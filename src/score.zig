const std = @import("std");

pub const Score = struct {
    value: u32,
    pub const max: u32 = 9_999_990;

    pub fn init(value: u32) @This() {
        return .{ .value = value };
    }
    pub fn add(self: *@This(), points: u32) void {
        if (self.value >= max) return;

        const remaining = max - self.value;
        if (points >= remaining) {
            self.value = max;
        } else {
            self.value += points;
        }
    }
    pub fn format(
        self: *const @This(),
        buf: []u8,
    ) [:0]const u8 {
        const WIDTH = 7;
        var tmp: [16]u8 = undefined;
        const raw = std.fmt.bufPrint(&tmp, "{d:0>2}", .{self.value}) catch {
            // Fallback in case formatting fails
            @memcpy(buf[0..7], "ERROR!!");
            buf[7] = 0;
            return buf[0..7 :0];
        };

        if (raw.len > WIDTH) {
            // Fallback if number is too large
            @memcpy(buf[0..7], "9999990");
            buf[7] = 0;
            return buf[0..7 :0];
        }

        const pad = WIDTH - raw.len;

        // Make sure output fits (plus the trailing zero)
        if (pad + raw.len + 1 > buf.len) {
            // Fallback if buffer is too small
            @memcpy(buf[0..7], "BUFFERR");
            buf[7] = 0;
            return buf[0..7 :0];
        }

        // Fill pad
        for (0..pad) |i| buf[i] = ' ';
        // Copy raw text
        std.mem.copyForwards(u8, buf[pad .. pad + raw.len], raw);
        // Null-terminate
        buf[pad + raw.len] = 0;
        return buf[0 .. pad + raw.len :0];
    }
};
