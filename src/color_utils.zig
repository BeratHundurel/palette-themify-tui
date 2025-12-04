const std = @import("std");
const types = @import("vscode_types.zig");

pub const RGB = types.RGB;
pub const HSL = types.HSL;
pub const PaletteQualityScore = types.PaletteQualityScore;
pub const HarmonyScheme = types.HarmonyScheme;
pub const ColorPair = types.ColorPair;

pub const BackgroundForegroundSelection = struct {
    background_index: usize,
    foreground_index: usize,
    remaining_indices: []usize,
};

inline fn parseHexToRgb(hex: []const u8) RGB {
    const r = std.fmt.parseInt(u8, hex[1..3], 16) catch 0;
    const g = std.fmt.parseInt(u8, hex[3..5], 16) catch 0;
    const b = std.fmt.parseInt(u8, hex[5..7], 16) catch 0;
    return RGB{ .r = r, .g = g, .b = b };
}

inline fn rgbDistanceFromRgb(rgb1: RGB, rgb2: RGB) f32 {
    const dr = @as(f32, @floatFromInt(@as(i32, rgb1.r) - @as(i32, rgb2.r)));
    const dg = @as(f32, @floatFromInt(@as(i32, rgb1.g) - @as(i32, rgb2.g)));
    const db = @as(f32, @floatFromInt(@as(i32, rgb1.b) - @as(i32, rgb2.b)));
    return @sqrt(dr * dr + dg * dg + db * db);
}

pub fn rgbDistance(hex_1: []const u8, hex_2: []const u8) f32 {
    const rgb1 = parseHexToRgb(hex_1);
    const rgb2 = parseHexToRgb(hex_2);
    return rgbDistanceFromRgb(rgb1, rgb2);
}

inline fn getLuminanceFromRgb(rgb: RGB) f32 {
    const rsRGB = @as(f32, @floatFromInt(rgb.r)) / 255.0;
    const gsRGB = @as(f32, @floatFromInt(rgb.g)) / 255.0;
    const bsRGB = @as(f32, @floatFromInt(rgb.b)) / 255.0;

    const rLinear = if (rsRGB <= 0.03928) rsRGB / 12.92 else std.math.pow(f32, (rsRGB + 0.055) / 1.055, 2.4);
    const gLinear = if (gsRGB <= 0.03928) gsRGB / 12.92 else std.math.pow(f32, (gsRGB + 0.055) / 1.055, 2.4);
    const bLinear = if (bsRGB <= 0.03928) bsRGB / 12.92 else std.math.pow(f32, (bsRGB + 0.055) / 1.055, 2.4);

    return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
}

pub fn getLuminance(hex: []const u8) f32 {
    const rgb = parseHexToRgb(hex);
    return getLuminanceFromRgb(rgb);
}

pub fn darkenColor(hex: []const u8, percent: f32) []const u8 {
    var r = std.fmt.parseInt(u8, hex[1..3], 16) catch 0;
    var g = std.fmt.parseInt(u8, hex[3..5], 16) catch 0;
    var b = std.fmt.parseInt(u8, hex[5..7], 16) catch 0;

    const factor = 1.0 - percent;
    r = @intFromFloat(@max(@as(f32, @floatFromInt(r)) * factor, 0.0));
    g = @intFromFloat(@max(@as(f32, @floatFromInt(g)) * factor, 0.0));
    b = @intFromFloat(@max(@as(f32, @floatFromInt(b)) * factor, 0.0));

    return std.fmt.allocPrint(std.heap.page_allocator, "#{X:0>2}{X:0>2}{X:0>2}", .{ r, g, b }) catch "#000000";
}

pub fn lightenColor(hex: []const u8, percent: f32) []const u8 {
    var r = std.fmt.parseInt(u8, hex[1..3], 16) catch 0;
    var g = std.fmt.parseInt(u8, hex[3..5], 16) catch 0;
    var b = std.fmt.parseInt(u8, hex[5..7], 16) catch 0;

    r = @intFromFloat(@min(@as(f32, @floatFromInt(r)) + (255.0 - @as(f32, @floatFromInt(r))) * percent, 255.0));
    g = @intFromFloat(@min(@as(f32, @floatFromInt(g)) + (255.0 - @as(f32, @floatFromInt(g))) * percent, 255.0));
    b = @intFromFloat(@min(@as(f32, @floatFromInt(b)) + (255.0 - @as(f32, @floatFromInt(b))) * percent, 255.0));

    return std.fmt.allocPrint(std.heap.page_allocator, "#{X:0>2}{X:0>2}{X:0>2}", .{ r, g, b }) catch "#FFFFFF";
}

