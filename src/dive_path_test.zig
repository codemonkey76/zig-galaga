const std = @import("std");
const rl = @import("raylib");
const Enemy = @import("enemy.zig").Enemy;
const DivePaths = @import("dive_paths.zig").DivePaths;
const DiveType = @import("dive_paths.zig").DiveType;

pub const DivePathTest = struct {
    enemies: std.ArrayList(Enemy),
    dive_paths: *const DivePaths,
    spawn_timer: f32,
    current_path: DiveType,

    pub fn init(allocator: std.mem.Allocator, dive_paths: *const DivePaths) @This() {
        return .{
            .enemies = std.ArrayList(Enemy).init(allocator),
            .dive_paths = dive_paths,
            .spawn_timer = 0,
            .current_path = .swoop_left,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.enemies.deinit();
    }

    pub fn update(self: *@This(), dt: f32) void {
        self.spawn_timer += dt;

        if (self.spawn_timer >= 1.5 and self.enemies.items.len < 4) {
            self.spawn_timer = 0;

            self.current_path = if (self.current_path == .swoop_left) .swoop_right else .swoop_left;

            const formation_pos = rl.Vector2{
                .x = 300 + @as(f32, @floatFromInt(self.enemies.items.len)) * 100,
                .y = 400,
            };

            const path = self.dive_paths.get(self.current_path);
            const enemy = Enemy.init(.zako, path, formation_pos);
            self.enemies.append(enemy) catch {};
        }

        for (self.enemies.items) |*enemy| {
            enemy.update(dt);
        }
    }

    pub fn draw(self: @This()) void {
        for (self.enemies.items) |enemy| {
            enemy.draw();
        }
    }
};
