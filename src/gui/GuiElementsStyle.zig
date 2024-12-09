const std = @import("std");
const rl = @import("../raylib.zig");

// enum are the same in the original C implementation
// which is not the key
pub const guiControl = enum(u32) {
    Default = 0,
    // Basic controls
    LABEL, // Used also for: LABELBUTTON
    BUTTON,
    TOGGLE, // Used also for: TOGGLEGROUP
    SLIDER, // Used also for: SLIDERBAR
    PROGRESSBAR,
    CHECKBOX,
    COMBOBOX,
    DROPDOWNBOX,
    TEXTBOX, // Used also for: TEXTBOXMULTI
    VALUEBOX,
    SPINNER, // Uses: BUTTON, VALUEBOX
    LISTVIEW,
    COLORPICKER,
    SCROLLBAR,
    STATUSBAR,
};

// Gui base properties for every control
// NOTE: RAYGUI_MAX_PROPS_BASE properties (by default 16 properties)
pub const guiControlProperty = enum(u32) {
    BORDER_COLOR_NORMAL = 0,
    BASE_COLOR_NORMAL,
    TEXT_COLOR_NORMAL,
    BORDER_COLOR_FOCUSED,
    BASE_COLOR_FOCUSED,
    TEXT_COLOR_FOCUSED,
    BORDER_COLOR_PRESSED,
    BASE_COLOR_PRESSED,

    TEXT_COLOR_PRESSED,
    BORDER_COLOR_DISABLED,
    BASE_COLOR_DISABLED,
    TEXT_COLOR_DISABLED,
    BORDER_WIDTH,
    TEXT_PADDING,
    TEXT_ALIGNMENT,
    RESERVED,
};

pub const guiDefaultProperty = enum(u32) {
    TEXT_SIZE = 16, // Text size (glyphs max height)
    TEXT_SPACING, // Text spacing between glyphs
    LINE_COLOR, // Line control color
    BACKGROUND_COLOR, // Background color
    TEXT_LINE_SPACING, // Text spacing between lines
    TEXT_ALIGNMENT_VERTICAL, // Text vertical alignment inside text bounds (after border and padding)
    TEXT_WRAP_MODE, // Text wrap-mode inside text bounds
    //TEXT_DECORATION             // Text decoration: 0-None, 1-Underline, 2-Line-through, 3-Overline
    //TEXT_DECORATION_THICK       // Text decoration line thickness
};

// text alignment
pub const guiTextAlignment = enum(u32) {
    GUI_TEXT_ALIGN_LEFT = 0,
    GUI_TEXT_ALIGN_CENTER,
    GUI_TEXT_ALIGN_RIGHT,
};

// text alignment
pub const guiTextAlignmentVertical = enum(u32) {
    GUI_TEXT_ALIGN_LEFT = 0,
    GUI_TEXT_ALIGN_CENTER,
    GUI_TEXT_ALIGN_RIGHT,
};

pub const guiPropertyElement = enum(u32) {
    BORDER = 0,
    BASE,
    TEXT,
    OTHER,
};

// general gui lkup:
pub var gui_style_loaded = false;
pub var gui_font: rl.Font = undefined;
pub const gui_alpha = 1.0;

// this is a lookup array for mapping the style of all elements, based on the number of controls.
// Each control has a based index for their default idle style; if the style altered, it adds an additional
// offset to the base to get other styles.
const RAY_MAX_CONTROLS = @typeInfo(guiControl).Enum.fields.len;
const RAY_MAX_PROPS_BASE = @typeInfo(guiControlProperty).Enum.fields.len;
const RAY_MAX_PROPS_EXTENDED = @typeInfo(guiDefaultProperty).Enum.fields.len;

const RAY_MAX_LKUP_SIZE = RAY_MAX_CONTROLS * (RAY_MAX_PROPS_BASE + RAY_MAX_PROPS_EXTENDED);
var gui_style_lkup: [RAY_MAX_LKUP_SIZE]u32 = std.mem.zeroes([RAY_MAX_LKUP_SIZE]u32);

pub fn guiGetStyle(control: u32, property: u32) u32 {
    if (!gui_style_loaded) {
        guiLoadStyleDefault();
    }

    return gui_style_lkup[control * (RAY_MAX_PROPS_BASE + RAY_MAX_PROPS_EXTENDED) + property];
}

