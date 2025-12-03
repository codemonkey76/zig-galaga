const rl = @import("raylib");

pub const Palette = struct {
    pub const black = rl.Color{ .r = 0, .g = 0, .b = 0, .a = 255 };
    pub const white = rl.Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
    pub const yellow = rl.Color{ .r = 255, .g = 240, .b = 0, .a = 255 };
    pub const green = rl.Color{ .r = 0, .g = 255, .b = 0, .a = 255 };
    pub const cyan = rl.Color{ .r = 0, .g = 255, .b = 255, .a = 255 };
    pub const red = rl.Color{ .r = 255, .g = 0, .b = 0, .a = 255 };
    pub const letterbox = rl.Color{ .r = 50, .g = 55, .b = 55, .a = 255 };
    pub const grid = rl.Color{ .r = 80, .g = 80, .b = 80, .a = 255 };
};
