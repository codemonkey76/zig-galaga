const std = @import("std");
const rl = @import("raylib");

pub const InputManager = struct {
    consumed_keys: std.AutoHashMap(rl.KeyboardKey, bool),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) @This() {
        return .{
            .consumed_keys = std.AutoHashMap(rl.KeyboardKey, bool).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.consumed_keys.deinit();
    }

    pub fn newFrame(self: *@This()) void {
        self.consumed_keys.clearRetainingCapacity();
    }

    pub fn isKeyPressed(self: *InputManager, key: rl.KeyboardKey, consume: bool) !bool {
        if (self.consumed_keys.get(key)) |consumed| {
            if (consumed) return false;
        }
        const pressed = rl.isKeyPressed(key);

        if (pressed and consume) {
            try self.consumed_keys.put(key, true);
        }
        return pressed;
    }
};
