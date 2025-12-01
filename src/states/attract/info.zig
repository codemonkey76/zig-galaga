const Renderer = @import("../../renderer.zig").Renderer;
const Palette = @import("../../palette.zig").Palette;
const Sprite = @import("../../sprites.zig").Sprite;
const Sprites = @import("../../sprites.zig").Sprites;
const SpriteType = @import("../../sprites.zig").SpriteType;
const c = @import("../../constants.zig");
const rl = @import("raylib");

const std = @import("std");

pub const Info = struct {
    timer: f32,
    sprites: Sprites,

    pub fn init(sprites: Sprites) @This() {
        return .{
            .timer = 0,
            .sprites = sprites,
        };
    }

    pub fn reset(self: *@This()) void {
        self.timer = 0;
    }

    pub fn update(self: *@This(), dt: f32) void {
        self.timer += dt;
    }

    pub fn draw(self: @This(), r: *Renderer) void {
        const zako = self.sprites.get(SpriteType.zako);

        r.drawSprite(zako, rl.Vector2{ .x = 1000, .y = 1000 });
        const t = self.timer;

        if (t < c.INFO_DELAY) return;

        r.drawText("GALAGA", .centered, 4, Palette.cyan);

        if (t >= c.INFO_DELAY * 2.0) {
            r.drawText("--- SCORE ---", .centered, 6, Palette.cyan);
            r.drawText("50", .{ .absolute = 16 }, 8, Palette.cyan);
            r.drawText("100", .{ .absolute = 22 }, 8, Palette.cyan);
            r.drawText("80", .{ .absolute = 16 }, 9, Palette.cyan);
            r.drawText("160", .{ .absolute = 22 }, 9, Palette.cyan);
        }
    }
};
