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
        const t = self.timer;

        if (t < c.INFO_DELAY) return;

        r.drawText("GALAGA", .{ .center_x = 4 }, Palette.cyan);

        if (t >= c.INFO_DELAY * 2.0) {
            r.drawText("--- SCORE ---", .{ .center_x = 6 }, Palette.cyan);
        }
        if (t >= c.INFO_DELAY * 3.0) {
            r.drawSprite(self.sprites.get(SpriteType.zako), .{ .cell = .{ .x = 11, .y = 8.5 } });
            r.drawText("50", .{ .cell = .{ .x = 16, .y = 8.5 } }, Palette.cyan);
            r.drawText("100", .{ .cell = .{ .x = 22, .y = 8.5 } }, Palette.cyan);
        }
        if (t >= c.INFO_DELAY * 4.0) {
            r.drawSprite(self.sprites.get(SpriteType.goei), .{ .cell = .{ .x = 11, .y = 8.5 } });
            r.drawText("80", .{ .cell = .{ .x = 16, .y = 10 } }, Palette.cyan);
            r.drawText("160", .{ .cell = .{ .x = 22, .y = 10 } }, Palette.cyan);
        }

        if (t >= c.INFO_DELAY * 5.0) {}
    }
};
