const rl = @import("raylib");
const std = @import("std");

const c = @import("constants.zig");

pub const SpriteType = enum {
    player,
    boss,
    goei,
    zako,
    scorpion,
    midori,
    galaxian,
    tombow,
    momji,
    enterprise,
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
            .player,
            Sprite.init(spritesheet, [_]rl.Rectangle{
                makeRect(3 + 16 * 1, 1, 16, 16),
                makeRect(5 + 16 * 2, 1, 16, 16),
                makeRect(7 + 16 * 3, 1, 16, 16),
                makeRect(9 + 16 * 4, 1, 16, 16),
                makeRect(11 + 16 * 5, 1, 16, 16),
                makeRect(13 + 16 * 6, 1, 16, 16),
                makeRect(13 + 16 * 6, 1, 16, 16),
            }),
        );

        sprites.set(
            .boss,
            Sprite.init(spritesheet, [_]rl.Rectangle{
                makeRect(3 + 16 * 1, 2 * 16 + 5, 16, 16),
                makeRect(5 + 16 * 2, 2 * 16 + 5, 16, 16),
                makeRect(7 + 16 * 3, 2 * 16 + 5, 16, 16),
                makeRect(9 + 16 * 4, 2 * 16 + 5, 16, 16),
                makeRect(11 + 16 * 5, 2 * 16 + 5, 16, 16),
                makeRect(13 + 16 * 6, 2 * 16 + 5, 16, 16),
                makeRect(15 + 16 * 7, 2 * 16 + 5, 16, 16),
            }),
        );

        sprites.set(
            .goei,
            Sprite.init(spritesheet, [_]rl.Rectangle{
                makeRect(3 + 16 * 1, 4 * 16 + 9, 16, 16),
                makeRect(5 + 16 * 2, 4 * 16 + 9, 16, 16),
                makeRect(7 + 16 * 3, 4 * 16 + 9, 16, 16),
                makeRect(9 + 16 * 4, 4 * 16 + 9, 16, 16),
                makeRect(11 + 16 * 5, 4 * 16 + 9, 16, 16),
                makeRect(13 + 16 * 6, 4 * 16 + 9, 16, 16),
                makeRect(15 + 16 * 7, 4 * 16 + 9, 16, 16),
            }),
        );

        sprites.set(
            .zako,
            Sprite.init(spritesheet, [_]rl.Rectangle{
                makeRect(3 + 16 * 1, 5 * 16 + 11, 16, 16),
                makeRect(5 + 16 * 2, 5 * 16 + 11, 16, 16),
                makeRect(7 + 16 * 3, 5 * 16 + 11, 16, 16),
                makeRect(9 + 16 * 4, 5 * 16 + 11, 16, 16),
                makeRect(11 + 16 * 5, 5 * 16 + 11, 16, 16),
                makeRect(13 + 16 * 6, 5 * 16 + 11, 16, 16),
                makeRect(15 + 16 * 7, 5 * 16 + 11, 16, 16),
            }),
        );

        sprites.set(
            .scorpion,
            Sprite.init(spritesheet, [_]rl.Rectangle{
                makeRect(3 + 16 * 1, 6 * 16 + 13, 16, 16),
                makeRect(5 + 16 * 2, 6 * 16 + 13, 16, 16),
                makeRect(7 + 16 * 3, 6 * 16 + 13, 16, 16),
                makeRect(9 + 16 * 4, 6 * 16 + 13, 16, 16),
                makeRect(11 + 16 * 5, 6 * 16 + 13, 16, 16),
                makeRect(13 + 16 * 6, 6 * 16 + 13, 16, 16),
                makeRect(13 + 16 * 6, 6 * 16 + 13, 16, 16),
            }),
        );

        sprites.set(
            .midori,
            Sprite.init(spritesheet, [_]rl.Rectangle{
                makeRect(3 + 16 * 1, 7 * 16 + 15, 16, 16),
                makeRect(5 + 16 * 2, 7 * 16 + 15, 16, 16),
                makeRect(7 + 16 * 3, 7 * 16 + 15, 16, 16),
                makeRect(9 + 16 * 4, 7 * 16 + 15, 16, 16),
                makeRect(11 + 16 * 5, 7 * 16 + 15, 16, 16),
                makeRect(13 + 16 * 6, 7 * 16 + 15, 16, 16),
                makeRect(13 + 16 * 6, 7 * 16 + 15, 16, 16),
            }),
        );

        sprites.set(
            .galaxian,
            Sprite.init(spritesheet, [_]rl.Rectangle{
                makeRect(3 + 16 * 1, 8 * 16 + 17, 16, 16),
                makeRect(5 + 16 * 2, 8 * 16 + 17, 16, 16),
                makeRect(7 + 16 * 3, 8 * 16 + 17, 16, 16),
                makeRect(9 + 16 * 4, 8 * 16 + 17, 16, 16),
                makeRect(11 + 16 * 5, 8 * 16 + 17, 16, 16),
                makeRect(13 + 16 * 6, 8 * 16 + 17, 16, 16),
                makeRect(13 + 16 * 6, 8 * 16 + 17, 16, 16),
            }),
        );

        sprites.set(
            .tombow,
            Sprite.init(spritesheet, [_]rl.Rectangle{
                makeRect(3 + 16 * 1, 9 * 16 + 19, 16, 16),
                makeRect(5 + 16 * 2, 9 * 16 + 19, 16, 16),
                makeRect(7 + 16 * 3, 9 * 16 + 19, 16, 16),
                makeRect(9 + 16 * 4, 9 * 16 + 19, 16, 16),
                makeRect(11 + 16 * 5, 9 * 16 + 19, 16, 16),
                makeRect(13 + 16 * 6, 9 * 16 + 19, 16, 16),
                makeRect(13 + 16 * 6, 9 * 16 + 19, 16, 16),
            }),
        );
        sprites.set(
            .momji,
            Sprite.init(spritesheet, [_]rl.Rectangle{
                makeRect(3 + 16 * 1, 10 * 16 + 21, 16, 16),
                makeRect(5 + 16 * 2, 10 * 16 + 21, 16, 16),
                makeRect(7 + 16 * 3, 10 * 16 + 21, 16, 16),
                makeRect(9 + 16 * 4, 10 * 16 + 21, 16, 16),
                makeRect(11 + 16 * 5, 10 * 16 + 21, 16, 16),
                makeRect(13 + 16 * 6, 10 * 16 + 21, 16, 16),
                makeRect(13 + 16 * 6, 10 * 16 + 21, 16, 16),
            }),
        );
        sprites.set(
            .enterprise,
            Sprite.init(spritesheet, [_]rl.Rectangle{
                makeRect(3 + 16 * 1, 11 * 16 + 23, 16, 16),
                makeRect(5 + 16 * 2, 11 * 16 + 23, 16, 16),
                makeRect(7 + 16 * 3, 11 * 16 + 23, 16, 16),
                makeRect(9 + 16 * 4, 11 * 16 + 23, 16, 16),
                makeRect(11 + 16 * 5, 11 * 16 + 23, 16, 16),
                makeRect(13 + 16 * 6, 11 * 16 + 23, 16, 16),
                makeRect(13 + 16 * 6, 11 * 16 + 23, 16, 16),
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
