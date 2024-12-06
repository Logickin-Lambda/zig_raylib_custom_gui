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

pub fn guiButton(bounds: rl.Rectangle, text: []const u8) bool {

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

    }
}

/// based on the source code of raygui, seems a bordered rectangle is actually made of 4 rectangles:
/// The centre rectangle and the four rectangles for each sides of the centre on as the borders
pub fn guiDrawRectangle(rec: rl.Rectangle, len_width: i32, border_color: rl.Color, color: rl.Color) void {}
