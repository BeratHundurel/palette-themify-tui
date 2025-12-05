const std = @import("std");
const palette_themify = @import("palette_themify");
const color_utils = palette_themify.color_utils;
const vaxis = @import("vaxis");
const zigimg = @import("zigimg");

// Use vaxis panic handler for better terminal cleanup on crashes
pub const panic = vaxis.panic_handler;
const TextInput = vaxis.widgets.TextInput;

// Configure logging levels for vaxis components
pub const std_options: std.Options = .{
    .log_scope_levels = &.{
        .{ .scope = .vaxis, .level = .warn },
        .{ .scope = .vaxis_parser, .level = .warn },
    },
};

const ColorAndCount = struct {
    color: zigimg.color.Colorf32,
    count: usize,

    /// Two colors are considered similar if all RGB components differ by less than 10%
    fn colorSimilar(a: zigimg.color.Colorf32, b: zigimg.color.Colorf32) bool {
        const threshold = 0.1;
        return @abs(a.r - b.r) < threshold and
            @abs(a.g - b.g) < threshold and
            @abs(a.b - b.b) < threshold;
    }

    fn lessThan(_: void, a: ColorAndCount, b: ColorAndCount) bool {
        return a.count > b.count;
    }
};

const Event = union(enum) {
    key_press: vaxis.Key,
    key_release: vaxis.Key,
    mouse: vaxis.Mouse,
    focus_in,
    focus_out,
    paste_start,
    paste_end,
    paste: []const u8,
    color_report: vaxis.Color.Report,
    color_scheme: vaxis.Color.Scheme,
    winsize: vaxis.Winsize,
};

const ThemingOption = struct {
    name: []const u8,
};

const theming_options = [_]ThemingOption{
    .{ .name = "VSCode" },
    .{ .name = "Zed" },
};

const AppState = enum {
    image_input,
    color_palette,
    theme_name_input,
};

