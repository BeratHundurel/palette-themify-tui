const std = @import("std");
const builtin = @import("builtin");
const types = @import("zed_types.zig");
const color_utils = @import("color_utils.zig");

pub const ZedTheme = types.ZedTheme;
const ZedThemeStyle = types.ZedThemeStyle;
const ZedThemeEntry = types.ZedThemeEntry;
const ZedSyntax = types.ZedSyntax;
const SyntaxStyle = types.SyntaxStyle;
const Player = types.Player;
const Appearance = types.Appearance;
const BackgroundAppearance = types.BackgroundAppearance;
const FontStyle = types.FontStyle;

pub fn generateZedTheme(
    allocator: std.mem.Allocator,
    colors: []const []const u8,
    theme_name: []const u8,
) !ZedTheme {
    const semantic = color_utils.findSemanticColors(colors);
    const improved_colors = try color_utils.selectDiverseColors(allocator, colors, 10);
    defer allocator.free(improved_colors);

    var sum_luminance: f32 = 0.0;
    for (improved_colors) |color| {
        sum_luminance += color_utils.getLuminance(color);
    }
    const average_luminance = sum_luminance / @as(f32, @floatFromInt(improved_colors.len));
    const dark_base = average_luminance < 128.0;

    const selection = try color_utils.selectBackgroundAndForeground(allocator, improved_colors, dark_base);
    defer allocator.free(selection.remaining_indices);

    const c0 = improved_colors[selection.background_index];
    const remaining = selection.remaining_indices;
    const c1_raw = improved_colors[remaining[0]];
    const c2_raw = improved_colors[remaining[1]];
    const c3_raw = improved_colors[remaining[2]];
    const c4_raw = improved_colors[remaining[3]];
    const c5_raw = improved_colors[remaining[4]];
    const c6_raw = improved_colors[remaining[5]];
    const c7_raw = improved_colors[remaining[6]];
    const c8_raw = improved_colors[remaining[7]];

    const base_luminance = color_utils.getLuminance(c0);
    const darken_amount = if (dark_base) 0.75 + (base_luminance) * 0.20 else 0.0;
    const lighten_amount = if (dark_base) 0.0 else 0.75 + (1.0 - base_luminance) * 0.20;

    const background = if (dark_base) color_utils.darkenColor(c0, darken_amount) else color_utils.lightenColor(c0, lighten_amount);
    const bg_very_dark = if (dark_base) color_utils.darkenColor(background, 0.20) else color_utils.lightenColor(background, 0.20);
    const bg_dark = if (dark_base) color_utils.darkenColor(background, 0.15) else color_utils.lightenColor(background, 0.15);
    const bg_light = if (dark_base) color_utils.lightenColor(background, 0.10) else color_utils.darkenColor(background, 0.05);
    const bg_lighter = if (dark_base) color_utils.lightenColor(background, 0.20) else color_utils.darkenColor(background, 0.10);

    const proposed_foreground = improved_colors[selection.foreground_index];
    const foreground = color_utils.ensureReadableContrast(proposed_foreground, background, 7.0);

    const fg_muted = if (dark_base) color_utils.darkenColor(foreground, 0.50) else color_utils.lightenColor(foreground, 0.50);
    const fg_disabled = if (dark_base) color_utils.darkenColor(foreground, 0.60) else color_utils.lightenColor(foreground, 0.60);
    const fg_placeholder = if (dark_base) color_utils.darkenColor(foreground, 0.70) else color_utils.lightenColor(foreground, 0.70);

    const fg_12 = color_utils.addAlpha(foreground, "12");
    const fg_26 = color_utils.addAlpha(foreground, "26");
    const fg_40 = color_utils.addAlpha(foreground, "40");
    const fg_66 = color_utils.addAlpha(foreground, "66");
    const fg_80 = color_utils.addAlpha(foreground, "80");

    const c1 = color_utils.adjustForContrast(c1_raw, bg_very_dark, 3.5);
    const c2 = color_utils.adjustForContrast(c2_raw, bg_very_dark, 3.5);

    const numbers_raw = color_utils.getHarmonicColor(c2, .complementary);
    const numbers = color_utils.adjustForContrast(numbers_raw, background, 3.5);

    const c3 = color_utils.adjustForContrast(c3_raw, background, 3.5);
    const c4 = color_utils.adjustForContrast(c4_raw, background, 3.5);
    const c5 = color_utils.adjustForContrast(c5_raw, background, 3.5);
    const c6 = color_utils.adjustForContrast(c6_raw, background, 3.5);
    const c7 = color_utils.adjustForContrast(c7_raw, background, 3.5);
    const c8 = color_utils.adjustForContrast(c8_raw, background, 3.5);

    const semantic_error = color_utils.adjustForContrast(semantic.error_color, background, 3.5);
    const semantic_warning = color_utils.adjustForContrast(semantic.warning_color, background, 3.5);
    const semantic_success = color_utils.adjustForContrast(semantic.success_color, background, 3.5);
    const semantic_info = color_utils.adjustForContrast(semantic.info_color, background, 3.5);

    const c2_33 = color_utils.addAlpha(c2, "33");
    const c2_40 = color_utils.addAlpha(c2, "40");
    const c2_66 = color_utils.addAlpha(c2, "66");
    const c2_88 = color_utils.addAlpha(c2, "88");
    const c2_99 = color_utils.addAlpha(c2, "99");
    const c3_33 = color_utils.addAlpha(c3, "33");

    const semantic_error_26 = color_utils.addAlpha(semantic_error, "26");
    const semantic_error_1f = color_utils.addAlpha(semantic_error, "1f");
    const semantic_warning_26 = color_utils.addAlpha(semantic_warning, "26");
    const semantic_warning_1f = color_utils.addAlpha(semantic_warning, "1f");
    const semantic_success_26 = color_utils.addAlpha(semantic_success, "26");
    const semantic_success_1f = color_utils.addAlpha(semantic_success, "1f");
    const semantic_success_88 = color_utils.addAlpha(semantic_success, "88");

    const accent_bright = if (dark_base) color_utils.lightenColor(c2, 0.33) else color_utils.darkenColor(c2, 0.33);

    const accents = try allocator.alloc([]const u8, 8);
    accents[7] = c1;
    accents[0] = c2;
    accents[1] = c3;
    accents[2] = c4;
    accents[3] = c5;
    accents[4] = c6;
    accents[5] = c7;
    accents[6] = c8;

    const players = try allocator.alloc(Player, 8);
    players[0] = .{ .cursor = foreground, .selection = fg_40, .background = foreground };
    players[1] = .{ .cursor = c2, .selection = c2_40, .background = c2 };
    players[2] = .{ .cursor = c3, .selection = c3_33, .background = c3 };
    players[3] = .{ .cursor = c4, .selection = color_utils.addAlpha(c4, "40"), .background = c4 };
    players[4] = .{ .cursor = c5, .selection = color_utils.addAlpha(c5, "40"), .background = c5 };
    players[5] = .{ .cursor = c6, .selection = color_utils.addAlpha(c6, "40"), .background = c6 };
    players[6] = .{ .cursor = c7, .selection = color_utils.addAlpha(c7, "40"), .background = c7 };
    players[7] = .{ .cursor = c8, .selection = color_utils.addAlpha(c8, "40"), .background = c8 };

    const style = ZedThemeStyle{
        .accents = accents,

        .@"vim.mode.text" = bg_very_dark,
        .@"vim.normal.background" = foreground,
        .@"vim.helix_normal.background" = foreground,
        .@"vim.visual.background" = c2,
        .@"vim.helix_select.background" = c2,
        .@"vim.insert.background" = semantic_success,
        .@"vim.visual_line.background" = c2,
        .@"vim.visual_block.background" = c3,
        .@"vim.replace.background" = semantic_error,

        .@"background.appearance" = .opaque_appearance,

        .border = bg_lighter,
        .@"border.variant" = c2_88,
        .@"border.focused" = c2_88,
        .@"border.selected" = c2_88,
        .@"border.transparent" = semantic_success_88,
        .@"border.disabled" = fg_disabled,

        .@"elevated_surface.background" = bg_dark,
        .@"surface.background" = bg_dark,
        .background = background,

        .@"element.background" = bg_very_dark,
        .@"element.hover" = bg_lighter,
        .@"element.active" = color_utils.addAlpha(bg_lighter, "4d"),
        .@"element.selected" = color_utils.addAlpha(bg_lighter, "4d"),
        .@"element.disabled" = fg_disabled,
        .@"drop_target.background" = color_utils.addAlpha(bg_lighter, "66"),

        .@"ghost_element.background" = "#00000000",
        .@"ghost_element.hover" = bg_light,
        .@"ghost_element.active" = bg_lighter,
        .@"ghost_element.selected" = fg_muted,
        .@"ghost_element.disabled" = fg_disabled,

        .text = foreground,
        .@"text.muted" = fg_muted,
        .@"text.placeholder" = fg_placeholder,
        .@"text.disabled" = fg_disabled,
        .@"text.accent" = c2,

        .icon = foreground,
        .@"icon.muted" = fg_muted,
        .@"icon.disabled" = fg_disabled,
        .@"icon.placeholder" = fg_placeholder,
        .@"icon.accent" = c2,

        .@"status_bar.background" = bg_very_dark,
        .@"title_bar.background" = bg_very_dark,
        .@"title_bar.inactive_background" = if (dark_base) color_utils.darkenColor(bg_very_dark, 0.30) else color_utils.lightenColor(bg_very_dark, 0.30),
        .@"toolbar.background" = background,

        .@"tab_bar.background" = bg_very_dark,
        .@"tab.inactive_background" = if (dark_base) color_utils.darkenColor(bg_very_dark, 0.30) else color_utils.lightenColor(bg_very_dark, 0.30),
        .@"tab.active_background" = background,

        .@"search.match_background" = c3_33,

        .@"panel.background" = bg_dark,
        .@"panel.focused_border" = foreground,
        .@"panel.indent_guide" = fg_placeholder,
        .@"panel.indent_guide_active" = fg_80,
        .@"panel.indent_guide_hover" = c2,
        .@"panel.overlay_background" = bg_very_dark,

        .@"pane.focused_border" = foreground,
        .@"pane_group.border" = bg_lighter,

        .@"scrollbar.thumb.background" = color_utils.addAlpha(fg_placeholder, "80"),
        .@"scrollbar.thumb.hover_background" = fg_muted,
        .@"scrollbar.thumb.active_background" = null,
        .@"scrollbar.thumb.border" = null,
        .@"scrollbar.track.background" = bg_very_dark,
        .@"scrollbar.track.border" = fg_12,

        .@"minimap.thumb.background" = c2_33,
        .@"minimap.thumb.hover_background" = c2_66,
        .@"minimap.thumb.active_background" = c2_99,
        .@"minimap.thumb.border" = null,

        .@"editor.foreground" = foreground,
        .@"editor.background" = background,
        .@"editor.gutter.background" = background,
        .@"editor.subheader.background" = bg_dark,
        .@"editor.active_line.background" = fg_12,
        .@"editor.highlighted_line.background" = null,
        .@"editor.line_number" = fg_muted,
        .@"editor.active_line_number" = c2,
        .@"editor.invisible" = fg_66,
        .@"editor.wrap_guide" = fg_placeholder,
        .@"editor.active_wrap_guide" = fg_placeholder,
        .@"editor.document_highlight.bracket_background" = color_utils.addAlpha(c2, "17"),
        .@"editor.document_highlight.read_background" = fg_26,
        .@"editor.document_highlight.write_background" = fg_26,
        .@"editor.indent_guide" = fg_placeholder,
        .@"editor.indent_guide_active" = fg_placeholder,

        .@"terminal.background" = background,
        .@"terminal.ansi.background" = background,
        .@"terminal.foreground" = foreground,
        .@"terminal.dim_foreground" = fg_muted,
        .@"terminal.bright_foreground" = foreground,
        .@"terminal.ansi.black" = if (dark_base) color_utils.darkenColor(foreground, 0.7) else color_utils.lightenColor(foreground, 0.7),
        .@"terminal.ansi.white" = fg_muted,
        .@"terminal.ansi.red" = semantic_error,
        .@"terminal.ansi.green" = semantic_success,
        .@"terminal.ansi.yellow" = semantic_warning,
        .@"terminal.ansi.blue" = semantic_info,
        .@"terminal.ansi.magenta" = c6,
        .@"terminal.ansi.cyan" = c7,
        .@"terminal.ansi.bright_black" = fg_placeholder,
        .@"terminal.ansi.bright_white" = fg_muted,
        .@"terminal.ansi.bright_red" = if (dark_base) color_utils.lightenColor(semantic_error, 0.1) else color_utils.darkenColor(semantic_error, 0.1),
        .@"terminal.ansi.bright_green" = if (dark_base) color_utils.lightenColor(semantic_success, 0.1) else color_utils.darkenColor(semantic_success, 0.1),
        .@"terminal.ansi.bright_yellow" = if (dark_base) color_utils.lightenColor(semantic_warning, 0.1) else color_utils.darkenColor(semantic_warning, 0.1),
        .@"terminal.ansi.bright_blue" = if (dark_base) color_utils.lightenColor(semantic_info, 0.1) else color_utils.darkenColor(semantic_info, 0.1),
        .@"terminal.ansi.bright_magenta" = if (dark_base) color_utils.lightenColor(c6, 0.1) else color_utils.darkenColor(c6, 0.1),
        .@"terminal.ansi.bright_cyan" = if (dark_base) color_utils.lightenColor(c7, 0.1) else color_utils.darkenColor(c7, 0.1),
        .@"terminal.ansi.dim_black" = if (dark_base) color_utils.darkenColor(foreground, 0.7) else color_utils.lightenColor(foreground, 0.7),
        .@"terminal.ansi.dim_white" = fg_muted,
        .@"terminal.ansi.dim_red" = semantic_error,
        .@"terminal.ansi.dim_green" = semantic_success,
        .@"terminal.ansi.dim_yellow" = semantic_warning,
        .@"terminal.ansi.dim_blue" = semantic_info,
        .@"terminal.ansi.dim_magenta" = c6,
        .@"terminal.ansi.dim_cyan" = c7,

        .@"link_text.hover" = accent_bright,

        .conflict = semantic_warning,
        .@"conflict.border" = semantic_warning,
        .@"conflict.background" = semantic_warning_26,
        .created = semantic_success,
        .@"created.border" = semantic_success,
        .@"created.background" = semantic_success_26,
        .deleted = semantic_error,
        .@"deleted.border" = semantic_error,
        .@"deleted.background" = semantic_error_26,
        .hidden = fg_disabled,
        .@"hidden.border" = fg_disabled,
        .@"hidden.background" = bg_dark,
        .hint = fg_placeholder,
        .@"hint.border" = fg_placeholder,
        .@"hint.background" = bg_dark,
        .ignored = fg_disabled,
        .@"ignored.border" = fg_disabled,
        .@"ignored.background" = color_utils.addAlpha(fg_disabled, "26"),
        .modified = semantic_warning,
        .@"modified.border" = semantic_warning,
        .@"modified.background" = semantic_warning_26,
        .predictive = fg_disabled,
        .@"predictive.border" = c2,
        .@"predictive.background" = bg_dark,
        .renamed = semantic_info,
        .@"renamed.border" = semantic_info,
        .@"renamed.background" = color_utils.addAlpha(semantic_info, "26"),
        .info = semantic_info,
        .@"info.border" = semantic_info,
        .@"info.background" = bg_light,
        .warning = semantic_warning,
        .@"warning.border" = semantic_warning,
        .@"warning.background" = semantic_warning_1f,
        .@"error" = semantic_error,
        .@"error.border" = semantic_error,
        .@"error.background" = semantic_error_1f,
        .success = semantic_success,
        .@"success.border" = semantic_success,
        .@"success.background" = semantic_success_1f,
        .@"unreachable" = semantic_error,
        .@"unreachable.border" = semantic_error,
        .@"unreachable.background" = semantic_error_1f,

        .players = players,

        .@"version_control.added" = semantic_success,
        .@"version_control.deleted" = semantic_error,
        .@"version_control.modified" = semantic_warning,
        .@"version_control.renamed" = semantic_info,
        .@"version_control.conflict" = semantic_warning,
        .@"version_control.conflict_marker.ours" = color_utils.addAlpha(semantic_success, "33"),
        .@"version_control.conflict_marker.theirs" = color_utils.addAlpha(semantic_info, "33"),
        .@"version_control.ignored" = fg_disabled,

        .@"debugger.accent" = semantic_error,
        .@"editor.debugger_active_line.background" = color_utils.addAlpha(semantic_warning, "12"),

        .syntax = ZedSyntax{
            .variable = .{ .color = foreground, .font_style = null, .font_weight = null },
            .@"variable.builtin" = .{ .color = semantic_error, .font_style = null, .font_weight = null },
            .@"variable.parameter" = .{ .color = c7, .font_style = null, .font_weight = null },
            .@"variable.member" = .{ .color = c1, .font_style = null, .font_weight = null },
            .@"variable.special" = .{ .color = semantic_error, .font_style = .italic, .font_weight = null },
            .constant = .{ .color = c5, .font_style = null, .font_weight = null },
            .@"constant.builtin" = .{ .color = c5, .font_style = null, .font_weight = null },
            .@"constant.macro" = .{ .color = c6, .font_style = null, .font_weight = null },
            .module = .{ .color = c5, .font_style = .italic, .font_weight = null },
            .label = .{ .color = semantic_info, .font_style = null, .font_weight = null },
            .string = .{ .color = c3, .font_style = null, .font_weight = null },
            .@"string.documentation" = .{ .color = c7, .font_style = null, .font_weight = null },
            .@"string.regexp" = .{ .color = numbers, .font_style = null, .font_weight = null },
            .@"string.escape" = .{ .color = c4, .font_style = null, .font_weight = null },
            .@"string.special" = .{ .color = c4, .font_style = null, .font_weight = null },
            .@"string.special.path" = .{ .color = c4, .font_style = null, .font_weight = null },
            .@"string.special.symbol" = .{ .color = c8, .font_style = null, .font_weight = null },
            .@"string.special.url" = .{ .color = foreground, .font_style = .italic, .font_weight = null },
            .character = .{ .color = c7, .font_style = null, .font_weight = null },
            .@"character.special" = .{ .color = c4, .font_style = null, .font_weight = null },
            .boolean = .{ .color = numbers, .font_style = null, .font_weight = null },
            .number = .{ .color = numbers, .font_style = null, .font_weight = null },
            .@"number.float" = .{ .color = numbers, .font_style = null, .font_weight = null },
            .type = .{ .color = c5, .font_style = null, .font_weight = null },
            .attribute = .{ .color = numbers, .font_style = null, .font_weight = null },
            .property = .{ .color = c1, .font_style = null, .font_weight = null },
            .function = .{ .color = c2, .font_style = null, .font_weight = null },
            .constructor = .{ .color = c8, .font_style = null, .font_weight = null },
            .operator = .{ .color = accent_bright, .font_style = null, .font_weight = null },
            .keyword = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.modifier" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.type" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.coroutine" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.function" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.operator" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.import" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.repeat" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.return" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.debug" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.exception" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.conditional" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.conditional.ternary" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"keyword.directive" = .{ .color = c4, .font_style = null, .font_weight = null },
            .@"keyword.directive.define" = .{ .color = c4, .font_style = null, .font_weight = null },
            .@"keyword.export" = .{ .color = accent_bright, .font_style = null, .font_weight = null },
            .punctuation = .{ .color = fg_muted, .font_style = null, .font_weight = null },
            .@"punctuation.delimiter" = .{ .color = fg_muted, .font_style = null, .font_weight = null },
            .@"punctuation.bracket" = .{ .color = fg_muted, .font_style = null, .font_weight = null },
            .@"punctuation.special" = .{ .color = c4, .font_style = null, .font_weight = null },
            .@"punctuation.special.symbol" = .{ .color = c8, .font_style = null, .font_weight = null },
            .@"punctuation.list_marker" = .{ .color = c7, .font_style = null, .font_weight = null },
            .comment = .{ .color = fg_muted, .font_style = .italic, .font_weight = null },
            .@"comment.doc" = .{ .color = fg_muted, .font_style = .italic, .font_weight = null },
            .@"comment.documentation" = .{ .color = fg_muted, .font_style = .italic, .font_weight = null },
            .@"comment.error" = .{ .color = semantic_error, .font_style = .italic, .font_weight = null },
            .@"comment.warning" = .{ .color = semantic_warning, .font_style = .italic, .font_weight = null },
            .@"comment.hint" = .{ .color = semantic_info, .font_style = .italic, .font_weight = null },
            .@"comment.todo" = .{ .color = c8, .font_style = .italic, .font_weight = null },
            .@"comment.note" = .{ .color = foreground, .font_style = .italic, .font_weight = null },
            .@"diff.plus" = .{ .color = semantic_success, .font_style = null, .font_weight = null },
            .@"diff.minus" = .{ .color = semantic_error, .font_style = null, .font_weight = null },
            .tag = .{ .color = c2, .font_style = null, .font_weight = null },
            .@"tag.attribute" = .{ .color = c5, .font_style = .italic, .font_weight = null },
            .@"tag.delimiter" = .{ .color = c7, .font_style = null, .font_weight = null },
            .parameter = .{ .color = c7, .font_style = null, .font_weight = null },
            .field = .{ .color = c1, .font_style = null, .font_weight = null },
            .namespace = .{ .color = c5, .font_style = .italic, .font_weight = null },
            .float = .{ .color = numbers, .font_style = null, .font_weight = null },
            .symbol = .{ .color = c4, .font_style = null, .font_weight = null },
            .@"string.regex" = .{ .color = numbers, .font_style = null, .font_weight = null },
            .text = .{ .color = foreground, .font_style = null, .font_weight = null },
            .@"emphasis.strong" = .{ .color = c7, .font_style = null, .font_weight = 700 },
            .emphasis = .{ .color = c7, .font_style = .italic, .font_weight = null },
            .embedded = .{ .color = c7, .font_style = null, .font_weight = null },
            .@"text.literal" = .{ .color = c3, .font_style = null, .font_weight = null },
            .concept = .{ .color = semantic_info, .font_style = null, .font_weight = null },
            .@"enum" = .{ .color = c7, .font_style = null, .font_weight = 700 },
            .@"function.decorator" = .{ .color = numbers, .font_style = null, .font_weight = null },
            .@"type.class.definition" = .{ .color = c5, .font_style = null, .font_weight = 700 },
            .hint = .{ .color = fg_muted, .font_style = .italic, .font_weight = null },
            .link_text = .{ .color = c1, .font_style = null, .font_weight = null },
            .link_uri = .{ .color = c2, .font_style = .italic, .font_weight = null },
            .parent = .{ .color = numbers, .font_style = null, .font_weight = null },
            .predictive = .{ .color = fg_disabled, .font_style = null, .font_weight = null },
            .predoc = .{ .color = semantic_error, .font_style = null, .font_weight = null },
            .primary = .{ .color = c7, .font_style = null, .font_weight = null },
            .@"tag.doctype" = .{ .color = c6, .font_style = null, .font_weight = null },
            .@"string.doc" = .{ .color = c7, .font_style = .italic, .font_weight = null },
            .title = .{ .color = foreground, .font_style = null, .font_weight = 800 },
            .variant = .{ .color = semantic_error, .font_style = null, .font_weight = null },
        },
    };

    const themes = try allocator.alloc(ZedThemeEntry, 1);
    themes[0] = .{
        .name = theme_name,
        .appearance = if (dark_base) .dark else .light,
        .style = style,
    };

    return ZedTheme{
        .@"$schema" = "https://zed.dev/schema/themes/v0.2.0.json",
        .name = theme_name,
        .author = "Palette Themify",
        .themes = themes,
    };
}