pub fn addAlpha(hex: []const u8, alpha: []const u8) []const u8 {
    return std.fmt.allocPrint(std.heap.page_allocator, "{s}{s}", .{ hex, alpha }) catch "#00000000";
}

pub fn contrastRatio(hex1: []const u8, hex2: []const u8) f32 {
    const lum1 = getLuminance(hex1);
    const lum2 = getLuminance(hex2);

    const lighter = @max(lum1, lum2);
    const darker = @min(lum1, lum2);

    return (lighter + 0.05) / (darker + 0.05);
}

inline fn isDarkColorFromRgb(rgb: RGB) bool {
    const brightness = (@as(f32, @floatFromInt(rgb.r)) * 299.0 + @as(f32, @floatFromInt(rgb.g)) * 587.0 + @as(f32, @floatFromInt(rgb.b)) * 114.0) / 255000.0;
    return brightness < 0.5;
}

pub fn isDarkColor(hex: []const u8) bool {
    const rgb = parseHexToRgb(hex);
    return isDarkColorFromRgb(rgb);
}

pub fn adjustForContrast(fg: []const u8, bg: []const u8, min_contrast: f32) []const u8 {
    var color = fg;
    var iterations: u32 = 0;
    const dark_bg = isDarkColor(bg);

    // Tame overly bright/saturated colors
    const hsl = hexToHsl(color);
    if (dark_bg and hsl.s > 0.7 and hsl.l > 0.65) {
        const new_l = 0.55 + (hsl.l - 0.65) * 0.3;
        const new_s = @min(hsl.s, 0.75);
        const rgb = hslToRgb(hsl.h, new_s, new_l);
        color = rgbToHex(rgb.r, rgb.g, rgb.b);
    } else if (!dark_bg and hsl.s > 0.8 and hsl.l > 0.4 and hsl.l < 0.6) {
        const new_s = hsl.s * 0.7;
        const rgb = hslToRgb(hsl.h, new_s, hsl.l);
        color = rgbToHex(rgb.r, rgb.g, rgb.b);
    }

    // Then ensure minimum contrast
    while (contrastRatio(color, bg) < min_contrast and iterations < 20) : (iterations += 1) {
        color = if (dark_bg) lightenColor(color, 0.1) else darkenColor(color, 0.1);
    }

    return color;
}

pub fn ensureReadableContrast(proposed_color: []const u8, background: []const u8, min_contrast: f32) []const u8 {
    if (contrastRatio(proposed_color, background) >= min_contrast) {
        return proposed_color;
    }

    const adjusted = adjustForContrast(proposed_color, background, min_contrast);
    if (contrastRatio(adjusted, background) >= min_contrast) {
        return adjusted;
    }

    const dark_bg = isDarkColor(background);
    const bg_hsl = hexToHsl(background);
    const proposed_hsl = hexToHsl(proposed_color);

    const target_lightness: f32 = if (dark_bg) 0.85 else 0.15;
    const rgb = hslToRgb(proposed_hsl.h, @max(proposed_hsl.s * 0.7, 0.1), target_lightness);
    const tinted_fallback = rgbToHex(rgb.r, rgb.g, rgb.b);

    if (contrastRatio(tinted_fallback, background) >= min_contrast) {
        return tinted_fallback;
    }

    const neutral_lightness: f32 = if (dark_bg) 0.9 else 0.1;
    const neutral_rgb = hslToRgb(bg_hsl.h, 0.05, neutral_lightness);
    return rgbToHex(neutral_rgb.r, neutral_rgb.g, neutral_rgb.b);
}

pub fn hexToHsl(hex: []const u8) HSL {
    const rgb = parseHexToRgb(hex);
    const r = @as(f32, @floatFromInt(rgb.r)) / 255.0;
    const g = @as(f32, @floatFromInt(rgb.g)) / 255.0;
    const b = @as(f32, @floatFromInt(rgb.b)) / 255.0;

    const max_val = @max(@max(r, g), b);
    const min_val = @min(@min(r, g), b);
    const delta = max_val - min_val;

    var h: f32 = 0.0;
    var s: f32 = 0.0;
    const l: f32 = (max_val + min_val) / 2.0;

    if (delta != 0.0) {
        s = if (l > 0.5) delta / (2.0 - max_val - min_val) else delta / (max_val + min_val);

        if (max_val == r) {
            h = ((g - b) / delta + (if (g < b) @as(f32, 6.0) else @as(f32, 0.0))) / 6.0;
        } else if (max_val == g) {
            h = ((b - r) / delta + 2.0) / 6.0;
        } else {
            h = ((r - g) / delta + 4.0) / 6.0;
        }
    }

    return HSL{ .h = h, .s = s, .l = l };
}

