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
    idle: []const SpriteFrame,
    rotation: []const SpriteFrame,
    allocator: std.mem.Allocator,

    pub fn init(
        allocator: std.mem.Allocator,
        texture: rl.Texture2D,
        idle: []const rl.Rectangle,
        rotation: []const rl.Rectangle,
    ) !@This() {
        var idle_frames = try allocator.alloc(SpriteFrame, idle.len);

        for (idle, 0..) |rect, i| {
            idle_frames[i] = .{ .source = rect };
        }

        var rotation_frames = try allocator.alloc(SpriteFrame, rotation.len);

        for (rotation, 0..) |rect, i| {
            rotation_frames[i] = .{ .source = rect };
        }

        return .{
            .texture = texture,
            .idle = idle_frames,
            .rotation = rotation_frames,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.allocator.free(self.idle);
        self.allocator.free(self.rotation);
    }

    pub fn getFrame(self: @This(), index: usize) SpriteFrame {
        return self.frames[index % 7];
    }

    pub fn getIdle(self: @This(), frame_index: usize) SpriteFrame {
        return self.idle[frame_index % self.idle.len];
    }

    pub fn getRotated(self: @This(), rotation_step: usize) SpriteFrame {
        return self.rotation[rotation_step % 5];
    }
};

pub const SpriteFrame = struct {
    source: rl.Rectangle,
};

