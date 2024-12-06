const std = @import("std");

// enum are the same in the original C implementation
// which is not the key
const guiControl = enum(u32) {
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
const guiControlProperty = enum(u32) {
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

// general gui lkup:
var gui_style_loaded = false;

// this is a lookup array for mapping the style of all elements, based on the number of controls.
// Each control has a based index for their default idle style; if the style altered, it adds an additional
// offset to the base to get other styles.
const RAY_MAX_CONTROLS = @typeInfo(guiControl);
const RAY_MAX_PROPS_BASE = 16;
const RAY_MAX_PROPS_EXTENDED = 8;

const RAY_MAX_LKUP_SIZE = RAY_MAX_CONTROLS * (RAY_MAX_PROPS_BASE + RAY_MAX_PROPS_EXTENDED);
const gui_style_lkup: [RAY_MAX_LKUP_SIZE]u32 = std.mem.zeroes([RAY_MAX_LKUP_SIZE]u32);



pub fn guiGetStyle(control: u32, property: u32){
    if(!gui_style_loaded){
        guiLoadStyleDefault();
    }
}

pub fn guiLoadStyleDefault() void {

    // we set the following indicator to true so that it is trigger once only. 
    gui_style_loaded = true;


}

pub fn guiSetStyle(control: u32, property: u32, value: u32) void {
    
    // user can still override the original style of the element,
    // which can done before loading any gui elements that style is not available,
    // so we also need to preload the default style before setting a style.
    if(!gui_style_loaded){
        guiLoadStyleDefault();
    }

    // this line overrides the specified control
    gui_style_lkup[control * (RAY_MAX_PROPS_BASE + RAY_MAX_PROPS_EXTENDED) + property] = value;

    // if we use the default element in enum, aka 0, it will overrides the all the style
    // based on the given property. Extended properties are not applies to all controls,
    // so the original raygui lib ignores it.
    if ((control == 0 ) and (property < RAY_MAX_PROPS_BASE)){
        var i: u32 = 1;
        while (i < RAY_MAX_CONTROLS): (i += 1){
            gui_style_lkup[i * (RAY_MAX_PROPS_BASE + RAY_MAX_PROPS_EXTENDED) + property] = value;
        }
    }
}