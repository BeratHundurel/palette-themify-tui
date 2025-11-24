const std = @import("std");

// HSL color space representation (normalized 0.0 to 1.0)
pub const HSL = struct {
    h: f32, // 0.0 to 1.0
    s: f32, // 0.0 to 1.0
    l: f32, // 0.0 to 1.0
};

pub const RGB = struct {
    r: u8,
    g: u8,
    b: u8,
};

// Represents a pair of colors with their perceptual distance
pub const ColorPair = struct {
    color1: []const u8,
    color2: []const u8,
    distance: f32,
};

// Overall quality assessment of a color palette
pub const PaletteQualityScore = struct {
    score: u32, // 0-100 quality score
    minDistance: f32, // Minimum distance between any two colors
    avgDistance: f32, // Average distance across all pairs
    poorPairs: []ColorPair, // Pairs with distance below threshold
    isGoodQuality: bool, // Quick check if palette meets quality standards
};

// Color harmony schemes based on color wheel relationships
pub const HarmonyScheme = enum {
    complementary,
    triadic,
    analogous,
    @"split-complementary",
};

// Token styling settings for syntax highlighting
pub const VSCodeTokenSettings = struct {
    foreground: ?[]const u8 = null,
    background: ?[]const u8 = null,
    fontStyle: ?[]const u8 = null,
};

pub const VSCodeTokenColor = struct {
    name: ?[]const u8 = null,
    scope: []const []const u8,
    settings: VSCodeTokenSettings,
};

