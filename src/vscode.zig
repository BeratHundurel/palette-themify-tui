const std = @import("std");
const types = @import("vscode_types.zig");
const color_utils = @import("color_utils.zig");

// Re-export types for convenience
pub const VSCodeTheme = types.VSCodeTheme;
pub const VSCodeThemeColors = types.VSCodeThemeColors;
pub const VSCodeTokenColor = types.VSCodeTokenColor;
pub const VSCodeTokenSettings = types.VSCodeTokenSettings;
pub const ThemeType = types.ThemeType;
pub const HarmonyScheme = types.HarmonyScheme;
pub const RGB = types.RGB;
pub const HSL = types.HSL;
pub const ColorPair = types.ColorPair;
pub const PaletteQualityScore = types.PaletteQualityScore;

// Re-export color utility functions
pub const rgbDistance = color_utils.rgbDistance;
pub const getLuminance = color_utils.getLuminance;
pub const darkenColor = color_utils.darkenColor;
pub const lightenColor = color_utils.lightenColor;
pub const addAlpha = color_utils.addAlpha;
pub const contrastRatio = color_utils.contrastRatio;
pub const isDarkColor = color_utils.isDarkColor;
pub const adjustForContrast = color_utils.adjustForContrast;
pub const ensureReadableContrast = color_utils.ensureReadableContrast;
pub const hexToHsl = color_utils.hexToHsl;
pub const hslToRgb = color_utils.hslToRgb;
pub const rgbToHex = color_utils.rgbToHex;
pub const calculatePaletteQuality = color_utils.calculatePaletteQuality;
pub const selectDiverseColors = color_utils.selectDiverseColors;
pub const generateHarmonyColors = color_utils.generateHarmonyColors;
pub const improvePaletteQuality = color_utils.improvePaletteQuality;

