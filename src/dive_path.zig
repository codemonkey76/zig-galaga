const rl = @import("raylib");
const std = @import("std");
const c = @import("constants.zig");
const Palette = @import("palette.zig").Palette;

pub const MirrorAxis = enum {
    x,
    y,
};
pub const DivePath = struct {
    control_points: []const rl.Vector2,
    duration: f32,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, control_points: []const rl.Vector2, duration: f32) !@This() {
        const owned_points = try allocator.dupe(rl.Vector2, control_points);
        return .{
            .control_points = owned_points,
            .duration = duration,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.allocator.free(self.control_points);
    }

    pub fn getPosition(self: @This(), t: f32) rl.Vector2 {
        const clamped_t = @max(0.0, @min(1.0, t));

        // For temporary calculations, use a fixed-size buffer
        var temp_buffer: [32]rl.Vector2 = undefined;
        const count = self.control_points.len;

        // Copy control points to buffer
        for (self.control_points, 0..) |cp, i| {
            temp_buffer[i] = cp;
        }

        // De Casteljau's algorithm
        var current_count = count;
        while (current_count > 1) : (current_count -= 1) {
            for (0..current_count - 1) |i| {
                temp_buffer[i] = lerp(temp_buffer[i], temp_buffer[i + 1], clamped_t);
            }
        }

        return temp_buffer[0];
    }

    pub fn mirror(self: @This(), axis: MirrorAxis) !@This() {
        const center_x = @as(f32, @floatFromInt(c.TARGET_W)) / 2.0;
        const center_y = @as(f32, @floatFromInt(c.TARGET_H)) / 2.0;

        var mirrored_points = try self.allocator.alloc(rl.Vector2, self.control_points.len);

        for (self.control_points, 0..) |point, i| {
            mirrored_points[i] = switch (axis) {
                .x => .{
                    .x = point.x,
                    .y = center_y + (center_y - point.y),
                },
                .y => .{
                    .x = center_x + (center_x - point.x),
                    .y = point.y,
                },
            };
        }

        return .{
            .control_points = mirrored_points,
            .duration = self.duration,
            .allocator = self.allocator,
        };
    }

    pub fn drawDebug(self: @This(), color: rl.Color, segments: usize) void {
        var prev_pos = self.getPosition(0.0);
        for (1..segments + 1) |i| {
            const t = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments));
            const pos = self.getPosition(t);

            rl.drawLine(@intFromFloat(prev_pos.x), @intFromFloat(prev_pos.y), @intFromFloat(pos.x), @intFromFloat(pos.y), color);

            prev_pos = pos;
        }

        // Draw control points
        for (self.control_points, 0..) |cp, i| {
            rl.drawCircle(@intFromFloat(cp.x), @intFromFloat(cp.y), 5, rl.Color.yellow);

            if (i > 0) {
                rl.drawLine(@intFromFloat(self.control_points[i - 1].x), @intFromFloat(self.control_points[i - 1].y), @intFromFloat(cp.x), @intFromFloat(cp.y), rl.Color{ .r = 255, .g = 255, .b = 0, .a = 100 });
            }
        }

        // Mark start and end
        const start = self.control_points[0];
        const end = self.control_points[self.control_points.len - 1];
        rl.drawCircle(@intFromFloat(start.x), @intFromFloat(start.y), 8, rl.Color.green);
        rl.drawCircle(@intFromFloat(end.x), @intFromFloat(end.y), 8, rl.Color.red);
    }
};

fn lerp(a: rl.Vector2, b: rl.Vector2, t: f32) rl.Vector2 {
    return rl.Vector2{
        .x = a.x + (b.x - a.x) * t,
        .y = a.y + (b.y - a.y) * t,
    };
}
