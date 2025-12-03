const rl = @import("raylib");
const std = @import("std");
const DivePath = @import("dive_path.zig").DivePath;

pub const DiveType = enum {
    swoop_right,
    swoop_left,
};

pub const DivePaths = struct {
    swoop_left: DivePath,
    swoop_right: DivePath,

    pub fn init(allocator: std.mem.Allocator) !@This() {
        const swoop_left = try DivePath.init(allocator, &[_]rl.Vector2{
            .{ .x = 300, .y = 0 }, // Start: top-center-left
            .{ .x = 300, .y = 350 }, // Control point 1
            .{ .x = 1100, .y = 400 }, // Control point 2: pull right
            .{ .x = 950, .y = 900 }, // Control point 3: curve down
            .{ .x = 350, .y = 850 }, // Control point 4: swing left
            .{ .x = 448, .y = 350 }, // End: center formation
        }, 3.0);

        return .{
            .swoop_left = swoop_left,
            .swoop_right = try swoop_left.mirror(.y),
        };
    }

    pub fn deinit(self: *@This()) void {
        self.swoop_left.deinit();
        self.swoop_right.deinit();
    }
};
