const rl = @import("raylib");
const c = @import("constants.zig");
const Renderer = @import("renderer.zig").Renderer;

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
        const digit_size = rl.measureTextEx(font, "0", c.SCALED_FONT_SIZE, 0);
        const cell_w = digit_size.x;
        const cell_h = digit_size.y;

        const usable_width = @as(f32, @floatFromInt(c.TARGET_W)) - (c.GRID_MARGIN_X * 2.0);
        const usable_height = @as(f32, @floatFromInt(c.TARGET_H)) - (c.GRID_MARGIN_Y * 2.0);

        const cols = @as(usize, @intFromFloat(usable_width / cell_w));
        const rows = @as(usize, @intFromFloat(usable_height / cell_h));

        return .{
            .origin_x = c.GRID_MARGIN_X,
            .origin_y = c.GRID_MARGIN_Y,
            .cell_w = cell_w,
            .cell_h = cell_h,
            .width = usable_width,
            .height = usable_height,
            .cols = cols,
            .rows = rows,
        };
    }

    pub fn pos(self: @This(), col: f32, row: f32) rl.Vector2 {
        return .{
            .x = self.origin_x + col * self.cell_w,
            .y = self.origin_y + row * self.cell_h,
        };
    }
};
