const rl = @import("raylib");
const std = @import("std");

const c = @import("constants.zig");

pub const SpriteType = enum {
    player,
    zako,
    goei,
    boss,
    scorpion,
    bosconian,
    galaxian,
    dragonfly,
    satellite,
    starship,
};

pub const Sprite = struct {
    texture: rl.Texture2D,
    frames: [7]SpriteFrame,

    pub fn init(texture: rl.Texture2D, rects: [7]rl.Rectangle) @This() {
        var frames: [7]SpriteFrame = undefined;
        for (rects, 0..) |rect, i| {
            frames[i] = .{ .source = rect };
        }

        return .{
            .texture = texture,
            .frames = frames,
        };
    }

    pub fn getFrame(self: @This(), index: usize) SpriteFrame {
        return self.frames[index % 7];
    }

    pub fn getIdle(self: @This(), wing_open: bool) SpriteFrame {
        return if (wing_open) self.frames[5] else self.frames[6];
    }

    pub fn getRotated(self: @This(), rotation_step: usize) SpriteFrame {
        return self.frames[rotation_step % 5];
    }
};

pub const SpriteFrame = struct {
    source: rl.Rectangle,
};

pub const Sprites = struct {
    spritesheet: rl.Texture2D,
    sprites: std.EnumArray(SpriteType, Sprite),

    pub fn init() !@This() {
        const spritesheet = try rl.loadTexture(c.SPRITE_SHEET);
        std.debug.print("Loaded spritesheet: {}x{}\n", .{ spritesheet.width, spritesheet.height });

        var sprites = std.EnumArray(SpriteType, Sprite).initUndefined();

        sprites.set(
            .zako,
            Sprite.init(spritesheet, [_]rl.Rectangle{
                makeRect(3 + 16 * 1, 6 * 16 - 5, 16, 16),
                makeRect(5 + 16 * 2, 6 * 16 - 5, 16, 16),
                makeRect(7 + 16 * 3, 6 * 16 - 5, 16, 16),
                makeRect(9 + 16 * 4, 6 * 16 - 5, 16, 16),
                makeRect(11 + 16 * 5, 6 * 16 - 5, 16, 16),
                makeRect(13 + 16 * 6, 6 * 16 - 5, 16, 16),
                makeRect(15 + 16 * 7, 6 * 16 - 5, 16, 16),
            }),
        );

        return .{
            .spritesheet = spritesheet,
            .sprites = sprites,
        };
    }
    pub fn deinit(self: *const @This()) void {
        rl.unloadTexture(self.spritesheet);
    }

    pub fn get(self: *const @This(), sprite_type: SpriteType) Sprite {
        return self.sprites.get(sprite_type);
    }
};

fn makeRect(x: i32, y: i32, w: i32, h: i32) rl.Rectangle {
    return .{
        .x = @floatFromInt(x),
        .y = @floatFromInt(y),
        .width = @floatFromInt(w),
        .height = @floatFromInt(h),
    };
}