pub const VSCodeThemeColors = struct {
    @"editor.background": []const u8,
    @"editor.foreground": []const u8,
    foreground: []const u8,
    disabledForeground: []const u8,
    focusBorder: []const u8,
    descriptionForeground: []const u8,
    errorForeground: []const u8,
    @"icon.foreground": []const u8,
    @"widget.border": []const u8,
    @"selection.background": []const u8,
    @"sash.hoverBorder": []const u8,
    @"activityBar.background": []const u8,
    @"activityBar.foreground": []const u8,
    @"activityBar.activeBorder": []const u8,
    @"activityBarBadge.background": []const u8,
    @"activityBarBadge.foreground": []const u8,
    @"sideBar.background": []const u8,
    @"sideBar.foreground": []const u8,
    @"sideBar.border": []const u8,
    @"sideBarTitle.foreground": []const u8,
    @"statusBar.background": []const u8,
    @"statusBar.foreground": []const u8,
    @"statusBar.noFolderBackground": []const u8,
    @"statusBar.debuggingBackground": []const u8,
    @"titleBar.activeBackground": []const u8,
    @"titleBar.activeForeground": []const u8,
    @"titleBar.inactiveBackground": []const u8,
    @"titleBar.inactiveForeground": []const u8,
    @"tab.activeBackground": []const u8,
    @"tab.activeForeground": []const u8,
    @"tab.inactiveBackground": []const u8,
    @"tab.inactiveForeground": []const u8,
    @"tab.activeBorder": []const u8,
    @"tab.border": []const u8,
    @"editorGroupHeader.tabsBackground": []const u8,
    @"panel.background": []const u8,
    @"panel.border": []const u8,
    @"panelTitle.activeBorder": []const u8,
    @"terminal.foreground": []const u8,
    @"terminal.ansiBlack": []const u8,
    @"terminal.ansiRed": []const u8,
    @"terminal.ansiGreen": []const u8,
    @"terminal.ansiYellow": []const u8,
    @"terminal.ansiBlue": []const u8,
    @"terminal.ansiMagenta": []const u8,
    @"terminal.ansiCyan": []const u8,
    @"terminal.ansiWhite": []const u8,
    @"terminal.ansiBrightBlack": []const u8,
    @"terminal.ansiBrightRed": []const u8,
    @"terminal.ansiBrightGreen": []const u8,
    @"terminal.ansiBrightYellow": []const u8,
    @"terminal.ansiBrightBlue": []const u8,
    @"terminal.ansiBrightMagenta": []const u8,
    @"terminal.ansiBrightCyan": []const u8,
    @"terminal.ansiBrightWhite": []const u8,
    @"input.background": []const u8,
    @"input.border": []const u8,
    @"input.foreground": []const u8,
    @"input.placeholderForeground": []const u8,
    @"inputOption.activeBorder": []const u8,
    @"inputOption.activeBackground": []const u8,
    @"inputOption.activeForeground": []const u8,
    @"inputValidation.errorBackground": []const u8,
    @"inputValidation.errorBorder": []const u8,
    @"inputValidation.errorForeground": []const u8,
    @"inputValidation.warningBackground": []const u8,
    @"inputValidation.warningBorder": []const u8,
    @"inputValidation.warningForeground": []const u8,
    @"inputValidation.infoBackground": []const u8,
    @"inputValidation.infoBorder": []const u8,
    @"inputValidation.infoForeground": []const u8,
    @"dropdown.background": []const u8,
    @"dropdown.foreground": []const u8,
    @"dropdown.border": []const u8,
    @"dropdown.listBackground": []const u8,
    @"quickInput.background": []const u8,
    @"quickInput.foreground": []const u8,
    @"quickInputList.focusBackground": []const u8,
    @"quickInputList.focusForeground": []const u8,
    @"quickInputList.focusIconForeground": []const u8,
    @"quickInputTitle.background": []const u8,
    @"list.activeSelectionBackground": []const u8,
    @"list.activeSelectionForeground": []const u8,
    @"list.inactiveSelectionBackground": []const u8,
    @"list.hoverBackground": []const u8,
    @"list.focusBackground": []const u8,
    @"button.background": []const u8,
    @"button.foreground": []const u8,
    @"button.hoverBackground": []const u8,
    @"button.secondaryBackground": []const u8,
    @"button.secondaryForeground": []const u8,
    @"button.secondaryHoverBackground": []const u8,
    @"badge.background": []const u8,
    @"badge.foreground": []const u8,
    @"breadcrumb.foreground": []const u8,
    @"breadcrumb.focusForeground": []const u8,
    @"breadcrumb.activeSelectionForeground": []const u8,
    @"breadcrumb.background": []const u8,
    @"scrollbarSlider.background": []const u8,
    @"scrollbarSlider.hoverBackground": []const u8,
    @"scrollbarSlider.activeBackground": []const u8,
    @"editorLineNumber.foreground": []const u8,
    @"editorLineNumber.activeForeground": []const u8,
    @"editorCursor.foreground": []const u8,
    @"editor.selectionBackground": []const u8,
    @"editor.inactiveSelectionBackground": []const u8,
    @"editor.findMatchBackground": []const u8,
    @"editor.findMatchHighlightBackground": []const u8,
    @"editorBracketMatch.background": []const u8,
    @"editorBracketMatch.border": []const u8,
    @"editorBracketHighlight.foreground1": []const u8,
    @"editorBracketHighlight.foreground2": []const u8,
    @"editorBracketHighlight.foreground3": []const u8,
    @"editorBracketHighlight.foreground4": []const u8,
    @"editorBracketHighlight.foreground5": []const u8,
    @"editorBracketHighlight.foreground6": []const u8,
    @"editorBracketPairGuide.activeBackground1": []const u8,
    @"editorBracketPairGuide.activeBackground2": []const u8,
    @"editorBracketPairGuide.activeBackground3": []const u8,
    @"editorBracketPairGuide.activeBackground4": []const u8,
    @"editorBracketPairGuide.activeBackground5": []const u8,
    @"editorBracketPairGuide.activeBackground6": []const u8,
    @"editorBracketPairGuide.background1": []const u8,
    @"editorBracketPairGuide.background2": []const u8,
    @"editorBracketPairGuide.background3": []const u8,
    @"editorBracketPairGuide.background4": []const u8,
    @"editorBracketPairGuide.background5": []const u8,
    @"editorBracketPairGuide.background6": []const u8,
    @"editorWhitespace.foreground": []const u8,
    @"editorWidget.background": []const u8,
    @"editorWidget.foreground": []const u8,
    @"editorWidget.border": []const u8,
    @"editorWidget.resizeBorder": []const u8,
    @"editorSuggestWidget.background": []const u8,
    @"editorSuggestWidget.foreground": []const u8,
    @"editorSuggestWidget.border": []const u8,
    @"editorSuggestWidget.highlightForeground": []const u8,
    @"editorSuggestWidget.focusHighlightForeground": []const u8,
    @"editorSuggestWidget.selectedBackground": []const u8,
    @"editorSuggestWidget.selectedForeground": []const u8,
    @"editorSuggestWidget.selectedIconForeground": []const u8,
    @"editorHoverWidget.background": []const u8,
    @"editorHoverWidget.foreground": []const u8,
    @"editorHoverWidget.border": []const u8,
    @"editorHoverWidget.highlightForeground": []const u8,
    @"editorHoverWidget.statusBarBackground": []const u8,
    @"editorError.foreground": []const u8,
    @"editorWarning.foreground": []const u8,
    @"editorInfo.foreground": []const u8,
    @"editorGutter.addedBackground": []const u8,
    @"editorGutter.modifiedBackground": []const u8,
    @"editorGutter.deletedBackground": []const u8,
    @"gitDecoration.addedResourceForeground": []const u8,
    @"gitDecoration.modifiedResourceForeground": []const u8,
    @"gitDecoration.deletedResourceForeground": []const u8,
    @"gitDecoration.untrackedResourceForeground": []const u8,
    @"gitDecoration.ignoredResourceForeground": []const u8,
    @"peekView.border": []const u8,
    @"peekViewEditor.background": []const u8,
    @"peekViewResult.background": []const u8,
    @"peekViewTitle.background": []const u8,
    @"notificationCenter.border": []const u8,
    @"notificationCenterHeader.background": []const u8,
    @"notifications.background": []const u8,
    @"notifications.border": []const u8,
    @"notificationLink.foreground": []const u8,
    @"settings.headerForeground": []const u8,
    @"settings.modifiedItemIndicator": []const u8,
    @"settings.focusedRowBackground": []const u8,
    @"settings.rowHoverBackground": []const u8,
    @"settings.focusedRowBorder": []const u8,
    @"settings.numberInputBackground": []const u8,
    @"settings.numberInputForeground": []const u8,
    @"settings.numberInputBorder": []const u8,
    @"settings.textInputBackground": []const u8,
    @"settings.textInputForeground": []const u8,
    @"settings.textInputBorder": []const u8,
    @"settings.checkboxBackground": []const u8,
    @"settings.checkboxForeground": []const u8,
    @"settings.checkboxBorder": []const u8,
    @"settings.dropdownBackground": []const u8,
    @"settings.dropdownForeground": []const u8,
    @"settings.dropdownBorder": []const u8,
    @"settings.dropdownListBorder": []const u8,
};

pub const ThemeType = enum {
    dark,
    light,
};

// Complete VSCode theme structure
pub const VSCodeTheme = struct {
    @"$schema": []const u8,
    name: []const u8,
    type: ThemeType,
    colors: VSCodeThemeColors,
    tokenColors: []const VSCodeTokenColor,
};

// Helper function to parse hex color string to RGB values
// This avoids repeated parsing when functions need RGB values multiple times
inline fn parseHexToRgb(hex: []const u8) RGB {
    const r = std.fmt.parseInt(u8, hex[1..3], 16) catch 0;
    const g = std.fmt.parseInt(u8, hex[3..5], 16) catch 0;
    const b = std.fmt.parseInt(u8, hex[5..7], 16) catch 0;
    return RGB{ .r = r, .g = g, .b = b };
}

