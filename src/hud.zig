const rl = @import("raylib");

const GameData = @import("game_data.zig").GameData;
const Renderer = @import("renderer.zig").Renderer;
const Grid = @import("grid.zig").Grid;
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
        const buf: [32:0]u8 = undefined;

        drawScore(r, self.grid, .absolute(0), 0, "   1UP", data.p1_score.format(&buf));
        drawScore(r, self.grid, .absolute(0), 0, "   2UP", data.p2_score.format(&buf));
        drawScore(r, self.grid, .centered, 0, "HIGH SCORE", data.hi_score.format(&buf));
    }

    /// Draws the score with a label above it at the grid position given.
    fn drawScore(r: *Renderer, grid: Grid, mode: DrawMode, y: usize, label: [:0]u8, score: [:0]u8) void {
        const coords = switch (mode) {
            .centered => .{
                .x1 = @as(f32, @floatFromInt((c.TARGET_W - rl.measureText(r.font, label, c.SCALED_FONT_SIZE)) / 2)),
                .x2 = @as(f32, @floatFromInt((c.TARGET_W - rl.measureText(r.font, score, c.SCALED_FONT_SIZE)) / 2)),
            },
            .absolute => |x| .{
                .x1 = grid.pos(x, y).x,
                .x2 = grid.pos(x, y).x,
            },
        };

        rl.drawTextEx(r.font, label, rl.Vector2{ .x = coords.x1, .y = y }, c.SCALED_FONT_SIZE, 0);
        rl.drawTextEx(r.font, score, rl.Vector2{ .x = coords.x2, .y = y + 1.0 }, c.SCALED_FONT_SIZE, 0);
    }
};
