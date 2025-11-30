const rl = @import("raylib");
const std = @import("std");
const Renderer = @import("renderer.zig").Renderer;
const c = @import("constants.zig");

const Star = struct {
    x: f32,
    y: f32,
    speed: f32,
    color: rl.Color,
    twinkle_timer: f32,
    twinkle_duration: f32,
    visible: bool,
};

pub const Starfield = struct {
    stars: [c.MAX_STARS]Star,
    prng: std.Random.DefaultPrng,

    pub fn init() Starfield {
        var stars: [c.MAX_STARS]Star = undefined;
        var prng = std.Random.DefaultPrng.init(@intCast(std.time.timestamp()));
        const random = prng.random();

        for (&stars) |*star| {
            star.x = random.float(f32) * c.LOGICAL_W;
            star.y = random.float(f32) * c.LOGICAL_H;
            star.speed = c.STAR_SPEED + random.float(f32) * c.STAR_SPEED_RANDOMNESS;
            star.twinkle_timer = 0;
            star.twinkle_duration = c.TWINKLE_MIN + random.float(f32) * (c.TWINKLE_MAX - c.TWINKLE_MIN);
            star.visible = true;

            const brightness = 128 + random.intRangeAtMost(u8, 0, 127);
            const color_choice = random.intRangeAtMost(u8, 0, 2);
            star.color = switch (color_choice) {
                0 => rl.Color{ .r = brightness, .g = brightness, .b = brightness, .a = 255 },
                1 => rl.Color{ .r = brightness - 55, .g = brightness - 35, .b = brightness, .a = 255 },
                2 => rl.Color{ .r = brightness, .g = brightness, .b = brightness - 55, .a = 255 },
                else => rl.Color.white,
            };
        }

        return .{
            .stars = stars,
            .prng = prng,
        };
    }

    pub fn update(self: *@This(), dt: f32) void {
        const random = self.prng.random();

        for (&self.stars) |*star| {
            star.y += star.speed * dt;

            // Twinkle effect
            star.twinkle_timer += dt;
            if (star.twinkle_timer >= star.twinkle_duration) {
                star.visible = !star.visible;
                star.twinkle_timer = 0;
            }

            // Wrap around when star goes off bottom (logical coords)
            if (star.y > c.LOGICAL_H) {
                star.y = 0;
                star.x = random.float(f32) * c.LOGICAL_W;
            }
        }
    }

    pub fn draw(self: @This(), _: *Renderer) void {
        const star_size_px = c.SSAA_FACTOR * c.STAR_SIZE_LOGICAL;

        for (self.stars) |star| {
            if (!star.visible) continue;

            // logical → supersampled coords
            const sx = star.x * c.SSAA_FACTOR;
            const sy = star.y * c.SSAA_FACTOR;

            rl.drawRectangle(
                @intFromFloat(sx),
                @intFromFloat(sy),
                star_size_px,
                star_size_px,
                star.color,
            );
        }
    }
};