pub fn guiLoadStyleDefault() void {

    // we set the following indicator to true so that it is trigger once only.
    gui_style_loaded = true;

    // Initialize default LIGHT style property values
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.BORDER_COLOR_NORMAL), 0x838383ff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.BASE_COLOR_NORMAL), 0xc9c9c9ff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.TEXT_COLOR_NORMAL), 0x686868ff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.BORDER_COLOR_FOCUSED), 0x5bb2d9ff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.BASE_COLOR_FOCUSED), 0xc9effeff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.TEXT_COLOR_FOCUSED), 0x6c9bbcff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.BORDER_COLOR_PRESSED), 0x0492c7ff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.BASE_COLOR_PRESSED), 0x97e8ffff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.TEXT_COLOR_PRESSED), 0x368bafff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.BORDER_COLOR_DISABLED), 0xb5c1c2ff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.BASE_COLOR_DISABLED), 0xe6e9e9ff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.TEXT_COLOR_DISABLED), 0xaeb7b8ff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.BORDER_WIDTH), 1);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.TEXT_PADDING), 0);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiControlProperty.TEXT_ALIGNMENT), @intFromEnum(guiTextAlignment.GUI_TEXT_ALIGN_CENTER));

    // Initialize control-specific property values
    // NOTE: Those properties are in default list but require specific values by control type
    guiSetStyle(@intFromEnum(guiControl.LABEL), @intFromEnum(guiControlProperty.TEXT_ALIGNMENT), @intFromEnum(guiTextAlignment.GUI_TEXT_ALIGN_LEFT));
    guiSetStyle(@intFromEnum(guiControl.BUTTON), @intFromEnum(guiControlProperty.BORDER_WIDTH), 2);
    guiSetStyle(@intFromEnum(guiControl.SLIDER), @intFromEnum(guiControlProperty.TEXT_PADDING), 4);
    guiSetStyle(@intFromEnum(guiControl.CHECKBOX), @intFromEnum(guiControlProperty.TEXT_PADDING), 4);
    guiSetStyle(@intFromEnum(guiControl.CHECKBOX), @intFromEnum(guiControlProperty.TEXT_ALIGNMENT), @intFromEnum(guiTextAlignment.GUI_TEXT_ALIGN_RIGHT));
    guiSetStyle(@intFromEnum(guiControl.TEXTBOX), @intFromEnum(guiControlProperty.TEXT_PADDING), 4);
    guiSetStyle(@intFromEnum(guiControl.TEXTBOX), @intFromEnum(guiControlProperty.TEXT_ALIGNMENT), @intFromEnum(guiTextAlignment.GUI_TEXT_ALIGN_LEFT));
    guiSetStyle(@intFromEnum(guiControl.VALUEBOX), @intFromEnum(guiControlProperty.TEXT_PADDING), 4);
    guiSetStyle(@intFromEnum(guiControl.VALUEBOX), @intFromEnum(guiControlProperty.TEXT_ALIGNMENT), @intFromEnum(guiTextAlignment.GUI_TEXT_ALIGN_LEFT));
    guiSetStyle(@intFromEnum(guiControl.SPINNER), @intFromEnum(guiControlProperty.TEXT_PADDING), 4);
    guiSetStyle(@intFromEnum(guiControl.SPINNER), @intFromEnum(guiControlProperty.TEXT_ALIGNMENT), @intFromEnum(guiTextAlignment.GUI_TEXT_ALIGN_LEFT));
    guiSetStyle(@intFromEnum(guiControl.STATUSBAR), @intFromEnum(guiControlProperty.TEXT_PADDING), 8);
    guiSetStyle(@intFromEnum(guiControl.STATUSBAR), @intFromEnum(guiControlProperty.TEXT_ALIGNMENT), @intFromEnum(guiTextAlignment.GUI_TEXT_ALIGN_LEFT));

    // Initialize extended property values
    // NOTE: By default, extended property values are initialized to 0
    // For now, let's only focus on any components that I have
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiDefaultProperty.TEXT_SIZE), 10);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiDefaultProperty.TEXT_SPACING), 1);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiDefaultProperty.LINE_COLOR), 0x90abb5ff);
    guiSetStyle(@intFromEnum(guiControl.Default), @intFromEnum(guiDefaultProperty.BACKGROUND_COLOR), 0xf5f5f5ff);

    gui_font = rl.GetFontDefault();
}

pub fn guiSetStyle(control: u32, property: u32, value: u32) void {

    // user can still override the original style of the element,
    // which can done before loading any gui elements that style is not available,
    // so we also need to preload the default style before setting a style.
    if (!gui_style_loaded) {
        guiLoadStyleDefault();
    }

    // this line overrides the specified control
    gui_style_lkup[control * (RAY_MAX_PROPS_BASE + RAY_MAX_PROPS_EXTENDED) + property] = value;

    // if we use the default element in enum, aka 0, it will overrides the all the style
    // based on the given property. Extended properties are not applies to all controls,
    // so the original raygui lib ignores it.
    if ((control == 0) and (property < RAY_MAX_PROPS_BASE)) {
        var i: u32 = 1;
        while (i < RAY_MAX_CONTROLS) : (i += 1) {
            gui_style_lkup[i * (RAY_MAX_PROPS_BASE + RAY_MAX_PROPS_EXTENDED) + property] = value;
        }
    }
}
