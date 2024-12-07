const std = @import("std");
const rl = @import("raylib.zig");
const gui = @import("gui/GuiElements.zig");

const DisplayError = error{
    FrameTooSmall,
};

const BaseFrameInfo = struct {
    const Self = @This();
    frame_width: i32 = 0,
    frame_height: i32 = 0,
    current_width: i32 = 0,
    current_height: i32 = 0,
    current_scale: f32 = 1,

    pub fn set_frame(self: *Self, width: i32, height: i32) !void {
        if (width < 12 or height < 12) {
            return DisplayError.FrameTooSmall;
        }

        self.frame_width = width;
        self.frame_height = height;
    }

    pub fn get_scaling_factor(self: *Self) f32 {
        const width = rl.GetScreenWidth();
        const height = rl.GetScreenHeight();

        if (width != self.current_width or height != self.current_height) {
            if (width > height) {
                std.debug.print("width: {d}, height: {d}, ", .{ width, height });
                std.debug.print("current width: {d}, current height: {d}\n", .{ self.frame_width, self.frame_height });
                self.current_scale = @as(f32, @floatFromInt(height)) / @as(f32, @floatFromInt(self.frame_height));
            }
        }
        return self.current_scale;
    }

    pub fn scale(self: *Self, input: anytype) c_int {
        if (@TypeOf(input) == c_int) {
            return @as(c_int, @intFromFloat(@as(f32, @floatFromInt(input)) * self.current_scale));
        } else {
            return @as(c_int, @intFromFloat(input * self.current_scale));
        }
    }

    pub fn scale_float(self: *Self, input: anytype) f32 {
        return @as(f32, @floatFromInt(input)) * self.current_scale;
    }
};

pub fn main() !void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const baseScreenWidth = 800;
    const baseScreenHeight = 450;

    var scaling = BaseFrameInfo{};
    try scaling.set_frame(baseScreenWidth, baseScreenHeight);

    rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE | rl.FLAG_VSYNC_HINT);
    rl.InitWindow(baseScreenWidth, baseScreenHeight, "raylib-zig [core] example - basic window");
    rl.SetWindowMinSize(320, 240);
    defer rl.CloseWindow(); // Close window and OpenGL context

    rl.SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    // var font_size: i64 = 10;

    while (!rl.WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------
        // Draw
        //----------------------------------------------------------------------------------
        rl.ClearBackground(rl.WHITE);

        // const c_font_size = @as(c_int, @intCast(@divFloor(font_size, 10) + 20));
        rl.BeginDrawing();
        const scale = scaling.get_scaling_factor();
        const text = rl.TextFormat("Scale: %f", scale);
        rl.DrawText(text, scaling.scale(150), scaling.scale(160), scaling.scale(20), rl.LIGHTGRAY);

        const c_greeting_text = "<!--Skri-A Kaark--> ///Accipiter Nova Zor Se";
        const text_dimension = rl.MeasureText(c_greeting_text, @as(c_int, 20));

        rl.DrawRectangle(scaling.scale(150), scaling.scale(200), scaling.scale(text_dimension), scaling.scale(20), rl.SKYBLUE);
        rl.DrawText(c_greeting_text, scaling.scale(150), scaling.scale(200), scaling.scale(20), rl.WHITE);

        const rec = rl.Rectangle{ .x = scaling.scale_float(150), .y = scaling.scale_float(240), .height = scaling.scale_float(32), .width = scaling.scale_float(128) };
        _ = gui.guiButton(rec, "Test");

        rl.EndDrawing();
    }
}
