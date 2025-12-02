const rl = @import("raylib");
const c = @import("constants.zig");
const Renderer = @import("renderer.zig").Renderer;
const std = @import("std");

pub const Grid = struct {
    origin_x: f32,
    origin_y: f32,
    cell_w: f32,
    cell_h: f32,
    width: f32,
    height: f32,
    cols: usize,
    rows: usize,

    pub fn init(font: rl.Font) @This() {
        const digit_size = rl.measureTextEx(font, "0", c.SCALED_FONT_SIZE, 2.0);
        const cell_w = digit_size.x + 7.0;
        const cell_h = digit_size.y;
        std.debug.print("Cell W: {d}, H: {d}\n", .{ cell_w, cell_h });
        std.debug.print("Target W: {d}, H: {d}\n", .{ c.TARGET_W, c.TARGET_H });

        const margin_x = c.GRID_MARGIN_X * @as(f32, @floatFromInt(c.SSAA_FACTOR));
        const margin_y = c.GRID_MARGIN_Y * @as(f32, @floatFromInt(c.SSAA_FACTOR));

        const usable_width = @as(f32, @floatFromInt(c.TARGET_W)) - (margin_x * 2.0);
        const usable_height = @as(f32, @floatFromInt(c.TARGET_H)) - (margin_y * 2.0);
        std.debug.print("Usable W: {d}, H: {d}\n", .{ usable_width, usable_height });

        const cols = @as(usize, @intFromFloat(usable_width / cell_w));
        const rows = @as(usize, @intFromFloat(usable_height / cell_h));
        std.debug.print("Grid cols: {d}, rows: {d}\n", .{ cols, rows });

        return .{
            .origin_x = margin_x, // Use scaled margin
            .origin_y = margin_y, // Use scaled margin
            .cell_w = cell_w,
            .cell_h = cell_h,
            .width = usable_width,
            .height = usable_height,
            .cols = cols,
            .rows = rows,
        };
    }

    pub fn pos(self: @This(), col: f32, row: f32) rl.Rectangle {
        return .{
            .x = self.origin_x + col * self.cell_w,
            .y = self.origin_y + row * self.cell_h,
            .width = self.cell_w,
            .height = self.cell_h,
        };
    }
};