const PaletteThemify = struct {
    allocator: std.mem.Allocator,
    should_quit: bool,
    tty: vaxis.Tty,
    vx: vaxis.Vaxis,
    mouse: ?vaxis.Mouse,
    text_input: TextInput,
    theme_name_input: TextInput,
    user_given_path: ?[]const u8,
    colors: ?[]zigimg.color.Colorf32,
    selected_option_index: usize,
    scroll_offset: i16,
    status_message: ?[]const u8,
    status_is_error: bool,
    current_state: AppState,

    pub fn init(allocator: std.mem.Allocator) !PaletteThemify {
        var buffer: [1024]u8 = undefined;
        return .{
            .allocator = allocator,
            .should_quit = false,
            .tty = try vaxis.Tty.init(buffer[0..]),
            .vx = try vaxis.init(allocator, .{}),
            .mouse = null,
            .text_input = TextInput.init(allocator),
            .theme_name_input = TextInput.init(allocator),
            .user_given_path = null,
            .colors = null,
            .selected_option_index = 0,
            .scroll_offset = 0,
            .status_message = null,
            .status_is_error = false,
            .current_state = .image_input,
        };
    }

    pub fn deinit(self: *PaletteThemify) void {
        if (self.user_given_path) |path| {
            self.allocator.free(path);
        }
        if (self.colors) |colors| {
            self.allocator.free(colors);
        }
        if (self.status_message) |msg| {
            self.allocator.free(msg);
        }
        self.text_input.deinit();
        self.theme_name_input.deinit();
        self.vx.deinit(self.allocator, self.tty.writer());
        self.tty.deinit();
    }

    pub fn run(self: *PaletteThemify) !void {
        var loop: vaxis.Loop(Event) = .{
            .tty = &self.tty,
            .vaxis = &self.vx,
        };
        try loop.init();
        try loop.start();

        try self.vx.enterAltScreen(self.tty.writer());
        try self.vx.queryTerminal(self.tty.writer(), 1 * std.time.ns_per_s);
        try self.vx.setMouseMode(self.tty.writer(), true);

        while (!self.should_quit) {
            loop.pollEvent();
            while (loop.tryEvent()) |event| {
                try self.update(event);
            }
            self.draw();
            try self.vx.render(self.tty.writer());
        }
    }

    fn goBackToImageInput(self: *PaletteThemify) void {
        if (self.colors) |colors| {
            self.allocator.free(colors);
            self.colors = null;
        }
        if (self.user_given_path) |path| {
            self.allocator.free(path);
            self.user_given_path = null;
        }
        if (self.status_message) |msg| {
            self.allocator.free(msg);
            self.status_message = null;
        }
        self.status_is_error = false;
        self.selected_option_index = 0;
        self.scroll_offset = 0;
        self.current_state = .image_input;
        self.theme_name_input.clearAndFree();
    }

    fn goBackToColorPalette(self: *PaletteThemify, clear_status: bool) void {
        if (clear_status) {
            if (self.status_message) |msg| {
                self.allocator.free(msg);
                self.status_message = null;
            }
            self.status_is_error = false;
        }
        self.current_state = .color_palette;
        self.theme_name_input.clearAndFree();
    }

    pub fn update(self: *PaletteThemify, event: Event) !void {
        switch (event) {
            .key_press => |key| {
                if (key.matches('c', .{ .ctrl = true })) {
                    self.should_quit = true;
                } else if (self.current_state == .theme_name_input) {
                    if (key.matches(vaxis.Key.escape, .{})) {
                        self.goBackToColorPalette(true);
                    } else if (key.matches(vaxis.Key.enter, .{})) {
                        const theme_name = self.theme_name_input.toOwnedSlice() catch null;
                        if (theme_name) |name| {
                            defer self.allocator.free(name);
                            if (name.len == 0) {
                                if (self.status_message) |old_msg| {
                                    self.allocator.free(old_msg);
                                }
                                self.status_message = std.fmt.allocPrint(
                                    self.allocator,
                                    "Please enter a theme name",
                                    .{},
                                ) catch null;
                                self.status_is_error = true;
                            } else {
                                self.generateAndInstallTheme(name) catch |err| {
                                    if (self.status_message) |old_msg| {
                                        self.allocator.free(old_msg);
                                    }
                                    self.status_message = std.fmt.allocPrint(
                                        self.allocator,
                                        "Error: {s}",
                                        .{@errorName(err)},
                                    ) catch null;
                                    self.status_is_error = true;
                                };
                                self.goBackToColorPalette(false);
                            }
                        }
                    } else {
                        try self.theme_name_input.update(.{ .key_press = key });
                    }
                } else if (self.current_state == .color_palette) {
                    if (key.matches(vaxis.Key.escape, .{}) or key.matches(vaxis.Key.backspace, .{})) {
                        self.goBackToImageInput();
                    } else if (key.matches(vaxis.Key.page_up, .{})) {
                        self.scroll_offset = @max(0, self.scroll_offset - 5);
                    } else if (key.matches(vaxis.Key.page_down, .{})) {
                        self.scroll_offset += 5;
                    } else if (key.matches(vaxis.Key.up, .{ .ctrl = true })) {
                        self.scroll_offset = @max(0, self.scroll_offset - 1);
                    } else if (key.matches(vaxis.Key.down, .{ .ctrl = true })) {
                        self.scroll_offset += 1;
                    } else if (key.matches(vaxis.Key.up, .{}) or key.matches('k', .{})) {
                        if (self.selected_option_index > 0) {
                            self.selected_option_index -= 1;
                        }
                    } else if (key.matches(vaxis.Key.down, .{}) or key.matches('j', .{})) {
                        if (self.selected_option_index < theming_options.len - 1) {
                            self.selected_option_index += 1;
                        }
                    } else if (key.matches(vaxis.Key.enter, .{})) {
                        const selected_option = theming_options[self.selected_option_index];
                        if (std.mem.eql(u8, selected_option.name, "VSCode")) {
                            self.current_state = .theme_name_input;
                            if (self.status_message) |old_msg| {
                                self.allocator.free(old_msg);
                                self.status_message = null;
                            }
                        } else {
                            if (self.status_message) |old_msg| {
                                self.allocator.free(old_msg);
                            }
                            self.status_message = std.fmt.allocPrint(
                                self.allocator,
                                "Theme type '{s}' not yet implemented",
                                .{selected_option.name},
                            ) catch null;
                            self.status_is_error = true;
                        }
                    }
                } else if (key.matches(vaxis.Key.enter, .{})) {
                    if (self.user_given_path) |old_text| {
                        self.allocator.free(old_text);
                    }
                    self.user_given_path = try self.text_input.toOwnedSlice();

                    self.processUserPath() catch |err| {
                        if (self.status_message) |old_msg| {
                            self.allocator.free(old_msg);
                        }
                        const error_msg = switch (err) {
                            error.FileNotFound => "File not found. Please check the path and try again.",
                            error.AccessDenied => "Access denied. You don't have permission to read this file.",
                            error.IsDir => "The path is a directory, not an image file.",
                            error.InvalidCharacter => "The path contains invalid characters.",
                            error.NoColors => "Could not extract any colors from the image. Try a different image.",
                            error.NotAnImage => "The file is not a valid image. Supported formats: PNG, JPEG, BMP, etc.",
                            error.OutOfMemory => "Out of memory. Try a smaller image.",
                            else => @errorName(err),
                        };
                        self.status_message = std.fmt.allocPrint(
                            self.allocator,
                            "Error: {s}",
                            .{error_msg},
                        ) catch null;
                        self.status_is_error = true;
                    };
                } else {
                    try self.text_input.update(.{ .key_press = key });
                }
            },
            .mouse => |mouse| {
                self.mouse = mouse;
                if (self.current_state == .color_palette) {
                    if (mouse.button == .wheel_up) {
                        self.scroll_offset = @max(0, self.scroll_offset - 3);
                    } else if (mouse.button == .wheel_down) {
                        self.scroll_offset += 3;
                    }
                }
            },
            .winsize => |ws| try self.vx.resize(self.allocator, self.tty.writer(), ws),
            else => {},
        }
    }

    pub fn draw(self: *PaletteThemify) void {
        const win = self.vx.window();
        win.clear();
        self.vx.setMouseShape(.default);

        switch (self.current_state) {
            .image_input => self.drawTextInput(win),
            .color_palette => {
                const scroll_extra: u16 = @intCast(@max(0, self.scroll_offset));
                const scrolled_win = win.child(.{
                    .x_off = 0,
                    .y_off = @intCast(-self.scroll_offset),
                    .width = win.width,
                    .height = @as(u16, @min(65535, @as(u32, win.height) + @as(u32, scroll_extra) + 100)),
                });
                self.drawColorPalette(scrolled_win);
            },
            .theme_name_input => self.drawThemeNameInput(win),
        }
    }

    fn drawTextInput(self: *PaletteThemify, win: vaxis.Window) void {
        const text_input_win = win.child(.{
            .x_off = 2,
            .y_off = 2,
            .width = 50,
            .height = 3,
            .border = .{
                .where = .all,
                .style = .{
                    .fg = .{ .index = 6 },
                },
                .glyphs = .single_rounded,
            },
        });

        const label_segment = [_]vaxis.Cell.Segment{
            .{
                .text = "Give an image or file path.",
                .style = .{
                    .fg = .{ .index = 12 },
                    .bold = true,
                },
            },
        };

        const label_win = win.child(.{
            .x_off = 4,
            .y_off = 2,
            .width = 40,
            .height = 1,
        });
        _ = label_win.print(&label_segment, .{});

        const padded_input = text_input_win.child(.{
            .x_off = 1,
            .y_off = 0,
            .width = text_input_win.width - 2,
            .height = 1,
        });

        const style = vaxis.Cell.Style{ .fg = .{ .index = 7 } };
        self.text_input.drawWithStyle(padded_input, style);

        if (self.status_message) |msg| {
            const status_win = win.child(.{
                .x_off = 2,
                .y_off = 8,
                .width = @intCast(@min(win.width - 4, 80)),
                .height = 2,
            });

            const status_segment = [_]vaxis.Cell.Segment{
                .{
                    .text = msg,
                    .style = .{
                        .fg = if (self.status_is_error) .{ .index = 1 } else .{ .index = 2 },
                        .bold = true,
                    },
                },
            };
            _ = status_win.print(&status_segment, .{});
        }

        const help_win = win.child(.{
            .x_off = 2,
            .y_off = 11,
            .width = 60,
            .height = 1,
        });

        const help_segment = [_]vaxis.Cell.Segment{
            .{
                .text = "(Enter: load image, Ctrl+C: quit)",
                .style = .{
                    .fg = .{ .index = 8 },
                },
            },
        };
        _ = help_win.print(&help_segment, .{});
    }

    fn drawThemeNameInput(self: *PaletteThemify, win: vaxis.Window) void {
        const title_segment = [_]vaxis.Cell.Segment{
            .{
                .text = "Enter Theme Name",
                .style = .{
                    .fg = .{ .index = 15 },
                    .bold = true,
                },
            },
        };

        const title_win = win.child(.{
            .x_off = 2,
            .y_off = 2,
            .width = 50,
            .height = 1,
        });
        _ = title_win.print(&title_segment, .{});

        const text_input_win = win.child(.{
            .x_off = 2,
            .y_off = 4,
            .width = 50,
            .height = 3,
            .border = .{
                .where = .all,
                .style = .{
                    .fg = .{ .index = 6 },
                },
                .glyphs = .single_rounded,
            },
        });

        const label_segment = [_]vaxis.Cell.Segment{
            .{
                .text = "Theme name:",
                .style = .{
                    .fg = .{ .index = 12 },
                    .bold = true,
                },
            },
        };

        const label_win = win.child(.{
            .x_off = 4,
            .y_off = 4,
            .width = 40,
            .height = 1,
        });
        _ = label_win.print(&label_segment, .{});

        const padded_input = text_input_win.child(.{
            .x_off = 1,
            .y_off = 0,
            .width = text_input_win.width - 2,
            .height = 1,
        });

        const style = vaxis.Cell.Style{ .fg = .{ .index = 7 } };
        self.theme_name_input.drawWithStyle(padded_input, style);

        if (self.status_message) |msg| {
            const status_win = win.child(.{
                .x_off = 2,
                .y_off = 10,
                .width = @intCast(@min(win.width - 4, 80)),
                .height = 2,
            });

            const status_segment = [_]vaxis.Cell.Segment{
                .{
                    .text = msg,
                    .style = .{
                        .fg = if (self.status_is_error) .{ .index = 1 } else .{ .index = 2 },
                        .bold = true,
                    },
                },
            };
            _ = status_win.print(&status_segment, .{});
        }

        const help_win = win.child(.{
            .x_off = 2,
            .y_off = 13,
            .width = 60,
            .height = 1,
        });

        const help_segment = [_]vaxis.Cell.Segment{
            .{
                .text = "(Enter: create theme, Esc: go back, Ctrl+C: quit)",
                .style = .{
                    .fg = .{ .index = 8 },
                },
            },
        };
        _ = help_win.print(&help_segment, .{});
    }

    fn drawColorPalette(self: *PaletteThemify, win: vaxis.Window) void {
        const title_segment = [_]vaxis.Cell.Segment{
            .{
                .text = "Dominant Colors",
                .style = .{
                    .fg = .{ .index = 15 },
                    .bold = true,
                },
            },
        };

        const title_win = win.child(.{
            .x_off = 2,
            .y_off = 1,
            .width = 50,
            .height = 1,
        });
        _ = title_win.print(&title_segment, .{});

        const box_width: usize = 6;
        const box_height: usize = 3;
        const spacing: usize = 1;
        const margin: usize = 2;

        const available_width = win.width - margin;
        const boxes_per_row = @max(1, available_width / (box_width + spacing));

        for (self.colors.?, 0..) |color, i| {
            const row = i / boxes_per_row;
            const col = i % boxes_per_row;

            const x_pos: usize = margin + col * (box_width + spacing);
            const y_pos: usize = 3 + row * (box_height + 1);

            const rgb = color_utils.colorf32ToRgb(color.r, color.g, color.b);
            const bg_color = vaxis.Color{ .rgb = [3]u8{ rgb.r, rgb.g, rgb.b } };

            var y: usize = 0;
            while (y < box_height) : (y += 1) {
                var x: usize = 0;
                while (x < box_width) : (x += 1) {
                    win.writeCell(@intCast(x_pos + x), @intCast(y_pos + y), .{
                        .char = .{
                            .width = 1,
                        },
                        .style = .{
                            .bg = bg_color,
                        },
                    });
                }
            }
        }

        const total_rows = (self.colors.?.len + boxes_per_row - 1) / boxes_per_row;
        const menu_y_offset: usize = 3 + total_rows * (box_height + 1) + 1;

        const options_title_segment = [_]vaxis.Cell.Segment{
            .{
                .text = "Select Theming Option:",
                .style = .{
                    .fg = .{ .index = 14 },
                    .bold = true,
                },
            },
        };

        const options_title_win = win.child(.{
            .x_off = 2,
            .y_off = @intCast(menu_y_offset),
            .width = 70,
            .height = 1,
        });
        _ = options_title_win.print(&options_title_segment, .{});

        for (theming_options, 0..) |option, i| {
            const is_selected = i == self.selected_option_index;
            const option_y: usize = menu_y_offset + 2 + i * 2;

            const option_win = win.child(.{
                .x_off = 4,
                .y_off = @intCast(option_y),
                .width = 40,
                .height = 1,
            });

            const prefix = switch (i) {
                0 => if (is_selected) "► 1. " else "  1. ",
                1 => if (is_selected) "► 2. " else "  2. ",
                else => if (is_selected) "► ?. " else "  ?. ",
            };

            const prefix_segment = [_]vaxis.Cell.Segment{
                .{
                    .text = prefix,
                    .style = .{
                        .fg = if (is_selected) .{ .index = 11 } else .{ .index = 7 },
                        .bold = is_selected,
                    },
                },
            };
            const col = option_win.print(&prefix_segment, .{}).col;

            const name_segment = [_]vaxis.Cell.Segment{
                .{
                    .text = option.name,
                    .style = .{
                        .fg = if (is_selected) .{ .index = 15 } else .{ .index = 7 },
                        .bold = is_selected,
                    },
                },
            };
            _ = option_win.print(&name_segment, .{ .col_offset = col });
        }

        const help_y = menu_y_offset + 2 + theming_options.len * 2 + 1;
        const available_help_width = if (win.width > 4) win.width - 4 else 1;

        const help_text = if (available_help_width >= 80)
            "(↑/↓ or j/k: navigate, Enter: select, Esc: go back, PgUp/PgDn: scroll, Ctrl+C: quit)"
        else if (available_help_width >= 60)
            "(j/k: navigate, Enter: select, Esc: back, PgUp/PgDn: scroll)"
        else if (available_help_width >= 40)
            "(j/k/Enter, Esc: back, PgUp/PgDn)"
        else
            "(j/k/Enter, Esc)";

        const help_segment = [_]vaxis.Cell.Segment{
            .{
                .text = help_text,
                .style = .{
                    .fg = .{ .index = 8 },
                },
            },
        };

        const help_win = win.child(.{
            .x_off = 2,
            .y_off = @intCast(help_y),
            .width = @intCast(available_help_width),
            .height = 1,
        });
        _ = help_win.print(&help_segment, .{});

        if (self.status_message) |msg| {
            const status_y = help_y + 2;
            const status_segment = [_]vaxis.Cell.Segment{
                .{
                    .text = msg,
                    .style = .{
                        .fg = if (self.status_is_error) .{ .index = 1 } else .{ .index = 2 },
                        .bold = true,
                    },
                },
            };

            const status_win = win.child(.{
                .x_off = 2,
                .y_off = @intCast(status_y),
                .width = @intCast(@min(available_help_width, if (win.width > 4) win.width - 4 else 1)),
                .height = 1,
            });
            _ = status_win.print(&status_segment, .{});
        }
    }

    /// Load an image from user_given_path, extract colors by grouping similar pixels,
    /// and store the top 15 most frequent colors sorted by occurrence count.
    pub fn processUserPath(self: *PaletteThemify) !void {
        const path = self.user_given_path orelse return;

        if (path.len == 0) {
            return error.FileNotFound;
        }

        var fs = std.fs.cwd();
        const file = fs.openFile(path, .{}) catch |err| {
            return switch (err) {
                error.FileNotFound => error.FileNotFound,
                error.AccessDenied => error.AccessDenied,
                error.IsDir => error.IsDir,
                error.InvalidUtf8 => error.InvalidCharacter,
                else => err,
            };
        };
        defer file.close();

        var read_buffer: [zigimg.io.DEFAULT_BUFFER_SIZE]u8 = undefined;
        var img = zigimg.Image.fromFile(self.allocator, file, &read_buffer) catch {
            return error.NotAnImage;
        };
        defer img.deinit(self.allocator);

        if (self.colors) |old_colors| {
            self.allocator.free(old_colors);
        }

        var color_map = std.ArrayList(ColorAndCount){};
        defer color_map.deinit(self.allocator);

        var color_it = img.iterator();
        while (color_it.next()) |color| {
            if (color.a < 0.01) continue;

            var found = false;
            for (color_map.items) |*item| {
                if (ColorAndCount.colorSimilar(item.color, color)) {
                    item.count += 1;
                    found = true;
                    break;
                }
            }

            if (!found) {
                try color_map.append(self.allocator, .{
                    .color = color,
                    .count = 1,
                });
            }
        }

        if (color_map.items.len == 0) {
            return error.NoColors;
        }

        std.mem.sort(ColorAndCount, color_map.items, {}, ColorAndCount.lessThan);

        const num_colors = @min(20, color_map.items.len);
        self.colors = try self.allocator.alloc(zigimg.color.Colorf32, num_colors);

        for (0..num_colors) |i| {
            self.colors.?[i] = color_map.items[i].color;
        }

        if (self.status_message) |old_msg| {
            self.allocator.free(old_msg);
            self.status_message = null;
        }
        self.status_is_error = false;
        self.current_state = .color_palette;
    }

    fn generateAndInstallTheme(self: *PaletteThemify, theme_name: []const u8) !void {
        const selected_option = theming_options[self.selected_option_index];

        if (self.status_message) |old_msg| {
            self.allocator.free(old_msg);
            self.status_message = null;
        }

        if (std.mem.eql(u8, selected_option.name, "VSCode")) {
            if (self.colors) |colors| {
                self.status_message = try std.fmt.allocPrint(
                    self.allocator,
                    "Generating VS Code theme...",
                    .{},
                );
                self.status_is_error = false;

                var hex_colors = try self.allocator.alloc([]const u8, colors.len);
                defer {
                    for (hex_colors) |hex| {
                        self.allocator.free(hex);
                    }
                    self.allocator.free(hex_colors);
                }

                for (colors, 0..) |color, i| {
                    hex_colors[i] = try color_utils.colorf32ToHex(self.allocator, color.r, color.g, color.b);
                }

                const theme = try palette_themify.vscode.generateVSCodeTheme(
                    self.allocator,
                    hex_colors,
                );
                defer {
                    self.allocator.free(theme.tokenColors);
                }

                const install_path = try palette_themify.vscode.installThemeToVSCode(
                    self.allocator,
                    theme,
                    theme_name,
                );
                defer self.allocator.free(install_path);

                if (self.status_message) |old_msg| {
                    self.allocator.free(old_msg);
                }
                self.status_message = try std.fmt.allocPrint(
                    self.allocator,
                    "✓ Theme installed to: {s}",
                    .{install_path},
                );
                self.status_is_error = false;
            } else {
                self.status_message = try std.fmt.allocPrint(
                    self.allocator,
                    "No colors available. Please load an image first.",
                    .{},
                );
                self.status_is_error = true;
            }
        } else {
            self.status_message = try std.fmt.allocPrint(
                self.allocator,
                "Theme type '{s}' not yet implemented",
                .{selected_option.name},
            );
            self.status_is_error = true;
        }
    }
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            std.log.err("memory leak", .{});
        }
    }
    const allocator = gpa.allocator();

    var app = try PaletteThemify.init(allocator);
    defer app.deinit();

    try app.run();
}