// Calculate Euclidean distance between two RGB colors using RGB struct
inline fn rgbDistanceFromRgb(rgb1: RGB, rgb2: RGB) f32 {
    const dr = @as(f32, @floatFromInt(@as(i32, rgb1.r) - @as(i32, rgb2.r)));
    const dg = @as(f32, @floatFromInt(@as(i32, rgb1.g) - @as(i32, rgb2.g)));
    const db = @as(f32, @floatFromInt(@as(i32, rgb1.b) - @as(i32, rgb2.b)));
    return @sqrt(dr * dr + dg * dg + db * db);
}

// Calculate Euclidean distance between two RGB colors
pub fn rgbDistance(hex_1: []const u8, hex_2: []const u8) f32 {
    const rgb1 = parseHexToRgb(hex_1);
    const rgb2 = parseHexToRgb(hex_2);
    return rgbDistanceFromRgb(rgb1, rgb2);
}

// Calculate perceived brightness using sRGB gamma correction from RGB struct
inline fn getLuminanceFromRgb(rgb: RGB) f32 {
    // Convert to 0-1 range
    const rsRGB = @as(f32, @floatFromInt(rgb.r)) / 255.0;
    const gsRGB = @as(f32, @floatFromInt(rgb.g)) / 255.0;
    const bsRGB = @as(f32, @floatFromInt(rgb.b)) / 255.0;

    // Convert from sRGB to linear RGB (gamma correction)
    const rLinear = if (rsRGB <= 0.03928) rsRGB / 12.92 else std.math.pow(f32, (rsRGB + 0.055) / 1.055, 2.4);
    const gLinear = if (gsRGB <= 0.03928) gsRGB / 12.92 else std.math.pow(f32, (gsRGB + 0.055) / 1.055, 2.4);
    const bLinear = if (bsRGB <= 0.03928) bsRGB / 12.92 else std.math.pow(f32, (bsRGB + 0.055) / 1.055, 2.4);

    return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
}

// Calculate perceived brightness using sRGB gamma correction
pub fn getLuminance(hex: []const u8) f32 {
    const rgb = parseHexToRgb(hex);
    return getLuminanceFromRgb(rgb);
}

// Darken a color by the specified percent
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

// Lighten a color by the specified percent
pub fn lightenColor(hex: []const u8, percent: f32) []const u8 {
    var r = std.fmt.parseInt(u8, hex[1..3], 16) catch 0;
    var g = std.fmt.parseInt(u8, hex[3..5], 16) catch 0;
    var b = std.fmt.parseInt(u8, hex[5..7], 16) catch 0;

    r = @intFromFloat(@min(@as(f32, @floatFromInt(r)) + (255.0 - @as(f32, @floatFromInt(r))) * percent, 255.0));
    g = @intFromFloat(@min(@as(f32, @floatFromInt(g)) + (255.0 - @as(f32, @floatFromInt(g))) * percent, 255.0));
    b = @intFromFloat(@min(@as(f32, @floatFromInt(b)) + (255.0 - @as(f32, @floatFromInt(b))) * percent, 255.0));

    return std.fmt.allocPrint(std.heap.page_allocator, "#{X:0>2}{X:0>2}{X:0>2}", .{ r, g, b }) catch "#FFFFFF";
}

// Append alpha channel to a hex color
pub fn addAlpha(hex: []const u8, alpha: []const u8) []const u8 {
    return std.fmt.allocPrint(std.heap.page_allocator, "{s}{s}", .{ hex, alpha }) catch "#00000000";
}

// Calculate contrast ratio between two colors
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

// Iteratively adjust foreground color to meet desired contrast ratio with background
pub fn adjustForContrast(fg: []const u8, bg: []const u8, min_contrast: f32, max_iterations: u32) []const u8 {
    var color = fg;
    var iterations: u32 = 0;
    const dark_bg = isDarkColor(bg);

    while (contrastRatio(color, bg) < min_contrast and iterations < max_iterations) : (iterations += 1) {
        color = if (dark_bg) lightenColor(color, 0.1) else darkenColor(color, 0.1);
    }

    return color;
}

// Ensure text is readable with WCAG AA standard (4.5:1 contrast ratio)
pub fn ensureReadableContrast(proposed_color: []const u8, background: []const u8, min_contrast: f32) []const u8 {
    if (contrastRatio(proposed_color, background) >= min_contrast) {
        return proposed_color;
    }
    const black = "#000000";
    const white = "#ffffff";
    return if (contrastRatio(white, background) >= contrastRatio(black, background)) white else black;
}

// Convert hex color to HSL color space
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

        // Calculate hue based on which channel is max
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

// Helper function to convert hue component to RGB
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

// Analyze palette quality based on color distance and diversity
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

    // Calculate all pairwise distances
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
    // Score based on both minimum and average distance
    const score_float = @min(100.0, (min_distance / 100.0) * 50.0 + (avg_distance / 150.0) * 50.0);
    const score = @as(u32, @intFromFloat(@round(score_float)));

    // Sort poor pairs by distance (worst first)
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