// Generate a complete VSCode theme from a color palette
// Requires at least 8 colors, automatically enhances to 12 if needed
pub fn generateVSCodeTheme(
    allocator: std.mem.Allocator,
    colors: []const []const u8,
    harmony_scheme: HarmonyScheme,
) !VSCodeTheme {
    const improved_colors = try color_utils.improvePaletteQuality(allocator, colors, 12, harmony_scheme);

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
        sum_luminance += color_utils.getLuminance(color);
    }
    const average_luminance = sum_luminance / 8.0;
    const dark_base = average_luminance < 128.0;

    // Calculate background and foreground colors with high contrast
    const darken_amount = if (dark_base) 0.825 + (average_luminance / 255.0) * 0.2 else 0.0;
    const lighten_amount = if (dark_base) 0.0 else 0.7 + (1.0 - average_luminance / 255.0) * 0.25;
    const background = if (dark_base) color_utils.darkenColor(c0, darken_amount) else color_utils.lightenColor(c0, lighten_amount);

    const proposed_foreground = if (dark_base) color_utils.lightenColor(c0, 0.7) else color_utils.darkenColor(c0, 0.8);
    const foreground = color_utils.ensureReadableContrast(proposed_foreground, background, 7.0);

    // Adjust accent colors for readability (WCAG AA)
    var c1 = color_utils.adjustForContrast(c1_raw, background, 4.5, 10);
    var c2 = color_utils.adjustForContrast(c2_raw, background, 4.5, 10);

    // Ensure accent colors don't clash with foreground
    if (color_utils.rgbDistance(c1, foreground) < 60) {
        c1 = if (dark_base) color_utils.lightenColor(c1, 0.15) else color_utils.darkenColor(c1, 0.15);
    }
    if (color_utils.rgbDistance(c2, foreground) < 60) {
        c2 = if (dark_base) color_utils.lightenColor(c2, 0.15) else color_utils.darkenColor(c2, 0.15);
    }
    if (color_utils.rgbDistance(c1, c2) < 50) {
        c2 = if (dark_base) color_utils.lightenColor(c2, 0.15) else color_utils.darkenColor(c2, 0.15);
    }

    const c3 = color_utils.adjustForContrast(c3_raw, background, 3.5, 10);
    const c4 = color_utils.adjustForContrast(c4_raw, background, 3.5, 10);
    const c5 = color_utils.adjustForContrast(c5_raw, background, 3.5, 10);
    const c6 = color_utils.adjustForContrast(c6_raw, background, 3.5, 10);
    const c7 = color_utils.adjustForContrast(c7_raw, background, 3.5, 10);

    // Precompute background variations for different UI elements
    const bg_very_dark = if (dark_base) color_utils.darkenColor(c0, 0.95) else color_utils.lightenColor(c0, 0.95);
    const bg_dark = if (dark_base) color_utils.darkenColor(c0, 0.92) else color_utils.lightenColor(c0, 0.92);
    const bg_medium = if (dark_base) color_utils.darkenColor(c0, 0.9) else color_utils.lightenColor(c0, 0.9);
    const bg_light = if (dark_base) color_utils.darkenColor(c0, 0.88) else color_utils.lightenColor(c0, 0.88);
    const bg_lighter = if (dark_base) color_utils.darkenColor(c0, 0.85) else color_utils.lightenColor(c0, 0.85);
    const bg_inactive = if (dark_base) color_utils.darkenColor(c0, 0.97) else color_utils.lightenColor(c0, 0.97);
    const c3_dark = if (dark_base) color_utils.darkenColor(c3, 0.8) else color_utils.lightenColor(c3, 0.8);
    const c4_dark = if (dark_base) color_utils.darkenColor(c4, 0.8) else color_utils.lightenColor(c4, 0.8);
    const c5_dark = if (dark_base) color_utils.darkenColor(c5, 0.8) else color_utils.lightenColor(c5, 0.8);
    const c2_dark = if (dark_base) color_utils.darkenColor(c2, 0.8) else color_utils.lightenColor(c2, 0.8);
    const button_fg = if (dark_base) background else color_utils.darkenColor(c0, 0.9);

    // Precompute alpha-blended colors for overlays and subtle effects
    const fg60 = color_utils.addAlpha(foreground, "60");
    const fg70 = color_utils.addAlpha(foreground, "70");
    const fg50 = color_utils.addAlpha(foreground, "50");
    const fg30 = color_utils.addAlpha(foreground, "30");
    const fg99 = color_utils.addAlpha(foreground, "99");
    const c1_40 = color_utils.addAlpha(c1, "40");
    const c1_20 = color_utils.addAlpha(c1, "20");
    const c1_30 = color_utils.addAlpha(c1, "30");
    const c1_60 = color_utils.addAlpha(c1, "60");
    const c1_80 = color_utils.addAlpha(c1, "80");
    const c2_20 = color_utils.addAlpha(c2, "20");
    const c2_30 = color_utils.addAlpha(c2, "30");
    const c2_40 = color_utils.addAlpha(c2, "40");
    const c2_50 = color_utils.addAlpha(c2, "50");
    const c2_60 = color_utils.addAlpha(c2, "60");
    const c2_80 = color_utils.addAlpha(c2, "80");
    const c3_30 = color_utils.addAlpha(c3, "30");
    const c3_80 = color_utils.addAlpha(c3, "80");
    const c4_80 = color_utils.addAlpha(c4, "80");
    const c5_20 = color_utils.addAlpha(c5, "20");
    const c5_30 = color_utils.addAlpha(c5, "30");
    const c5_40 = color_utils.addAlpha(c5, "40");
    const c5_80 = color_utils.addAlpha(c5, "80");
    const c6_30 = color_utils.addAlpha(c6, "30");
    const c6_80 = color_utils.addAlpha(c6, "80");
    const c7_30 = color_utils.addAlpha(c7, "30");
    const c7_80 = color_utils.addAlpha(c7, "80");
    const fg_aa = color_utils.addAlpha(foreground, "aa");
    const fg_bracket_dark = color_utils.addAlpha(foreground, if (dark_base) "90" else "80");
    const fg_punct_dark = color_utils.addAlpha(foreground, if (dark_base) "70" else "60");

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
        .@"terminal.ansiBlack" = if (dark_base) color_utils.darkenColor(c0, 0.9) else color_utils.darkenColor(c0, 0.2),
        .@"terminal.ansiRed" = c4,
        .@"terminal.ansiGreen" = c3,
        .@"terminal.ansiYellow" = c5,
        .@"terminal.ansiBlue" = c2,
        .@"terminal.ansiMagenta" = c6,
        .@"terminal.ansiCyan" = c7,
        .@"terminal.ansiWhite" = foreground,
        .@"terminal.ansiBrightBlack" = if (dark_base) color_utils.darkenColor(foreground, 0.3) else color_utils.lightenColor(foreground, 0.3),
        .@"terminal.ansiBrightRed" = if (dark_base) color_utils.lightenColor(c4, 0.2) else color_utils.darkenColor(c4, 0.2),
        .@"terminal.ansiBrightGreen" = if (dark_base) color_utils.lightenColor(c3, 0.2) else color_utils.darkenColor(c3, 0.2),
        .@"terminal.ansiBrightYellow" = if (dark_base) color_utils.lightenColor(c5, 0.2) else color_utils.darkenColor(c5, 0.2),
        .@"terminal.ansiBrightBlue" = if (dark_base) color_utils.lightenColor(c2, 0.2) else color_utils.darkenColor(c2, 0.2),
        .@"terminal.ansiBrightMagenta" = if (dark_base) color_utils.lightenColor(c6, 0.2) else color_utils.darkenColor(c6, 0.2),
        .@"terminal.ansiBrightCyan" = if (dark_base) color_utils.lightenColor(c7, 0.2) else color_utils.darkenColor(c7, 0.2),
        .@"terminal.ansiBrightWhite" = if (dark_base) color_utils.lightenColor(foreground, 0.2) else color_utils.darkenColor(foreground, 0.2),
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
        .@"button.hoverBackground" = if (dark_base) color_utils.lightenColor(c2, 0.1) else color_utils.darkenColor(c2, 0.1),
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
            .settings = .{ .foreground = if (dark_base) color_utils.lightenColor(c6, 0.05) else color_utils.darkenColor(c6, 0.05) },
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
