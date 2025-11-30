const rl = @import("raylib");

const GameData = @import("game_data.zig").GameData;
const Renderer = @import("renderer.zig").Renderer;
const Grid = @import("grid.zig").Grid;
const Palette = @import("palette.zig").Palette;
const c = @import("constants.zig");

const DrawMode = union(enum) {
    centered,
    absolute: usize,
};
pub const Hud = struct {
    grid: Grid,

    pub fn init(r: *Renderer) @This() {
        return .{
            .grid = Grid.init(r),
        };
    }

    pub fn draw(self: @This(), r: *Renderer, data: GameData) void {
        var buf: [32:0]u8 = undefined;

        drawScore(r, self.grid, .{ .absolute = 0 }, 0, "   1UP", data.p1_score.format(&buf));
        drawScore(r, self.grid, .{ .absolute = 27 }, 0, "   2UP", data.p2_score.format(&buf));
        drawScore(r, self.grid, .centered, 0, "HIGH SCORE", data.hi_score.format(&buf));
    }

    /// Draws the score with a label above it at the grid position given.
    fn drawScore(r: *Renderer, grid: Grid, mode: DrawMode, y: usize, label: [:0]const u8, score: [:0]const u8) void {
        const y_px = grid.pos(0, y).y;
        const y_plus_1 = grid.pos(0, y + 1).y;

        const coords: struct { x1: f32, x2: f32 } = switch (mode) {
            .centered => .{
                .x1 = @as(f32, @floatFromInt(@divFloor((c.TARGET_W - rl.measureText(label, c.SCALED_FONT_SIZE)), 2))),
                .x2 = @as(f32, @floatFromInt(@divFloor((c.TARGET_W - rl.measureText(score, c.SCALED_FONT_SIZE)), 2))),
            },
            .absolute => |x| .{
                .x1 = grid.pos(x, y).x,
                .x2 = grid.pos(x, y).x,
            },
        };

        rl.drawTextEx(r.font, label, rl.Vector2{ .x = coords.x1, .y = y_px }, c.SCALED_FONT_SIZE, 0, Palette.red);
        rl.drawTextEx(r.font, score, rl.Vector2{ .x = coords.x2, .y = y_plus_1 }, c.SCALED_FONT_SIZE, 0, Palette.white);
    }
};