// Select diverse colors using greedy maximin algorithm
// Picks colors that maximize minimum distance to already selected colors
pub fn selectDiverseColors(allocator: std.mem.Allocator, colors: []const []const u8, count: usize) ![][]const u8 {
    if (colors.len == 0) {
        return &[_][]const u8{};
    }

    if (colors.len <= count) {
        return try allocator.dupe([]const u8, colors);
    }

    var selected = std.ArrayList([]const u8){};
    defer selected.deinit(allocator);

    try selected.append(allocator, colors[0]);

    var safety_counter: usize = 0;
    const max_iterations = count * colors.len;

    // Iteratively select the color that maximizes distance to nearest selected color
    while (selected.items.len < count and safety_counter < max_iterations) : (safety_counter += 1) {
        var max_min_distance: f32 = 0.0;
        var best_candidate: ?[]const u8 = null;

        for (colors) |candidate| {
            var already_selected = false;
            for (selected.items) |s| {
                if (std.mem.eql(u8, s, candidate)) {
                    already_selected = true;
                    break;
                }
            }
            if (already_selected) continue;

            // Find minimum distance to any selected color
            var min_distance: f32 = std.math.floatMax(f32);
            for (selected.items) |s| {
                const dist = rgbDistance(candidate, s);
                if (dist < min_distance) {
                    min_distance = dist;
                }
            }

            if (min_distance > max_min_distance) {
                max_min_distance = min_distance;
                best_candidate = candidate;
            }
        }

        if (best_candidate) |candidate| {
            try selected.append(allocator, candidate);
        } else {
            break;
        }
    }

    return try allocator.dupe([]const u8, selected.items);
}