fn hueToRgb(p: f32, q: f32, t_input: f32) f32 {
    var t = t_input;
    if (t < 0.0) t += 1.0;
    if (t > 1.0) t -= 1.0;
    if (t < 1.0 / 6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0 / 2.0) return q;
    if (t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
    return p;
}

pub fn hslToRgb(h: f32, s: f32, l: f32) RGB {
    var r: f32 = 0.0;
    var g: f32 = 0.0;
    var b: f32 = 0.0;

    if (s == 0.0) {
        r = l;
        g = l;
        b = l;
    } else {
        const q = if (l < 0.5) l * (1.0 + s) else l + s - l * s;
        const p = 2.0 * l - q;
        r = hueToRgb(p, q, h + 1.0 / 3.0);
        g = hueToRgb(p, q, h);
        b = hueToRgb(p, q, h - 1.0 / 3.0);
    }

    return RGB{
        .r = @as(u8, @intFromFloat(@round(r * 255.0))),
        .g = @as(u8, @intFromFloat(@round(g * 255.0))),
        .b = @as(u8, @intFromFloat(@round(b * 255.0))),
    };
}

pub fn rgbToHex(r: u8, g: u8, b: u8) []const u8 {
    return std.fmt.allocPrint(std.heap.page_allocator, "#{X:0>2}{X:0>2}{X:0>2}", .{ r, g, b }) catch "#000000";
}

pub fn calculatePaletteQuality(allocator: std.mem.Allocator, colors: []const []const u8) !PaletteQualityScore {
    if (colors.len < 2) {
        return PaletteQualityScore{
            .score = 100,
            .minDistance = 0.0,
            .avgDistance = 0.0,
            .poorPairs = &[_]ColorPair{},
            .isGoodQuality = true,
        };
    }

    var distances = std.ArrayList(f32){};
    defer distances.deinit(allocator);

    var poor_pairs = std.ArrayList(ColorPair){};
    defer poor_pairs.deinit(allocator);

    const POOR_THRESHOLD: f32 = 50.0;

    var i: usize = 0;
    while (i < colors.len) : (i += 1) {
        var j: usize = i + 1;
        while (j < colors.len) : (j += 1) {
            const dist = rgbDistance(colors[i], colors[j]);
            try distances.append(dist);

            if (dist < POOR_THRESHOLD) {
                try poor_pairs.append(ColorPair{
                    .color1 = colors[i],
                    .color2 = colors[j],
                    .distance = dist,
                });
            }
        }
    }

    var min_distance: f32 = std.math.floatMax(f32);
    var sum: f32 = 0.0;
    for (distances.items) |d| {
        if (d < min_distance) min_distance = d;
        sum += d;
    }

    const avg_distance = sum / @as(f32, @floatFromInt(distances.items.len));
    const score_float = @min(100.0, (min_distance / 100.0) * 50.0 + (avg_distance / 150.0) * 50.0);
    const score = @as(u32, @intFromFloat(@round(score_float)));

    std.mem.sort(ColorPair, poor_pairs.items, {}, struct {
        fn lessThan(_: void, a: ColorPair, b: ColorPair) bool {
            return a.distance < b.distance;
        }
    }.lessThan);

    const poor_pairs_owned = try allocator.dupe(ColorPair, poor_pairs.items);

    return PaletteQualityScore{
        .score = score,
        .minDistance = @round(min_distance),
        .avgDistance = @round(avg_distance),
        .poorPairs = poor_pairs_owned,
        .isGoodQuality = score >= 60 and min_distance >= 40.0,
    };
}

pub fn selectDiverseColors(allocator: std.mem.Allocator, colors: []const []const u8, count: usize) ![][]const u8 {
    var selected = std.ArrayList([]const u8){};
    defer selected.deinit(allocator);

    var used_indices = std.ArrayList(usize){};
    defer used_indices.deinit(allocator);

    const priority_count: usize = 5;
    const priority_threshold: f32 = 30.0;
    const normal_threshold: f32 = 50.0;

    for (0..@min(priority_count, colors.len)) |i| {
        const candidate = colors[i];

        var too_similar = false;
        for (selected.items) |s| {
            if (rgbDistance(candidate, s) < priority_threshold) {
                too_similar = true;
                break;
            }
        }

        if (!too_similar) {
            try selected.append(allocator, candidate);
            try used_indices.append(allocator, i);
        }
    }

    const remaining_needed = count -| selected.items.len;
    if (remaining_needed > 0) {
        var candidates_with_index = std.ArrayList(struct { index: usize, color: []const u8 }){};
        defer candidates_with_index.deinit(allocator);

        for (priority_count..colors.len) |i| {
            if (i < colors.len) {
                try candidates_with_index.append(allocator, .{ .index = i, .color = colors[i] });
            }
        }

        var added: usize = 0;
        var safety_counter: usize = 0;
        const max_iterations = remaining_needed * colors.len;

        while (added < remaining_needed and safety_counter < max_iterations) : (safety_counter += 1) {
            var max_min_distance: f32 = 0.0;
            var best_candidate_idx: ?usize = null;

            for (candidates_with_index.items, 0..) |entry, list_idx| {
                var already_used = false;
                for (used_indices.items) |used_idx| {
                    if (used_idx == entry.index) {
                        already_used = true;
                        break;
                    }
                }
                if (already_used) continue;

                var min_distance: f32 = std.math.floatMax(f32);
                for (selected.items) |s| {
                    const dist = rgbDistance(entry.color, s);
                    if (dist < min_distance) {
                        min_distance = dist;
                    }
                }

                if (min_distance >= normal_threshold and min_distance > max_min_distance) {
                    max_min_distance = min_distance;
                    best_candidate_idx = list_idx;
                }
            }

            if (best_candidate_idx) |list_idx| {
                const entry = candidates_with_index.items[list_idx];
                try selected.append(allocator, entry.color);
                try used_indices.append(allocator, entry.index);
                added += 1;
            } else {
                for (candidates_with_index.items, 0..) |entry, list_idx| {
                    var already_used = false;
                    for (used_indices.items) |used_idx| {
                        if (used_idx == entry.index) {
                            already_used = true;
                            break;
                        }
                    }
                    if (!already_used) {
                        var min_distance: f32 = std.math.floatMax(f32);
                        for (selected.items) |s| {
                            const dist = rgbDistance(entry.color, s);
                            if (dist < min_distance) {
                                min_distance = dist;
                            }
                        }
                        if (min_distance > max_min_distance) {
                            max_min_distance = min_distance;
                            best_candidate_idx = list_idx;
                        }
                    }
                }
                if (best_candidate_idx) |list_idx| {
                    const entry = candidates_with_index.items[list_idx];
                    try selected.append(allocator, entry.color);
                    try used_indices.append(allocator, entry.index);
                    added += 1;
                } else {
                    break;
                }
            }
        }
    }

    var result = std.ArrayList([]const u8){};
    defer result.deinit(allocator);

    for (used_indices.items) |idx| {
        try result.append(allocator, colors[idx]);
    }

    return try allocator.dupe([]const u8, result.items);
}

/// Enhance palette by adding harmony colors and selecting diverse subset
pub fn improvePaletteQuality(allocator: std.mem.Allocator, colors: []const []const u8, target_count: usize, harmony_scheme: HarmonyScheme) ![][]const u8 {
    if (colors.len >= target_count) {
        return try selectDiverseColors(allocator, colors, target_count);
    }

    var enhanced = std.ArrayList([]const u8){};
    defer enhanced.deinit(allocator);

    // Start with original colors
    for (colors) |color| {
        try enhanced.append(allocator, color);
    }

    // Generate harmony colors from original palette to fill gaps
    var i: usize = 0;
    while (enhanced.items.len < target_count and i < colors.len) : (i += 1) {
        const harmony_colors = try generateHarmonyColors(allocator, colors[i], harmony_scheme);
        defer allocator.free(harmony_colors);

        for (harmony_colors) |h_color| {
            if (enhanced.items.len >= target_count) break;

            // Check if color already exists
            var exists = false;
            for (enhanced.items) |existing| {
                if (std.mem.eql(u8, existing, h_color)) {
                    exists = true;
                    break;
                }
            }

            if (!exists) {
                try enhanced.append(allocator, h_color);
            }
        }
    }

    return try selectDiverseColors(allocator, enhanced.items, target_count);
}

pub fn generateHarmonyColors(allocator: std.mem.Allocator, base_color: []const u8, scheme: HarmonyScheme) ![][]const u8 {
    const hsl = hexToHsl(base_color);
    var colors = std.ArrayList([]const u8){};
    defer colors.deinit(allocator);

    try colors.append(allocator, base_color);

    switch (scheme) {
        .complementary => {
            const comp_h = @mod(hsl.h + 0.5, 1.0);
            const rgb = hslToRgb(comp_h, hsl.s, hsl.l);
            try colors.append(allocator, rgbToHex(rgb.r, rgb.g, rgb.b));
        },
        .triadic => {
            const offsets = [_]f32{ 1.0 / 3.0, 2.0 / 3.0 };
            for (offsets) |offset| {
                const h = @mod(hsl.h + offset, 1.0);
                const rgb = hslToRgb(h, hsl.s, hsl.l);
                try colors.append(allocator, rgbToHex(rgb.r, rgb.g, rgb.b));
            }
        },
        .analogous => {
            const offsets = [_]f32{ -1.0 / 12.0, 1.0 / 12.0 };
            for (offsets) |offset| {
                const h = @mod(hsl.h + offset + 1.0, 1.0);
                const rgb = hslToRgb(h, hsl.s, hsl.l);
                try colors.append(allocator, rgbToHex(rgb.r, rgb.g, rgb.b));
            }
        },
        .@"split-complementary" => {
            const comp_h = @mod(hsl.h + 0.5, 1.0);
            const offsets = [_]f32{ -1.0 / 12.0, 1.0 / 12.0 };
            for (offsets) |offset| {
                const h = @mod(comp_h + offset + 1.0, 1.0);
                const rgb = hslToRgb(h, hsl.s, hsl.l);
                try colors.append(allocator, rgbToHex(rgb.r, rgb.g, rgb.b));
            }
        },
    }

    return try allocator.dupe([]const u8, colors.items);
}

pub fn getHarmonicColor(base_color: []const u8, scheme: HarmonyScheme) []const u8 {
    const hsl = hexToHsl(base_color);

    const target_h: f32 = switch (scheme) {
        .complementary => @mod(hsl.h + 0.5, 1.0),
        .triadic => @mod(hsl.h + 1.0 / 3.0, 1.0),
        .analogous => @mod(hsl.h + 1.0 / 12.0 + 1.0, 1.0),
        .@"split-complementary" => @mod(hsl.h + 0.5 - 1.0 / 12.0 + 1.0, 1.0),
    };

    const rgb = hslToRgb(target_h, hsl.s, hsl.l);
    return rgbToHex(rgb.r, rgb.g, rgb.b);
}

fn calculateBackgroundScore(hex: []const u8, prefer_dark: bool) f32 {
    const hsl = hexToHsl(hex);
    const luminance = getLuminance(hex);

    const saturation_score = 1.0 - hsl.s;

    var luminance_score: f32 = 0.0;
    if (prefer_dark) {
        if (luminance < 0.15) {
            luminance_score = 1.0;
        } else if (luminance < 0.4) {
            luminance_score = 0.7 - (luminance - 0.15) * 2.0;
        } else {
            luminance_score = 0.2;
        }
    } else {
        if (luminance > 0.85) {
            luminance_score = 1.0;
        } else if (luminance > 0.6) {
            luminance_score = 0.7 + (luminance - 0.6) * 1.2;
        } else {
            luminance_score = 0.2;
        }
    }

    return saturation_score * 0.6 + luminance_score * 0.4;
}

pub fn selectBackgroundColor(colors: []const []const u8, prefer_dark: bool) usize {
    if (colors.len == 0) return 0;

    var best_index: usize = 0;
    var best_score: f32 = 0.0;

    for (colors, 0..) |color, i| {
        const score = calculateBackgroundScore(color, prefer_dark);
        if (score > best_score) {
            best_score = score;
            best_index = i;
        }
    }

    return best_index;
}

pub fn selectForegroundColor(colors: []const []const u8, background: []const u8, exclude_index: usize) usize {
    if (colors.len == 0) return 0;
    if (colors.len == 1) return 0;

    var best_index: usize = if (exclude_index == 0) 1 else 0;
    var best_contrast: f32 = 0.0;

    for (colors, 0..) |color, i| {
        if (i == exclude_index) continue;

        const contrast = contrastRatio(color, background);
        if (contrast > best_contrast) {
            best_contrast = contrast;
            best_index = i;
        }
    }

    return best_index;
}

pub fn selectBackgroundAndForeground(allocator: std.mem.Allocator, colors: []const []const u8, prefer_dark: bool) !BackgroundForegroundSelection {
    if (colors.len < 2) {
        return error.NotEnoughColors;
    }

    const bg_index = selectBackgroundColor(colors, prefer_dark);
    const fg_index = selectForegroundColor(colors, colors[bg_index], bg_index);

    var remaining = std.ArrayList(usize){};
    defer remaining.deinit(allocator);

    for (0..colors.len) |i| {
        if (i != bg_index and i != fg_index) {
            try remaining.append(allocator, i);
        }
    }

    const remaining_slice = try allocator.dupe(usize, remaining.items);

    return BackgroundForegroundSelection{
        .background_index = bg_index,
        .foreground_index = fg_index,
        .remaining_indices = remaining_slice,
    };
}