pub fn installThemeToZed(allocator: std.mem.Allocator, theme: ZedTheme, theme_name: []const u8) ![]const u8 {
    var themes_dir: []const u8 = undefined;

    if (builtin.os.tag == .windows) {
        const appdata = std.process.getEnvVarOwned(allocator, "APPDATA") catch |err| {
            std.log.err("Failed to get APPDATA environment variable: {}", .{err});
            return error.EnvVarNotFound;
        };
        defer allocator.free(appdata);
        themes_dir = try std.fs.path.join(allocator, &.{ appdata, "Zed", "themes" });
    } else {
        const home = std.process.getEnvVarOwned(allocator, "HOME") catch |err| {
            std.log.err("Failed to get HOME environment variable: {}", .{err});
            return error.EnvVarNotFound;
        };
        defer allocator.free(home);
        themes_dir = try std.fs.path.join(allocator, &.{ home, ".config", "zed", "themes" });
    }
    defer allocator.free(themes_dir);

    std.fs.makeDirAbsolute(themes_dir) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => {
            std.log.err("Failed to create themes directory: {}", .{err});
            return err;
        },
    };

    const safe_name = try makeSafeFilename(allocator, theme_name);
    defer allocator.free(safe_name);

    const filename = try std.fmt.allocPrint(allocator, "{s}.json", .{safe_name});
    defer allocator.free(filename);

    const theme_path = try std.fs.path.join(allocator, &.{ themes_dir, filename });

    var json_writer = std.io.Writer.Allocating.init(allocator);
    defer json_writer.deinit();

    try writeZedThemeJson(&json_writer.writer, theme);

    const json_string = try json_writer.toOwnedSlice();
    defer allocator.free(json_string);

    var file = try std.fs.createFileAbsolute(theme_path, .{});
    defer file.close();

    try file.writeAll(json_string);

    return theme_path;
}

