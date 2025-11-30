const Renderer = @import("../../renderer.zig").Renderer;
const Palette = @import("../../palette.zig").Palette;

const DELAY = 1.0;

pub const Info = struct {
    timer: f32,

    pub fn init() @This() {
        return .{
            .timer = 0,
        };
    }

    pub fn reset(self: *@This()) void {
        self.timer = 0;
    }

    pub fn update(self: *@This(), dt: f32) void {
        self.timer += dt;
    }

    pub fn draw(_: @This(), _: *Renderer) void {
        // const t = self.timer;

        // if (t < DELAY) {
        //     return;
        // }

        // r.drawCenteredText("GALAGA", 0, Palette.cyan);
        // r.drawCenteredText("GALAGA", 1, Palette.cyan);
        // r.drawCenteredText("GALAGA", 2, Palette.cyan);
        // r.drawCenteredText("GALAGA", 3, Palette.cyan);
        // r.drawCenteredText("GALAGA", 4, Palette.cyan);
        //
        // if (t >= DELAY * 2.0) {
        //     r.drawCenteredText("--- SCORE ---", 5, Palette.cyan);
        // }
    }
};
