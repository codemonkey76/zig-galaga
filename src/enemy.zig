const rl = @import("raylib");
const std = @import("std");
const SpriteType = @import("sprites.zig").SpriteType;
const DivePath = @import("dive_path.zig").DivePath;
const Renderer = @import("renderer.zig").Renderer;
const Palette = @import("palette.zig").Palette;
const c = @import("constants.zig");

pub const FormationPos = struct {
    x: f32,
    y: f32,
};

pub const RotationInfo = struct {
    frame: usize,
    angle: f32,
};

pub const Enemy = struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    sprite_type: SpriteType,
    state: EnemyState,
    formation_pos: rl.Vector2,
    path_time: f32,
    dive_path: *const DivePath,
    return_path: ?DivePath,
    return_control_ponts: [4]rl.Vector2, // storage buffer for calculating return path

    pub fn init(sprite_type: SpriteType, dive_path: *const DivePath, formation_pos: rl.Vector2) @This() {
        return .{
            .position = dive_path.control_points[0],
            .velocity = rl.Vector2{ .x = 0, .y = 0 },
            .sprite_type = sprite_type,
            .state = .diving,
            .formation_pos = formation_pos,
            .path_time = 0,
            .dive_path = dive_path,
            .return_path = null,
            .return_control_points = undefined,
        };
    }

    pub fn update(self: *@This(), dt: f32) void {
        switch (self.state) {
            .diving => {
                self.path_time += dt;
                self.velocity = self.driv_path.getVelocityAtTime(self.path_time, dt);
                self.position = self.dive_path.getPositionAtTime(self.path_time);

                if (self.path_time >= self.dive_path.duration) {
                    // Dive complete, generate path to formation
                    self.state = .returning;
                    self.return_path = self.generateReturnPath(&self.return_control_points);
                    self.path_time = 0;
                }
            },
            .returning => {
                if (self.return_path) |path| {
                    self.path_time += dt;
                    self.velocity = path.getVelocityAtTime(self.path_time, dt);
                    self.position = path.getPositionAtTime(self.path_time);

                    if (self.path_time >= path.duration) {
                        self.state = .in_formation;
                        self.return_path = null;
                    }
                }
            },
            .in_formation => {
                self.position = self.formation_pos;
                self.velocity = .{ .x = 0, .y = 0 };
            },
            .spawning => {},
        }
    }

    fn generateReturnPath(self: @This(), buffer: *[4]rl.Vector2) !DivePath {
        const start = self.position;
        const end = self.formation_pos;

        buffer[0] = start;
        buffer[1] = .{ .x = start.x, .y = (start.y + end.y) / 2 };
        buffer[2] = .{ .x = end.x, .y = (start.y + end.y) / 2 };
        buffer[3] = end;

        return .{
            .control_points = buffer[0..4],
            .duration = 1.5,
        };
    }

    pub fn getRotationInfo(self: @This()) RotationInfo {
        // Calculate angle from velocity
        const angle_rad = std.math.atan2(self.velocity.y, self.velocity.x);
        const angle_deg = angle_rad * 180.0 / std.math.pi;

        // Normalize to 0-360
        const normalized = if (angle_deg < 0) angle_deg + 360 else angle_deg;

        // Frames cover 90 (left) to 0 (up) = andles 90-0
        // Each frame is 15 apart: 90, 75, 60, 45, 30, 15, 0

        // Figure out which quadrant and flip accordingly
        var sprite_angle: f32 = 0;
        var frame_angle = normalized;

        if (normalized > 90 and normalized <= 180) {
            // Bottom-left quadrant: use frames, flip horizontally
            frame_angle = 180 - normalized; // Map 91-180 to 89-0
            sprite_angle = 180;
        } else if (normalized > 180 and normalized <= 270) {
            // Bottom-right quadrant: use frames as-is, rotate 180
            frame_angle = normalized - 180; // Map 181-270 to 1-90
            sprite_angle = 180;
        } else if (normalized > 270) {
            // Top right quadrant: use rames, flip horizontally
            frame_angle = 360 - normalized; // Map 271-360 to 89-0
            sprite_angle = 0;
        }

        const frame = @min(5, @as(usize, @intFromFloat(frame_angle / 15.0)));

        return .{ .frame = frame, .angle = sprite_angle };
    }
    pub fn draw(self: @This(), r: *Renderer) void {
        const sprite = r.sprites.get(self.sprite_type);

        const frame_info = switch (self.state) {
            .in_formation => blk: {
                const frame = sprite.get_idle(r.frame_index);
                break :blk .{ .frame = frame, .angle = 0.0 };
            },
            .diving, .returning, .spawning => blk: {
                const info = self.getRotationInfo();
                const frame = sprite.getRotated(info.frame);
                break :blk .{ .frame = frame, .angle = info.angle };
            },
        };

        const scale = @as(f32, @floatFromInt(c.SSAA_FACTOR));
        const dest = rl.Rectangle{
            .x = self.position.x,
            .y = self.position.y,
            .width = frame_info.frame.source.width * scale,
            .height = frame_info.frame.source.height * scale,
        };

        const origin = rl.Vector2{
            .x = dest.width / 2,
            .y = dest.height / 2,
        };

        rl.drawTexturePro(sprite.texture, frame_info.source, dest, origin, frame_info.angle, Palette.white);
    }
};

pub const EnemyState = enum {
    spawning,
    in_formation,
    diving,
    returning,
};
