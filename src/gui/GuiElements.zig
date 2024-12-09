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

pub fn guiToggle(bounds: rl.Rectangle, text: [*c]const u8, active: *bool) bool {

    // var for handling generic state
    var state = gui_state;

    // update control
    if (state != GuiState.START_DISABLED and !gui_locked) {
        const mouse_location = rl.GetMousePosition();

        // check if the mouse cursor locates at the component
        if (rl.CheckCollisionPointRec(mouse_location, bounds)) {
            if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT)) {
                // std.debug.print("Pressed, ", .{});
                state = GuiState.STATE_PRESSED;
            } else if (rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT)) {
                // std.debug.print("Flipped, ", .{});
                state = GuiState.STATE_NORMAL;
                active.* = !active.*;
            } else {
                // std.debug.print("Default, ", .{});
                state = GuiState.STATE_FOCUSED;
            }
        }
    }

    // render control
    if (state == GuiState.STATE_NORMAL) {
        // std.debug.print("NORMAL State, ", .{});
        const border_color = if (active.*) @intFromEnum(style.guiControlProperty.BORDER_COLOR_PRESSED) else (@intFromEnum(style.guiPropertyElement.BORDER) + @intFromEnum(state) * 3);
        const center_color = if (active.*) @intFromEnum(style.guiControlProperty.BASE_COLOR_PRESSED) else (@intFromEnum(style.guiPropertyElement.BASE) + @intFromEnum(state) * 3);
        const border_style = rl.Fade(rl.GetColor(style.guiGetStyle(@intFromEnum(style.guiControl.TOGGLE), border_color)), style.gui_alpha);
        const center_style = rl.Fade(rl.GetColor(style.guiGetStyle(@intFromEnum(style.guiControl.TOGGLE), center_color)), style.gui_alpha);
        guiDrawRectangle(bounds, @intCast(style.guiGetStyle(@as(u32, @intFromEnum(style.guiControl.TOGGLE)), @intFromEnum(style.guiControlProperty.BORDER_WIDTH))), border_style, center_style);
    } else {
        // std.debug.print("NON-NORMAL State, ", .{});
        const border_color = @intFromEnum(style.guiPropertyElement.BORDER) + @intFromEnum(state) * 3;
        const center_color = @intFromEnum(style.guiPropertyElement.BASE) + @intFromEnum(state) * 3;
        const border_style = rl.Fade(rl.GetColor(style.guiGetStyle(@intFromEnum(style.guiControl.TOGGLE), border_color)), style.gui_alpha);
        const center_style = rl.Fade(rl.GetColor(style.guiGetStyle(@intFromEnum(style.guiControl.TOGGLE), center_color)), style.gui_alpha);
        guiDrawRectangle(bounds, @intCast(style.guiGetStyle(@as(u32, @intFromEnum(style.guiControl.TOGGLE)), @intFromEnum(style.guiControlProperty.BORDER_WIDTH))), border_style, center_style);
    }

    // rl.DrawText(text, @as(c_int, @intFromFloat(bounds.x + (bounds.x / 16))), @as(c_int, @intFromFloat(bounds.y)), @as(c_int, @intFromFloat(bounds.height)) - 2, rl.WHITE);
    guiDrawText(text, bounds, style.guiTextAlignment.GUI_TEXT_ALIGN_CENTER, rl.WHITE);
    return active.*;
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

// let's have a look for text rendering, and I will based off GuiDrawText without the icon rendering
// The intention of this part is to understand how to render text in proper sizing and alignment.
pub fn guiDrawText(text: [*c]const u8, textBounds: rl.Rectangle, alignment: style.guiTextAlignment, tint: rl.Color) void {

    // the following code will not include icons from the raygui because that is not the purpose for this project

    // based on the comment in the source, seems the procedures process the text line by line, separated a new line character \n
    // After split the lines, the horizontal alignment manipulate each lines in horizontal position with handling word wrap,
    // and the vertical alignment affects the vertical location of the over text block.

    // According to the raylib, GuiTextSplit is static, and it has a static buffer, suggesting that we can't use it more than once
    // within the same frame for the same element because it might overwrites the previous split, causing some unknown behavior and bugs.
    // Thus, their solution was to explicitly declare another function to handle new line split.

    // however, this can be quite complicated at times, and since the main idea of this part is to understand
    // how sizing and alignment works rather than to build a one to one replication of the original function,
    // so I assume all my implementation are single lined to reduce the complexity of the text rendering process.

    // const total_height = @as(f32, @floatFromInt(style.guiGetStyle(@intFromEnum(style.guiControl.Default), @intFromEnum(style.guiDefaultProperty.TEXT_SIZE))));

    var text_bound_position: rl.Vector2 = .{ .x = textBounds.x, .y = textBounds.y };

    // The are difference between points and pixels, but I am yet to figure out how they are related;
    // perhaps I will have a look how the conversion works.
    const text_size_x = rl.MeasureText(text, @as(i32, @intFromFloat(textBounds.height / 3)));
    // const text_size_x = rl.MeasureText(text, 1); // it doesn't work because MeasureText require the minimum text

    // this handles all the alignment when the length of text is shorter than the given rectangle bound
    std.debug.print("x: {d}, width: {d}, text length: {d}\n", .{ textBounds.x, textBounds.width, text_size_x });
    text_bound_position.x = switch (alignment) {
        style.guiTextAlignment.GUI_TEXT_ALIGN_LEFT => textBounds.x,
        style.guiTextAlignment.GUI_TEXT_ALIGN_CENTER => textBounds.x + textBounds.width / 2 - @as(f32, @floatFromInt(text_size_x * 3)) / 2,
        style.guiTextAlignment.GUI_TEXT_ALIGN_RIGHT => textBounds.x + textBounds.width - @as(f32, @floatFromInt(text_size_x * 3)),
    };

    // if (@as(f32, @floatFromInt(text_size_x)) > textBounds.width) text_bound_position.x = textBounds.x;

    // text_bound_position.y = switch (alignment) {
    //     style.guiTextAlignment.GUI_TEXT_ALIGN_LEFT => textBounds.y,
    //     style.guiTextAlignment.GUI_TEXT_ALIGN_CENTER => textBounds.y + textBounds.height / 2 - total_height / 2,
    //     style.guiTextAlignment.GUI_TEXT_ALIGN_RIGHT => textBounds.y + textBounds.height - total_height,
    // };

    // They have cast the float into int than back to float; seems like they want to truncate all digits after the decimal point
    text_bound_position.x = @as(f32, @floatFromInt(@as(i32, @intFromFloat(text_bound_position.x))));
    text_bound_position.y = @as(f32, @floatFromInt(@as(i32, @intFromFloat(text_bound_position.y))));

    rl.DrawText(text, @as(c_int, @intFromFloat(text_bound_position.x)), @as(c_int, @intFromFloat(text_bound_position.y)), text_size_x, tint);
}