fn writeZedThemeJson(writer: anytype, theme: ZedTheme) !void {
    try writer.writeAll("{\n");
    try writer.writeAll("    \"$schema\": \"");
    try writer.writeAll(theme.@"$schema");
    try writer.writeAll("\",\n");
    try writer.writeAll("    \"name\": \"");
    try writer.writeAll(theme.name);
    try writer.writeAll("\",\n");
    try writer.writeAll("    \"author\": \"");
    try writer.writeAll(theme.author);
    try writer.writeAll("\",\n");
    try writer.writeAll("    \"themes\": [\n");

    for (theme.themes, 0..) |entry, i| {
        try writer.writeAll("        {\n");
        try writer.writeAll("            \"name\": \"");
        try writer.writeAll(entry.name);
        try writer.writeAll("\",\n");
        try writer.writeAll("            \"appearance\": \"");
        try writer.writeAll(if (entry.appearance == .dark) "dark" else "light");
        try writer.writeAll("\",\n");
        try writer.writeAll("            \"style\": ");
        try writeZedThemeStyle(writer, entry.style);
        try writer.writeAll("\n        }");
        if (i < theme.themes.len - 1) {
            try writer.writeAll(",");
        }
        try writer.writeAll("\n");
    }

    try writer.writeAll("    ]\n");
    try writer.writeAll("}\n");
}