// Generate harmonious colors based on color theory
pub fn generateHarmonyColors(allocator: std.mem.Allocator, base_color: []const u8, scheme: HarmonyScheme) ![][]const u8 {
    const hsl = hexToHsl(base_color);
    var colors = std.ArrayList([]const u8){};
    defer colors.deinit(allocator);

    try colors.append(allocator, base_color);

    switch (scheme) {
        .complementary => {
            // Opposite color on the wheel (180°)
            const comp_h = @mod(hsl.h + 0.5, 1.0);
            const rgb = hslToRgb(comp_h, hsl.s, hsl.l);
            try colors.append(allocator, rgbToHex(rgb.r, rgb.g, rgb.b));
        },
        .triadic => {
            // Evenly spaced colors: 120° and 240° from base
            const offsets = [_]f32{ 1.0 / 3.0, 2.0 / 3.0 };
            for (offsets) |offset| {
                const h = @mod(hsl.h + offset, 1.0);
                const rgb = hslToRgb(h, hsl.s, hsl.l);
                try colors.append(allocator, rgbToHex(rgb.r, rgb.g, rgb.b));
            }
        },
        .analogous => {
            // Adjacent colors: ±30° from base
            const offsets = [_]f32{ -1.0 / 12.0, 1.0 / 12.0 };
            for (offsets) |offset| {
                const h = @mod(hsl.h + offset + 1.0, 1.0);
                const rgb = hslToRgb(h, hsl.s, hsl.l);
                try colors.append(allocator, rgbToHex(rgb.r, rgb.g, rgb.b));
            }
        },
        .@"split-complementary" => {
            // Two colors adjacent to the complement
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

// Enhance palette by adding harmony colors and selecting diverse subset
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

// Generate a complete VSCode theme from a color palette
// Requires at least 8 colors, automatically enhances to 12 if needed
pub fn generateVSCodeTheme(
    allocator: std.mem.Allocator,
    colors: []const []const u8,
    harmony_scheme: HarmonyScheme,
) !VSCodeTheme {
    const improved_colors = try improvePaletteQuality(allocator, colors, 12, harmony_scheme);

    if (improved_colors.len < 8) {
        return error.NotEnoughColors;
    }

    const c0 = improved_colors[0];
    const c1_raw = improved_colors[1];
    const c2_raw = improved_colors[2];
    const c3_raw = improved_colors[3];
    const c4_raw = improved_colors[4];
    const c5_raw = improved_colors[5];
    const c6_raw = improved_colors[6];
    const c7_raw = improved_colors[7];

    // Determine if theme should be dark or light based on average luminance
    var sum_luminance: f32 = 0.0;
    for (improved_colors[0..8]) |color| {
        sum_luminance += getLuminance(color);
    }
    const average_luminance = sum_luminance / 8.0;
    const dark_base = average_luminance < 128.0;

    // Calculate background and foreground colors with high contrast
    const darken_amount = if (dark_base) 0.825 + (average_luminance / 255.0) * 0.2 else 0.0;
    const lighten_amount = if (dark_base) 0.0 else 0.7 + (1.0 - average_luminance / 255.0) * 0.25;
    const background = if (dark_base) darkenColor(c0, darken_amount) else lightenColor(c0, lighten_amount);

    const proposed_foreground = if (dark_base) lightenColor(c0, 0.7) else darkenColor(c0, 0.8);
    const foreground = ensureReadableContrast(proposed_foreground, background, 7.0);

    // Adjust accent colors for readability (WCAG AA)
    var c1 = adjustForContrast(c1_raw, background, 4.5, 10);
    var c2 = adjustForContrast(c2_raw, background, 4.5, 10);

    // Ensure accent colors don't clash with foreground
    if (rgbDistance(c1, foreground) < 60) {
        c1 = if (dark_base) lightenColor(c1, 0.15) else darkenColor(c1, 0.15);
    }
    if (rgbDistance(c2, foreground) < 60) {
        c2 = if (dark_base) lightenColor(c2, 0.15) else darkenColor(c2, 0.15);
    }
    if (rgbDistance(c1, c2) < 50) {
        c2 = if (dark_base) lightenColor(c2, 0.15) else darkenColor(c2, 0.15);
    }

    const c3 = adjustForContrast(c3_raw, background, 3.5, 10);
    const c4 = adjustForContrast(c4_raw, background, 3.5, 10);
    const c5 = adjustForContrast(c5_raw, background, 3.5, 10);
    const c6 = adjustForContrast(c6_raw, background, 3.5, 10);
    const c7 = adjustForContrast(c7_raw, background, 3.5, 10);

    // Precompute background variations for different UI elements
    const bg_very_dark = if (dark_base) darkenColor(c0, 0.95) else lightenColor(c0, 0.95);
    const bg_dark = if (dark_base) darkenColor(c0, 0.92) else lightenColor(c0, 0.92);
    const bg_medium = if (dark_base) darkenColor(c0, 0.9) else lightenColor(c0, 0.9);
    const bg_light = if (dark_base) darkenColor(c0, 0.88) else lightenColor(c0, 0.88);
    const bg_lighter = if (dark_base) darkenColor(c0, 0.85) else lightenColor(c0, 0.85);
    const bg_inactive = if (dark_base) darkenColor(c0, 0.97) else lightenColor(c0, 0.97);
    const c3_dark = if (dark_base) darkenColor(c3, 0.8) else lightenColor(c3, 0.8);
    const c4_dark = if (dark_base) darkenColor(c4, 0.8) else lightenColor(c4, 0.8);
    const c5_dark = if (dark_base) darkenColor(c5, 0.8) else lightenColor(c5, 0.8);
    const c2_dark = if (dark_base) darkenColor(c2, 0.8) else lightenColor(c2, 0.8);
    const button_fg = if (dark_base) background else darkenColor(c0, 0.9);

    // Precompute alpha-blended colors for overlays and subtle effects
    const fg60 = addAlpha(foreground, "60");
    const fg70 = addAlpha(foreground, "70");
    const fg50 = addAlpha(foreground, "50");
    const fg30 = addAlpha(foreground, "30");
    const fg99 = addAlpha(foreground, "99");
    const c1_40 = addAlpha(c1, "40");
    const c1_20 = addAlpha(c1, "20");
    const c1_30 = addAlpha(c1, "30");
    const c1_60 = addAlpha(c1, "60");
    const c1_80 = addAlpha(c1, "80");
    const c2_20 = addAlpha(c2, "20");
    const c2_30 = addAlpha(c2, "30");
    const c2_40 = addAlpha(c2, "40");
    const c2_50 = addAlpha(c2, "50");
    const c2_60 = addAlpha(c2, "60");
    const c2_80 = addAlpha(c2, "80");
    const c3_30 = addAlpha(c3, "30");
    const c3_80 = addAlpha(c3, "80");
    const c4_80 = addAlpha(c4, "80");
    const c5_20 = addAlpha(c5, "20");
    const c5_30 = addAlpha(c5, "30");
    const c5_40 = addAlpha(c5, "40");
    const c5_80 = addAlpha(c5, "80");
    const c6_30 = addAlpha(c6, "30");
    const c6_80 = addAlpha(c6, "80");
    const c7_30 = addAlpha(c7, "30");
    const c7_80 = addAlpha(c7, "80");
    const fg_aa = addAlpha(foreground, "aa");
    const fg_bracket_dark = addAlpha(foreground, if (dark_base) "90" else "80");
    const fg_punct_dark = addAlpha(foreground, if (dark_base) "70" else "60");

    const theme_colors = VSCodeThemeColors{
        .@"editor.background" = background,
        .@"editor.foreground" = foreground,
        .foreground = foreground,
        .disabledForeground = fg60,
        .focusBorder = c2_60,
        .descriptionForeground = fg70,
        .errorForeground = c4,
        .@"icon.foreground" = c1,
        .@"widget.border" = c1_40,
        .@"selection.background" = c2_50,
        .@"sash.hoverBorder" = c2,
        .@"activityBar.background" = bg_very_dark,
        .@"activityBar.foreground" = c1,
        .@"activityBar.activeBorder" = c2,
        .@"activityBarBadge.background" = c2,
        .@"activityBarBadge.foreground" = foreground,
        .@"sideBar.background" = bg_dark,
        .@"sideBar.foreground" = foreground,
        .@"sideBar.border" = c1_20,
        .@"sideBarTitle.foreground" = c1,
        .@"statusBar.background" = bg_very_dark,
        .@"statusBar.foreground" = foreground,
        .@"statusBar.noFolderBackground" = c3_dark,
        .@"statusBar.debuggingBackground" = c4,
        .@"titleBar.activeBackground" = bg_very_dark,
        .@"titleBar.activeForeground" = foreground,
        .@"titleBar.inactiveBackground" = bg_inactive,
        .@"titleBar.inactiveForeground" = fg99,
        .@"tab.activeBackground" = background,
        .@"tab.activeForeground" = foreground,
        .@"tab.inactiveBackground" = bg_very_dark,
        .@"tab.inactiveForeground" = fg_aa,
        .@"tab.activeBorder" = c2,
        .@"tab.border" = c1_20,
        .@"editorGroupHeader.tabsBackground" = bg_very_dark,
        .@"panel.background" = background,
        .@"panel.border" = c1_40,
        .@"panelTitle.activeBorder" = c2,
        .@"terminal.foreground" = foreground,
        .@"terminal.ansiBlack" = if (dark_base) darkenColor(c0, 0.9) else darkenColor(c0, 0.2),
        .@"terminal.ansiRed" = c4,
        .@"terminal.ansiGreen" = c3,
        .@"terminal.ansiYellow" = c5,
        .@"terminal.ansiBlue" = c2,
        .@"terminal.ansiMagenta" = c6,
        .@"terminal.ansiCyan" = c7,
        .@"terminal.ansiWhite" = foreground,
        .@"terminal.ansiBrightBlack" = if (dark_base) darkenColor(foreground, 0.3) else lightenColor(foreground, 0.3),
        .@"terminal.ansiBrightRed" = if (dark_base) lightenColor(c4, 0.2) else darkenColor(c4, 0.2),
        .@"terminal.ansiBrightGreen" = if (dark_base) lightenColor(c3, 0.2) else darkenColor(c3, 0.2),
        .@"terminal.ansiBrightYellow" = if (dark_base) lightenColor(c5, 0.2) else darkenColor(c5, 0.2),
        .@"terminal.ansiBrightBlue" = if (dark_base) lightenColor(c2, 0.2) else darkenColor(c2, 0.2),
        .@"terminal.ansiBrightMagenta" = if (dark_base) lightenColor(c6, 0.2) else darkenColor(c6, 0.2),
        .@"terminal.ansiBrightCyan" = if (dark_base) lightenColor(c7, 0.2) else darkenColor(c7, 0.2),
        .@"terminal.ansiBrightWhite" = if (dark_base) lightenColor(foreground, 0.2) else darkenColor(foreground, 0.2),
        .@"input.background" = bg_lighter,
        .@"input.border" = c1_40,
        .@"input.foreground" = foreground,
        .@"input.placeholderForeground" = fg50,
        .@"inputOption.activeBorder" = c2,
        .@"inputOption.activeBackground" = c2_30,
        .@"inputOption.activeForeground" = foreground,
        .@"inputValidation.errorBackground" = c4_dark,
        .@"inputValidation.errorBorder" = c4,
        .@"inputValidation.errorForeground" = foreground,
        .@"inputValidation.warningBackground" = c5_dark,
        .@"inputValidation.warningBorder" = c5,
        .@"inputValidation.warningForeground" = foreground,
        .@"inputValidation.infoBackground" = c2_dark,
        .@"inputValidation.infoBorder" = c2,
        .@"inputValidation.infoForeground" = foreground,
        .@"dropdown.background" = bg_light,
        .@"dropdown.foreground" = foreground,
        .@"dropdown.border" = c1_40,
        .@"dropdown.listBackground" = bg_lighter,
        .@"quickInput.background" = bg_light,
        .@"quickInput.foreground" = foreground,
        .@"quickInputList.focusBackground" = c2_40,
        .@"quickInputList.focusForeground" = foreground,
        .@"quickInputList.focusIconForeground" = c2,
        .@"quickInputTitle.background" = bg_dark,
        .@"list.activeSelectionBackground" = c2_40,
        .@"list.activeSelectionForeground" = foreground,
        .@"list.inactiveSelectionBackground" = c1_30,
        .@"list.hoverBackground" = c1_20,
        .@"list.focusBackground" = c2_30,
        .@"button.background" = c2,
        .@"button.foreground" = button_fg,
        .@"button.hoverBackground" = if (dark_base) lightenColor(c2, 0.1) else darkenColor(c2, 0.1),
        .@"button.secondaryBackground" = bg_light,
        .@"button.secondaryForeground" = foreground,
        .@"button.secondaryHoverBackground" = bg_lighter,
        .@"badge.background" = c2,
        .@"badge.foreground" = button_fg,
        .@"breadcrumb.foreground" = fg70,
        .@"breadcrumb.focusForeground" = foreground,
        .@"breadcrumb.activeSelectionForeground" = c2,
        .@"breadcrumb.background" = background,
        .@"scrollbarSlider.background" = c1_40,
        .@"scrollbarSlider.hoverBackground" = c1_60,
        .@"scrollbarSlider.activeBackground" = c2_60,
        .@"editorLineNumber.foreground" = fg50,
        .@"editorLineNumber.activeForeground" = c2,
        .@"editorCursor.foreground" = c2,
        .@"editor.selectionBackground" = c2_40,
        .@"editor.inactiveSelectionBackground" = c1_30,
        .@"editor.findMatchBackground" = c5_40,
        .@"editor.findMatchHighlightBackground" = c5_20,
        .@"editorBracketMatch.background" = c2_20,
        .@"editorBracketMatch.border" = c2,
        .@"editorBracketHighlight.foreground1" = c2_80,
        .@"editorBracketHighlight.foreground2" = c3_80,
        .@"editorBracketHighlight.foreground3" = c5_80,
        .@"editorBracketHighlight.foreground4" = c6_80,
        .@"editorBracketHighlight.foreground5" = c7_80,
        .@"editorBracketHighlight.foreground6" = c1_80,
        .@"editorBracketPairGuide.activeBackground1" = c2,
        .@"editorBracketPairGuide.activeBackground2" = c3,
        .@"editorBracketPairGuide.activeBackground3" = c5,
        .@"editorBracketPairGuide.activeBackground4" = c6,
        .@"editorBracketPairGuide.activeBackground5" = c7,
        .@"editorBracketPairGuide.activeBackground6" = c1,
        .@"editorBracketPairGuide.background1" = c2_30,
        .@"editorBracketPairGuide.background2" = c3_30,
        .@"editorBracketPairGuide.background3" = c5_30,
        .@"editorBracketPairGuide.background4" = c6_30,
        .@"editorBracketPairGuide.background5" = c7_30,
        .@"editorBracketPairGuide.background6" = c1_30,
        .@"editorWhitespace.foreground" = fg30,
        .@"editorWidget.background" = bg_light,
        .@"editorWidget.foreground" = foreground,
        .@"editorWidget.border" = c1_40,
        .@"editorWidget.resizeBorder" = c2,
        .@"editorSuggestWidget.background" = bg_light,
        .@"editorSuggestWidget.foreground" = foreground,
        .@"editorSuggestWidget.border" = c1_40,
        .@"editorSuggestWidget.highlightForeground" = c2,
        .@"editorSuggestWidget.focusHighlightForeground" = c2,
        .@"editorSuggestWidget.selectedBackground" = c2_40,
        .@"editorSuggestWidget.selectedForeground" = foreground,
        .@"editorSuggestWidget.selectedIconForeground" = c2,
        .@"editorHoverWidget.background" = bg_light,
        .@"editorHoverWidget.foreground" = foreground,
        .@"editorHoverWidget.border" = c1_40,
        .@"editorHoverWidget.highlightForeground" = c2,
        .@"editorHoverWidget.statusBarBackground" = bg_dark,
        .@"editorError.foreground" = c4,
        .@"editorWarning.foreground" = c5,
        .@"editorInfo.foreground" = c2,
        .@"editorGutter.addedBackground" = c3,
        .@"editorGutter.modifiedBackground" = c5,
        .@"editorGutter.deletedBackground" = c4,
        .@"gitDecoration.addedResourceForeground" = c3,
        .@"gitDecoration.modifiedResourceForeground" = c5,
        .@"gitDecoration.deletedResourceForeground" = c4,
        .@"gitDecoration.untrackedResourceForeground" = c7,
        .@"gitDecoration.ignoredResourceForeground" = fg60,
        .@"peekView.border" = c2,
        .@"peekViewEditor.background" = bg_light,
        .@"peekViewResult.background" = bg_dark,
        .@"peekViewTitle.background" = bg_very_dark,
        .@"notificationCenter.border" = c1_40,
        .@"notificationCenterHeader.background" = bg_dark,
        .@"notifications.background" = bg_light,
        .@"notifications.border" = c1_40,
        .@"notificationLink.foreground" = c2,
        .@"settings.headerForeground" = foreground,
        .@"settings.modifiedItemIndicator" = c2,
        .@"settings.focusedRowBackground" = bg_medium,
        .@"settings.rowHoverBackground" = bg_dark,
        .@"settings.focusedRowBorder" = c2_60,
        .@"settings.numberInputBackground" = background,
        .@"settings.numberInputForeground" = c6,
        .@"settings.numberInputBorder" = c1_40,
        .@"settings.textInputBackground" = background,
        .@"settings.textInputForeground" = c2,
        .@"settings.textInputBorder" = c1_40,
        .@"settings.checkboxBackground" = background,
        .@"settings.checkboxForeground" = c5,
        .@"settings.checkboxBorder" = c1_40,
        .@"settings.dropdownBackground" = background,
        .@"settings.dropdownForeground" = c1,
        .@"settings.dropdownBorder" = c1_40,
        .@"settings.dropdownListBorder" = c1_40,
    };

    // Token colors array
    var token_colors = [_]VSCodeTokenColor{
        .{
            .name = "Comment",
            .scope = &[_][]const u8{ "comment", "punctuation.definition.comment" },
            .settings = .{ .foreground = fg60, .fontStyle = "italic" },
        },
        .{
            .name = "Keyword",
            .scope = &[_][]const u8{ "keyword", "keyword.control", "keyword.operator.new", "keyword.operator.expression", "keyword.other" },
            .settings = .{ .foreground = c6, .fontStyle = "bold" },
        },
        .{
            .name = "Storage",
            .scope = &[_][]const u8{ "storage", "storage.type", "storage.modifier", "entity.name.tag", "meta.tag" },
            .settings = .{ .foreground = c6 },
        },
        .{
            .name = "String",
            .scope = &[_][]const u8{ "string", "string.quoted", "string.template", "string.regexp", "punctuation.definition.string", "support.constant.property-value", "support.constant.property-value.css", "markup.inline.raw", "markup.fenced_code", "markup.inserted" },
            .settings = .{ .foreground = c3 },
        },
        .{
            .name = "Number",
            .scope = &[_][]const u8{ "constant.numeric", "constant.character", "number", "constant.other", "variable.other.constant", "support.constant", "entity.other.inherited-class", "support.class", "support.type" },
            .settings = .{ .foreground = c5 },
        },
        .{
            .name = "Built-in constant",
            .scope = &[_][]const u8{ "constant.language", "constant.language.boolean", "constant.language.null", "entity.name.class", "entity.name.type" },
            .settings = .{ .foreground = c5, .fontStyle = "bold" },
        },
        .{
            .name = "Variable",
            .scope = &[_][]const u8{ "variable", "identifier", "variable.other.readwrite", "meta.definition.variable" },
            .settings = .{ .foreground = foreground },
        },
        .{
            .name = "Property",
            .scope = &[_][]const u8{ "variable.other.property", "variable.other.object.property", "meta.object-literal.key", "support.variable", "support.other.variable", "support.type.property-name", "support.type.property-name.css" },
            .settings = .{ .foreground = c1 },
        },
        .{
            .name = "Function",
            .scope = &[_][]const u8{ "entity.name.function", "meta.function-call", "meta.method-call", "meta.method", "entity.other.attribute-name", "entity.name.module", "support.module", "support.function", "support.node" },
            .settings = .{ .foreground = c2 },
        },
        .{
            .name = "Parameter",
            .scope = &[_][]const u8{ "variable.parameter", "meta.parameter" },
            .settings = .{ .foreground = c7 },
        },
        .{
            .name = "Brackets",
            .scope = &[_][]const u8{ "punctuation.definition.begin.bracket", "punctuation.definition.end.bracket", "punctuation.definition.begin.bracket.round", "punctuation.definition.end.bracket.round", "punctuation.definition.begin.bracket.square", "punctuation.definition.end.bracket.square", "punctuation.definition.begin.bracket.curly", "punctuation.definition.end.bracket.curly", "meta.brace", "punctuation.section.brackets", "punctuation.section.parens", "punctuation.section.braces" },
            .settings = .{ .foreground = fg_bracket_dark },
        },
        .{
            .name = "Punctuation",
            .scope = &[_][]const u8{ "punctuation", "punctuation.terminator", "punctuation.separator", "punctuation.separator.comma", "punctuation.definition" },
            .settings = .{ .foreground = fg_punct_dark },
        },
        .{
            .name = "Operator",
            .scope = &[_][]const u8{ "keyword.operator", "punctuation.operator" },
            .settings = .{ .foreground = if (dark_base) lightenColor(c6, 0.05) else darkenColor(c6, 0.05) },
        },
        .{
            .name = "Heading",
            .scope = &[_][]const u8{ "markup.heading", "entity.name.section" },
            .settings = .{ .foreground = c2, .fontStyle = "bold" },
        },
        .{
            .name = "Italic",
            .scope = &[_][]const u8{"markup.italic"},
            .settings = .{ .fontStyle = "italic" },
        },
        .{
            .name = "Bold",
            .scope = &[_][]const u8{"markup.bold"},
            .settings = .{ .fontStyle = "bold" },
        },
        .{
            .name = "Link",
            .scope = &[_][]const u8{ "markup.underline.link", "string.other.link" },
            .settings = .{ .foreground = c2, .fontStyle = "underline" },
        },
        .{
            .name = "Deleted",
            .scope = &[_][]const u8{"markup.deleted"},
            .settings = .{ .foreground = c4 },
        },
        .{
            .name = "Invalid",
            .scope = &[_][]const u8{ "invalid", "invalid.illegal" },
            .settings = .{ .foreground = c4, .fontStyle = "bold" },
        },
        .{
            .name = "Deprecated",
            .scope = &[_][]const u8{"invalid.deprecated"},
            .settings = .{ .foreground = c4_80, .fontStyle = "italic" },
        },
    };

    const token_colors_slice = try allocator.dupe(VSCodeTokenColor, &token_colors);

    return VSCodeTheme{
        .@"$schema" = "vscode://schemas/color-theme",
        .name = "Custom Palette Theme",
        .type = if (dark_base) .dark else .light,
        .colors = theme_colors,
        .tokenColors = token_colors_slice,
    };
}

/// Install theme as a local VS Code extension
/// Creates the necessary directory structure and files in VS Code's local extensions folder
/// Returns the installation path
pub fn installThemeToVSCode(allocator: std.mem.Allocator, theme: VSCodeTheme, theme_name: []const u8) ![]const u8 {
    const home_dir = std.process.getEnvVarOwned(allocator, "USERPROFILE") catch |err| blk: {
        if (err == error.EnvironmentVariableNotFound) {
            break :blk std.process.getEnvVarOwned(allocator, "HOME") catch {
                return error.NoHomeDirectory;
            };
        }
        return err;
    };
    defer allocator.free(home_dir);

    // Construct the extensions path
    const extension_dir_path = try std.fs.path.join(allocator, &[_][]const u8{
        home_dir,
        ".vscode",
        "extensions",
        "palette-themify-local",
    });
    defer allocator.free(extension_dir_path);

    // Create the extension directory
    std.fs.cwd().makePath(extension_dir_path) catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };

    // Create themes subdirectory
    const themes_dir_path = try std.fs.path.join(allocator, &[_][]const u8{
        extension_dir_path,
        "themes",
    });
    defer allocator.free(themes_dir_path);

    std.fs.cwd().makePath(themes_dir_path) catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };

    // Generate theme filename (lowercase, replace spaces with dashes)
    var theme_filename = try allocator.alloc(u8, theme_name.len + 5);
    defer allocator.free(theme_filename);

    var idx: usize = 0;
    for (theme_name) |c| {
        if (c == ' ') {
            theme_filename[idx] = '-';
        } else if (c >= 'A' and c <= 'Z') {
            theme_filename[idx] = c + 32;
        } else {
            theme_filename[idx] = c;
        }
        idx += 1;
    }
    @memcpy(theme_filename[idx..][0..5], ".json");

    // Write theme JSON file
    const theme_file_path = try std.fs.path.join(allocator, &[_][]const u8{
        themes_dir_path,
        theme_filename,
    });
    defer allocator.free(theme_file_path);

    const theme_file = try std.fs.cwd().createFile(theme_file_path, .{});
    defer theme_file.close();

    const fmt = std.json.fmt(theme, .{ .whitespace = .indent_4, .emit_null_optional_fields = false });
    var json_writer = std.io.Writer.Allocating.init(allocator);
    defer json_writer.deinit();

    try fmt.format(&json_writer.writer);
    const json_string = try json_writer.toOwnedSlice();
    defer allocator.free(json_string);

    try theme_file.writeAll(json_string);

    // Create package.json
    const package_json_path = try std.fs.path.join(allocator, &[_][]const u8{
        extension_dir_path,
        "package.json",
    });
    defer allocator.free(package_json_path);

    const package_file = try std.fs.cwd().createFile(package_json_path, .{});
    defer package_file.close();

    // Determine UI theme type
    const ui_theme = if (theme.type == .dark) "vs-dark" else "vs";

    // Build package.json content
    const package_json = try std.fmt.allocPrint(allocator,
        \\{{
        \\  "name": "palette-themify-local",
        \\  "displayName": "Palette Themify",
        \\  "description": "Custom themes generated by Palette Themify",
        \\  "version": "0.0.1",
        \\  "publisher": "local",
        \\  "engines": {{
        \\    "vscode": "^1.70.0"
        \\  }},
        \\  "contributes": {{
        \\    "themes": [
        \\      {{
        \\        "label": "{s}",
        \\        "uiTheme": "{s}",
        \\        "path": "./themes/{s}"
        \\      }}
        \\    ]
        \\  }}
        \\}}
        \\
    , .{ theme_name, ui_theme, theme_filename });
    defer allocator.free(package_json);

    try package_file.writeAll(package_json);

    // Return the installation path for user feedback
    return try allocator.dupe(u8, extension_dir_path);
}
