const rl = @import("raylib");
const c = @import("constants.zig");
const Renderer = @import("renderer.zig").Renderer;

pub const Grid = struct {
    origin_x: f32,
    origin_y: f32,
    cell_w: f32,
    cell_h: f32,

    pub fn init(r: *Renderer) @This() {
        const digit_size = rl.measureTextEx(r.font, "0", c.SCALED_FONT_SIZE, 0);
        const cell_w = digit_size.x;

        const cell_h = digit_size.y;

        return .{
            .origin_x = c.GRID_MARGIN_X,
            .origin_y = c.GRID_MARGIN_Y,
            .cell_w = cell_w,
            .cell_h = cell_h,
        };
    }

    pub fn pos(self: @This(), col: usize, row: usize) rl.Vector2 {
        return .{
            .x = self.origin_x + @as(f32, @floatFromInt(col)) * self.cell_w,
            .y = self.origin_y + @as(f32, @floatFromInt(row)) * self.cell_h,
        };
    }
};