fn writeString(writer: anytype, key: []const u8, value: []const u8, indent: []const u8, trailing_comma: bool) !void {
    try writer.writeAll(indent);
    try writer.writeAll("\"");
    try writer.writeAll(key);
    try writer.writeAll("\": \"");
    try writer.writeAll(value);
    try writer.writeAll("\"");
    if (trailing_comma) try writer.writeAll(",");
    try writer.writeAll("\n");
}

fn writeOptionalString(writer: anytype, key: []const u8, value: ?[]const u8, indent: []const u8, trailing_comma: bool) !void {
    try writer.writeAll(indent);
    try writer.writeAll("\"");
    try writer.writeAll(key);
    try writer.writeAll("\": ");
    if (value) |v| {
        try writer.writeAll("\"");
        try writer.writeAll(v);
        try writer.writeAll("\"");
    } else {
        try writer.writeAll("null");
    }
    if (trailing_comma) try writer.writeAll(",");
    try writer.writeAll("\n");
}

fn writeZedThemeStyle(writer: anytype, style: ZedThemeStyle) !void {
    const indent = "                ";
    try writer.writeAll("{\n");

    try writer.writeAll(indent);
    try writer.writeAll("\"accents\": [\n");
    for (style.accents, 0..) |accent, i| {
        try writer.writeAll(indent);
        try writer.writeAll("    \"");
        try writer.writeAll(accent);
        try writer.writeAll("\"");
        if (i < style.accents.len - 1) try writer.writeAll(",");
        try writer.writeAll("\n");
    }
    try writer.writeAll(indent);
    try writer.writeAll("],\n");

    try writeString(writer, "vim.mode.text", style.@"vim.mode.text", indent, true);
    try writeString(writer, "vim.normal.background", style.@"vim.normal.background", indent, true);
    try writeString(writer, "vim.helix_normal.background", style.@"vim.helix_normal.background", indent, true);
    try writeString(writer, "vim.visual.background", style.@"vim.visual.background", indent, true);
    try writeString(writer, "vim.helix_select.background", style.@"vim.helix_select.background", indent, true);
    try writeString(writer, "vim.insert.background", style.@"vim.insert.background", indent, true);
    try writeString(writer, "vim.visual_line.background", style.@"vim.visual_line.background", indent, true);
    try writeString(writer, "vim.visual_block.background", style.@"vim.visual_block.background", indent, true);
    try writeString(writer, "vim.replace.background", style.@"vim.replace.background", indent, true);

    try writer.writeAll(indent);
    try writer.writeAll("\"background.appearance\": \"");
    try writer.writeAll(switch (style.@"background.appearance") {
        .opaque_appearance => "opaque",
        .blurred => "blurred",
        .transparent => "transparent",
    });
    try writer.writeAll("\",\n");

    try writeString(writer, "border", style.border, indent, true);
    try writeString(writer, "border.variant", style.@"border.variant", indent, true);
    try writeString(writer, "border.focused", style.@"border.focused", indent, true);
    try writeString(writer, "border.selected", style.@"border.selected", indent, true);
    try writeString(writer, "border.transparent", style.@"border.transparent", indent, true);
    try writeString(writer, "border.disabled", style.@"border.disabled", indent, true);

    try writeString(writer, "elevated_surface.background", style.@"elevated_surface.background", indent, true);
    try writeString(writer, "surface.background", style.@"surface.background", indent, true);
    try writeString(writer, "background", style.background, indent, true);

    try writeString(writer, "element.background", style.@"element.background", indent, true);
    try writeString(writer, "element.hover", style.@"element.hover", indent, true);
    try writeString(writer, "element.active", style.@"element.active", indent, true);
    try writeString(writer, "element.selected", style.@"element.selected", indent, true);
    try writeString(writer, "element.disabled", style.@"element.disabled", indent, true);
    try writeString(writer, "drop_target.background", style.@"drop_target.background", indent, true);

    try writeString(writer, "ghost_element.background", style.@"ghost_element.background", indent, true);
    try writeString(writer, "ghost_element.hover", style.@"ghost_element.hover", indent, true);
    try writeString(writer, "ghost_element.active", style.@"ghost_element.active", indent, true);
    try writeString(writer, "ghost_element.selected", style.@"ghost_element.selected", indent, true);
    try writeString(writer, "ghost_element.disabled", style.@"ghost_element.disabled", indent, true);

    try writeString(writer, "text", style.text, indent, true);
    try writeString(writer, "text.muted", style.@"text.muted", indent, true);
    try writeString(writer, "text.placeholder", style.@"text.placeholder", indent, true);
    try writeString(writer, "text.disabled", style.@"text.disabled", indent, true);
    try writeString(writer, "text.accent", style.@"text.accent", indent, true);

    try writeString(writer, "icon", style.icon, indent, true);
    try writeString(writer, "icon.muted", style.@"icon.muted", indent, true);
    try writeString(writer, "icon.disabled", style.@"icon.disabled", indent, true);
    try writeString(writer, "icon.placeholder", style.@"icon.placeholder", indent, true);
    try writeString(writer, "icon.accent", style.@"icon.accent", indent, true);

    try writeString(writer, "status_bar.background", style.@"status_bar.background", indent, true);
    try writeString(writer, "title_bar.background", style.@"title_bar.background", indent, true);
    try writeString(writer, "title_bar.inactive_background", style.@"title_bar.inactive_background", indent, true);
    try writeString(writer, "toolbar.background", style.@"toolbar.background", indent, true);

    try writeString(writer, "tab_bar.background", style.@"tab_bar.background", indent, true);
    try writeString(writer, "tab.inactive_background", style.@"tab.inactive_background", indent, true);
    try writeString(writer, "tab.active_background", style.@"tab.active_background", indent, true);

    try writeString(writer, "search.match_background", style.@"search.match_background", indent, true);

    try writeString(writer, "panel.background", style.@"panel.background", indent, true);
    try writeString(writer, "panel.focused_border", style.@"panel.focused_border", indent, true);
    try writeString(writer, "panel.indent_guide", style.@"panel.indent_guide", indent, true);
    try writeString(writer, "panel.indent_guide_active", style.@"panel.indent_guide_active", indent, true);
    try writeString(writer, "panel.indent_guide_hover", style.@"panel.indent_guide_hover", indent, true);
    try writeString(writer, "panel.overlay_background", style.@"panel.overlay_background", indent, true);

    try writeString(writer, "pane.focused_border", style.@"pane.focused_border", indent, true);
    try writeString(writer, "pane_group.border", style.@"pane_group.border", indent, true);

    try writeString(writer, "scrollbar.thumb.background", style.@"scrollbar.thumb.background", indent, true);
    try writeString(writer, "scrollbar.thumb.hover_background", style.@"scrollbar.thumb.hover_background", indent, true);
    try writeOptionalString(writer, "scrollbar.thumb.active_background", style.@"scrollbar.thumb.active_background", indent, true);
    try writeOptionalString(writer, "scrollbar.thumb.border", style.@"scrollbar.thumb.border", indent, true);
    try writeString(writer, "scrollbar.track.background", style.@"scrollbar.track.background", indent, true);
    try writeString(writer, "scrollbar.track.border", style.@"scrollbar.track.border", indent, true);

    try writeString(writer, "minimap.thumb.background", style.@"minimap.thumb.background", indent, true);
    try writeString(writer, "minimap.thumb.hover_background", style.@"minimap.thumb.hover_background", indent, true);
    try writeString(writer, "minimap.thumb.active_background", style.@"minimap.thumb.active_background", indent, true);
    try writeOptionalString(writer, "minimap.thumb.border", style.@"minimap.thumb.border", indent, true);

    try writeString(writer, "editor.foreground", style.@"editor.foreground", indent, true);
    try writeString(writer, "editor.background", style.@"editor.background", indent, true);
    try writeString(writer, "editor.gutter.background", style.@"editor.gutter.background", indent, true);
    try writeString(writer, "editor.subheader.background", style.@"editor.subheader.background", indent, true);
    try writeString(writer, "editor.active_line.background", style.@"editor.active_line.background", indent, true);
    try writeOptionalString(writer, "editor.highlighted_line.background", style.@"editor.highlighted_line.background", indent, true);
    try writeString(writer, "editor.line_number", style.@"editor.line_number", indent, true);
    try writeString(writer, "editor.active_line_number", style.@"editor.active_line_number", indent, true);
    try writeString(writer, "editor.invisible", style.@"editor.invisible", indent, true);
    try writeString(writer, "editor.wrap_guide", style.@"editor.wrap_guide", indent, true);
    try writeString(writer, "editor.active_wrap_guide", style.@"editor.active_wrap_guide", indent, true);
    try writeString(writer, "editor.document_highlight.bracket_background", style.@"editor.document_highlight.bracket_background", indent, true);
    try writeString(writer, "editor.document_highlight.read_background", style.@"editor.document_highlight.read_background", indent, true);
    try writeString(writer, "editor.document_highlight.write_background", style.@"editor.document_highlight.write_background", indent, true);
    try writeString(writer, "editor.indent_guide", style.@"editor.indent_guide", indent, true);
    try writeString(writer, "editor.indent_guide_active", style.@"editor.indent_guide_active", indent, true);

    try writeString(writer, "terminal.background", style.@"terminal.background", indent, true);
    try writeString(writer, "terminal.ansi.background", style.@"terminal.ansi.background", indent, true);
    try writeString(writer, "terminal.foreground", style.@"terminal.foreground", indent, true);
    try writeString(writer, "terminal.dim_foreground", style.@"terminal.dim_foreground", indent, true);
    try writeString(writer, "terminal.bright_foreground", style.@"terminal.bright_foreground", indent, true);
    try writeString(writer, "terminal.ansi.black", style.@"terminal.ansi.black", indent, true);
    try writeString(writer, "terminal.ansi.white", style.@"terminal.ansi.white", indent, true);
    try writeString(writer, "terminal.ansi.red", style.@"terminal.ansi.red", indent, true);
    try writeString(writer, "terminal.ansi.green", style.@"terminal.ansi.green", indent, true);
    try writeString(writer, "terminal.ansi.yellow", style.@"terminal.ansi.yellow", indent, true);
    try writeString(writer, "terminal.ansi.blue", style.@"terminal.ansi.blue", indent, true);
    try writeString(writer, "terminal.ansi.magenta", style.@"terminal.ansi.magenta", indent, true);
    try writeString(writer, "terminal.ansi.cyan", style.@"terminal.ansi.cyan", indent, true);
    try writeString(writer, "terminal.ansi.bright_black", style.@"terminal.ansi.bright_black", indent, true);
    try writeString(writer, "terminal.ansi.bright_white", style.@"terminal.ansi.bright_white", indent, true);
    try writeString(writer, "terminal.ansi.bright_red", style.@"terminal.ansi.bright_red", indent, true);
    try writeString(writer, "terminal.ansi.bright_green", style.@"terminal.ansi.bright_green", indent, true);
    try writeString(writer, "terminal.ansi.bright_yellow", style.@"terminal.ansi.bright_yellow", indent, true);
    try writeString(writer, "terminal.ansi.bright_blue", style.@"terminal.ansi.bright_blue", indent, true);
    try writeString(writer, "terminal.ansi.bright_magenta", style.@"terminal.ansi.bright_magenta", indent, true);
    try writeString(writer, "terminal.ansi.bright_cyan", style.@"terminal.ansi.bright_cyan", indent, true);
    try writeString(writer, "terminal.ansi.dim_black", style.@"terminal.ansi.dim_black", indent, true);
    try writeString(writer, "terminal.ansi.dim_white", style.@"terminal.ansi.dim_white", indent, true);
    try writeString(writer, "terminal.ansi.dim_red", style.@"terminal.ansi.dim_red", indent, true);
    try writeString(writer, "terminal.ansi.dim_green", style.@"terminal.ansi.dim_green", indent, true);
    try writeString(writer, "terminal.ansi.dim_yellow", style.@"terminal.ansi.dim_yellow", indent, true);
    try writeString(writer, "terminal.ansi.dim_blue", style.@"terminal.ansi.dim_blue", indent, true);
    try writeString(writer, "terminal.ansi.dim_magenta", style.@"terminal.ansi.dim_magenta", indent, true);
    try writeString(writer, "terminal.ansi.dim_cyan", style.@"terminal.ansi.dim_cyan", indent, true);

    try writeString(writer, "link_text.hover", style.@"link_text.hover", indent, true);

    try writeString(writer, "conflict", style.conflict, indent, true);
    try writeString(writer, "conflict.border", style.@"conflict.border", indent, true);
    try writeString(writer, "conflict.background", style.@"conflict.background", indent, true);
    try writeString(writer, "created", style.created, indent, true);
    try writeString(writer, "created.border", style.@"created.border", indent, true);
    try writeString(writer, "created.background", style.@"created.background", indent, true);
    try writeString(writer, "deleted", style.deleted, indent, true);
    try writeString(writer, "deleted.border", style.@"deleted.border", indent, true);
    try writeString(writer, "deleted.background", style.@"deleted.background", indent, true);
    try writeString(writer, "hidden", style.hidden, indent, true);
    try writeString(writer, "hidden.border", style.@"hidden.border", indent, true);
    try writeString(writer, "hidden.background", style.@"hidden.background", indent, true);
    try writeString(writer, "hint", style.hint, indent, true);
    try writeString(writer, "hint.border", style.@"hint.border", indent, true);
    try writeString(writer, "hint.background", style.@"hint.background", indent, true);
    try writeString(writer, "ignored", style.ignored, indent, true);
    try writeString(writer, "ignored.border", style.@"ignored.border", indent, true);
    try writeString(writer, "ignored.background", style.@"ignored.background", indent, true);
    try writeString(writer, "modified", style.modified, indent, true);
    try writeString(writer, "modified.border", style.@"modified.border", indent, true);
    try writeString(writer, "modified.background", style.@"modified.background", indent, true);
    try writeString(writer, "predictive", style.predictive, indent, true);
    try writeString(writer, "predictive.border", style.@"predictive.border", indent, true);
    try writeString(writer, "predictive.background", style.@"predictive.background", indent, true);
    try writeString(writer, "renamed", style.renamed, indent, true);
    try writeString(writer, "renamed.border", style.@"renamed.border", indent, true);
    try writeString(writer, "renamed.background", style.@"renamed.background", indent, true);
    try writeString(writer, "info", style.info, indent, true);
    try writeString(writer, "info.border", style.@"info.border", indent, true);
    try writeString(writer, "info.background", style.@"info.background", indent, true);
    try writeString(writer, "warning", style.warning, indent, true);
    try writeString(writer, "warning.border", style.@"warning.border", indent, true);
    try writeString(writer, "warning.background", style.@"warning.background", indent, true);
    try writeString(writer, "error", style.@"error", indent, true);
    try writeString(writer, "error.border", style.@"error.border", indent, true);
    try writeString(writer, "error.background", style.@"error.background", indent, true);
    try writeString(writer, "success", style.success, indent, true);
    try writeString(writer, "success.border", style.@"success.border", indent, true);
    try writeString(writer, "success.background", style.@"success.background", indent, true);
    try writeString(writer, "unreachable", style.@"unreachable", indent, true);
    try writeString(writer, "unreachable.border", style.@"unreachable.border", indent, true);
    try writeString(writer, "unreachable.background", style.@"unreachable.background", indent, true);

    try writer.writeAll(indent);
    try writer.writeAll("\"players\": [\n");
    for (style.players, 0..) |player, i| {
        try writer.writeAll(indent);
        try writer.writeAll("    {\n");
        try writeString(writer, "cursor", player.cursor, indent ++ "        ", true);
        try writeString(writer, "selection", player.selection, indent ++ "        ", true);
        try writeString(writer, "background", player.background, indent ++ "        ", false);
        try writer.writeAll(indent);
        try writer.writeAll("    }");
        if (i < style.players.len - 1) try writer.writeAll(",");
        try writer.writeAll("\n");
    }
    try writer.writeAll(indent);
    try writer.writeAll("],\n");

    try writeString(writer, "version_control.added", style.@"version_control.added", indent, true);
    try writeString(writer, "version_control.deleted", style.@"version_control.deleted", indent, true);
    try writeString(writer, "version_control.modified", style.@"version_control.modified", indent, true);
    try writeString(writer, "version_control.renamed", style.@"version_control.renamed", indent, true);
    try writeString(writer, "version_control.conflict", style.@"version_control.conflict", indent, true);
    try writeString(writer, "version_control.conflict_marker.ours", style.@"version_control.conflict_marker.ours", indent, true);
    try writeString(writer, "version_control.conflict_marker.theirs", style.@"version_control.conflict_marker.theirs", indent, true);
    try writeString(writer, "version_control.ignored", style.@"version_control.ignored", indent, true);

    try writeString(writer, "debugger.accent", style.@"debugger.accent", indent, true);
    try writeString(writer, "editor.debugger_active_line.background", style.@"editor.debugger_active_line.background", indent, true);

    try writer.writeAll(indent);
    try writer.writeAll("\"syntax\": ");
    try writeSyntax(writer, style.syntax);
    try writer.writeAll("\n");

    try writer.writeAll("            }");
}