pub const Sprites = struct {
    spritesheet: rl.Texture2D,
    sprites: std.EnumArray(SpriteType, Sprite),

    pub fn init(allocator: std.mem.Allocator) !@This() {
        const spritesheet = try rl.loadTexture(c.SPRITE_SHEET);
        std.debug.print("Loaded spritesheet: {}x{}\n", .{ spritesheet.width, spritesheet.height });

        var sprites = std.EnumArray(SpriteType, Sprite).initUndefined();

        sprites.set(
            .player,
            try Sprite.init(
                allocator,
                spritesheet,
                &[_]rl.Rectangle{
                    makeRect(13 + 16 * 6, 1, 16, 16),
                },
                &[_]rl.Rectangle{
                    makeRect(3 + 16 * 1, 1, 16, 16),
                    makeRect(5 + 16 * 2, 1, 16, 16),
                    makeRect(7 + 16 * 3, 1, 16, 16),
                    makeRect(9 + 16 * 4, 1, 16, 16),
                    makeRect(11 + 16 * 5, 1, 16, 16),
                },
            ),
        );

        sprites.set(
            .boss,
            try Sprite.init(
                allocator,
                spritesheet,
                &[_]rl.Rectangle{
                    makeRect(13 + 16 * 6, 2 * 16 + 5, 16, 16),
                    makeRect(15 + 16 * 7, 2 * 16 + 5, 16, 16),
                },
                &[_]rl.Rectangle{
                    makeRect(3 + 16 * 1, 2 * 16 + 5, 16, 16),
                    makeRect(5 + 16 * 2, 2 * 16 + 5, 16, 16),
                    makeRect(7 + 16 * 3, 2 * 16 + 5, 16, 16),
                    makeRect(9 + 16 * 4, 2 * 16 + 5, 16, 16),
                    makeRect(11 + 16 * 5, 2 * 16 + 5, 16, 16),
                },
            ),
        );

        sprites.set(
            .goei,
            try Sprite.init(
                allocator,
                spritesheet,
                &[_]rl.Rectangle{
                    makeRect(13 + 16 * 6, 4 * 16 + 9, 16, 16),
                    makeRect(15 + 16 * 7, 4 * 16 + 9, 16, 16),
                },
                &[_]rl.Rectangle{
                    makeRect(3 + 16 * 1, 4 * 16 + 9, 16, 16),
                    makeRect(5 + 16 * 2, 4 * 16 + 9, 16, 16),
                    makeRect(7 + 16 * 3, 4 * 16 + 9, 16, 16),
                    makeRect(9 + 16 * 4, 4 * 16 + 9, 16, 16),
                    makeRect(11 + 16 * 5, 4 * 16 + 9, 16, 16),
                },
            ),
        );

        sprites.set(
            .zako,
            try Sprite.init(
                allocator,
                spritesheet,
                &[_]rl.Rectangle{
                    makeRect(13 + 16 * 6, 5 * 16 + 11, 16, 16),
                    makeRect(15 + 16 * 7, 5 * 16 + 11, 16, 16),
                },

                &[_]rl.Rectangle{
                    makeRect(3 + 16 * 1, 5 * 16 + 11, 16, 16),
                    makeRect(5 + 16 * 2, 5 * 16 + 11, 16, 16),
                    makeRect(7 + 16 * 3, 5 * 16 + 11, 16, 16),
                    makeRect(9 + 16 * 4, 5 * 16 + 11, 16, 16),
                    makeRect(11 + 16 * 5, 5 * 16 + 11, 16, 16),
                },
            ),
        );

        sprites.set(
            .scorpion,
            try Sprite.init(
                allocator,
                spritesheet,
                &[_]rl.Rectangle{
                    makeRect(13 + 16 * 6, 6 * 16 + 13, 16, 16),
                },
                &[_]rl.Rectangle{
                    makeRect(3 + 16 * 1, 6 * 16 + 13, 16, 16),
                    makeRect(5 + 16 * 2, 6 * 16 + 13, 16, 16),
                    makeRect(7 + 16 * 3, 6 * 16 + 13, 16, 16),
                    makeRect(9 + 16 * 4, 6 * 16 + 13, 16, 16),
                    makeRect(11 + 16 * 5, 6 * 16 + 13, 16, 16),
                },
            ),
        );

        sprites.set(
            .midori,
            try Sprite.init(
                allocator,
                spritesheet,
                &[_]rl.Rectangle{
                    makeRect(13 + 16 * 6, 7 * 16 + 15, 16, 16),
                },
                &[_]rl.Rectangle{
                    makeRect(3 + 16 * 1, 7 * 16 + 15, 16, 16),
                    makeRect(5 + 16 * 2, 7 * 16 + 15, 16, 16),
                    makeRect(7 + 16 * 3, 7 * 16 + 15, 16, 16),
                    makeRect(9 + 16 * 4, 7 * 16 + 15, 16, 16),
                    makeRect(11 + 16 * 5, 7 * 16 + 15, 16, 16),
                    makeRect(13 + 16 * 6, 7 * 16 + 15, 16, 16),
                },
            ),
        );

        sprites.set(
            .galaxian,
            try Sprite.init(
                allocator,
                spritesheet,
                &[_]rl.Rectangle{
                    makeRect(13 + 16 * 6, 8 * 16 + 17, 16, 16),
                },
                &[_]rl.Rectangle{
                    makeRect(3 + 16 * 1, 8 * 16 + 17, 16, 16),
                    makeRect(5 + 16 * 2, 8 * 16 + 17, 16, 16),
                    makeRect(7 + 16 * 3, 8 * 16 + 17, 16, 16),
                    makeRect(9 + 16 * 4, 8 * 16 + 17, 16, 16),
                    makeRect(11 + 16 * 5, 8 * 16 + 17, 16, 16),
                },
            ),
        );

        sprites.set(
            .tombow,
            try Sprite.init(
                allocator,
                spritesheet,
                &[_]rl.Rectangle{
                    makeRect(13 + 16 * 6, 9 * 16 + 19, 16, 16),
                },
                &[_]rl.Rectangle{
                    makeRect(3 + 16 * 1, 9 * 16 + 19, 16, 16),
                    makeRect(5 + 16 * 2, 9 * 16 + 19, 16, 16),
                    makeRect(7 + 16 * 3, 9 * 16 + 19, 16, 16),
                    makeRect(9 + 16 * 4, 9 * 16 + 19, 16, 16),
                    makeRect(11 + 16 * 5, 9 * 16 + 19, 16, 16),
                },
            ),
        );
        sprites.set(
            .momji,
            try Sprite.init(
                allocator,
                spritesheet,
                &[_]rl.Rectangle{
                    makeRect(1, 10 * 16 + 21, 16, 16),
                    makeRect(3 + 16, 10 * 16 + 21, 16, 16),
                    makeRect(5 + 16 * 2, 10 * 16 + 21, 16, 16),
                },
                &[_]rl.Rectangle{
                    makeRect(9 + 16 * 4, 10 * 16 + 21, 16, 16),
                    makeRect(11 + 16 * 5, 10 * 16 + 21, 16, 16),
                },
            ),
        );
        sprites.set(
            .enterprise,
            try Sprite.init(
                allocator,
                spritesheet,
                &[_]rl.Rectangle{
                    makeRect(13 + 16 * 6, 11 * 16 + 23, 16, 16),
                },
                &[_]rl.Rectangle{
                    makeRect(3 + 16 * 1, 11 * 16 + 23, 16, 16),
                    makeRect(5 + 16 * 2, 11 * 16 + 23, 16, 16),
                    makeRect(7 + 16 * 3, 11 * 16 + 23, 16, 16),
                    makeRect(9 + 16 * 4, 11 * 16 + 23, 16, 16),
                    makeRect(11 + 16 * 5, 11 * 16 + 23, 16, 16),
                },
            ),
        );

        return .{
            .spritesheet = spritesheet,
            .sprites = sprites,
        };
    }
    pub fn deinit(self: *const @This()) void {
        for (self.sprites.values) |sprite| {
            var s = sprite;
            s.deinit();
        }
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
