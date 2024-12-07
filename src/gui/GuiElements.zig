const rl = @import("../raylib.zig");
const style = @import("GuiElementsStyle.zig");
const std = @import("std");

// with the enum defined with a type,
// each enum will have an additional integer representation.
// use @intFromEnum to use the integers stored in the enum
const GuiState = enum(u32) {
    STATE_NORMAL = 0,
    STATE_FOCUSED,
    STATE_PRESSED,
    START_DISABLED,
};

// these controls are used for globally controls all elements
var gui_state = GuiState.STATE_NORMAL;
var gui_locked = false;
var RAYGUI_ICON_TEXT_PADDING: i32 = undefined;

pub fn guiButton(bounds: rl.Rectangle, text: [*c]const u8) bool {

    // update control
    var state = gui_state;
    var pressed = false;

    // check if all gui elements are globally disabled,
    // useful for loading screen, preventing users to accidentally click the buttons
    if (state != GuiState.START_DISABLED and !gui_locked) {

        // if it is not globally disabled, check the mouse pointer location and specified region,
        // only elements within the cursor counts
        const mouse_location = rl.GetMousePosition();

        if (rl.CheckCollisionPointRec(mouse_location, bounds)) {
            // check each mouse state
            if (rl.IsMouseButtonDown(rl.MOUSE_LEFT_BUTTON)) {
                state = GuiState.STATE_PRESSED;
            } else {
                state = GuiState.STATE_FOCUSED;
            }

            if (rl.IsMouseButtonPressed(rl.MOUSE_LEFT_BUTTON)) {
                pressed = true;
            }
        }

        // draw control
        const border_width_style = rl.Fade(rl.GetColor(style.guiGetStyle(@intFromEnum(style.guiControl.BUTTON), @intFromEnum(style.guiPropertyElement.BORDER) + (@intFromEnum(state) * 3))), style.gui_alpha);
        const border_center_style = rl.Fade(rl.GetColor(style.guiGetStyle(@intFromEnum(style.guiControl.BUTTON), @intFromEnum(style.guiPropertyElement.BASE) + (@intFromEnum(state) * 3))), style.gui_alpha);
        guiDrawRectangle(bounds, @intCast(style.guiGetStyle(@as(u32, @intFromEnum(style.guiControl.BUTTON)), @intFromEnum(style.guiControlProperty.BORDER_WIDTH))), border_width_style, border_center_style);

        rl.DrawText(text, @as(c_int, @intFromFloat(bounds.x + (bounds.x / 16))), @as(c_int, @intFromFloat(bounds.y)), @as(c_int, @intFromFloat(bounds.height)) - 2, rl.WHITE);
    }
    return pressed;
}

/// based on the source code of raygui, seems a bordered rectangle is actually made of 4 rectangles:
/// The centre rectangle and the four rectangles for each sides of the centre on as the borders
pub fn guiDrawRectangle(rec: rl.Rectangle, border_width: i32, border_color: rl.Color, color: rl.Color) void {

    // as long as alpha (transparency) is not transparent,
    // draw a rectangle with the specified color
    if (color.a > 0) {
        rl.DrawRectangle(@as(c_int, @intFromFloat(rec.x)), @as(c_int, @intFromFloat(rec.y)), @as(c_int, @intFromFloat(rec.width)), @as(c_int, @intFromFloat(rec.height)), color);
    }

    // only render the border if the width is not zero
    if (border_width > 0) {
        rl.DrawRectangle(@as(c_int, @intFromFloat(rec.x)), @as(c_int, @intFromFloat(rec.y)), @as(c_int, @intFromFloat(rec.width)), @as(c_int, border_width), border_color);
        rl.DrawRectangle(@as(c_int, @intFromFloat(rec.x)), @as(c_int, @as(i32, @intFromFloat(rec.y)) + border_width), @as(c_int, border_width), @as(c_int, @as(i32, @intFromFloat(rec.height)) - 2 * border_width), border_color);
        rl.DrawRectangle(@as(c_int, @as(i32, @intFromFloat(rec.x + rec.width))) - border_width, @as(c_int, @as(i32, @intFromFloat(rec.y)) + border_width), @as(c_int, border_width), @as(c_int, @as(i32, @intFromFloat(rec.height)) - 2 * border_width), border_color);
        rl.DrawRectangle(@as(c_int, @intFromFloat(rec.x)), @as(c_int, @as(i32, @intFromFloat(rec.y + rec.height)) - border_width), @as(c_int, @intFromFloat(rec.width)), @as(c_int, border_width), border_color);
    }
}