fn writeSyntax(writer: anytype, syntax: ZedSyntax) !void {
    const indent = "                    ";
    try writer.writeAll("{\n");

    const fields = @typeInfo(ZedSyntax).@"struct".fields;
    inline for (fields, 0..) |field, i| {
        try writer.writeAll(indent);
        try writer.writeAll("\"");
        try writer.writeAll(field.name);
        try writer.writeAll("\": ");
        try writeSyntaxStyle(writer, @field(syntax, field.name));
        if (i < fields.len - 1) try writer.writeAll(",");
        try writer.writeAll("\n");
    }

    try writer.writeAll("                }");
}

fn writeSyntaxStyle(writer: anytype, style: SyntaxStyle) !void {
    try writer.writeAll("{\n");
    const inner_indent = "                        ";
    try writeString(writer, "color", style.color, inner_indent, true);

    try writer.writeAll(inner_indent);
    try writer.writeAll("\"font_style\": ");
    if (style.font_style) |fs| {
        try writer.writeAll("\"");
        try writer.writeAll(switch (fs) {
            .normal => "normal",
            .italic => "italic",
            .oblique => "oblique",
        });
        try writer.writeAll("\"");
    } else {
        try writer.writeAll("null");
    }
    try writer.writeAll(",\n");

    try writer.writeAll(inner_indent);
    try writer.writeAll("\"font_weight\": ");
    if (style.font_weight) |fw| {
        var buf: [16]u8 = undefined;
        const result = std.fmt.bufPrint(&buf, "{d}", .{fw}) catch "0";
        try writer.writeAll(result);
    } else {
        try writer.writeAll("null");
    }
    try writer.writeAll("\n");

    try writer.writeAll("                    }");
}

fn makeSafeFilename(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    var result = try allocator.alloc(u8, name.len);
    var i: usize = 0;

    for (name) |c| {
        if (std.ascii.isAlphanumeric(c) or c == '-' or c == '_') {
            result[i] = std.ascii.toLower(c);
            i += 1;
        } else if (c == ' ') {
            result[i] = '-';
            i += 1;
        }
    }

    if (i == 0) {
        allocator.free(result);
        return try allocator.dupe(u8, "palette-theme");
    }

    return allocator.realloc(result, i);
}
