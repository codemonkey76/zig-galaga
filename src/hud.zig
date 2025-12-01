const rl = @import("raylib");

const GameData = @import("game_data.zig").GameData;
const Renderer = @import("renderer.zig").Renderer;
const DrawMode = @import("renderer.zig").DrawMode;
const Grid = @import("grid.zig").Grid;
const Palette = @import("palette.zig").Palette;
const c = @import("constants.zig");

pub const Hud = struct {
    pub fn draw(r: *Renderer, data: GameData) void {
        var buf: [32:0]u8 = undefined;

        drawScore(r, .{ .cell = .{ .x = 0, .y = 0 } }, "   1UP", data.p1_score.format(&buf));
        drawScore(r, .{ .cell = .{ .x = 27, .y = 0 } }, "   2UP", data.p2_score.format(&buf));
        drawScore(r, .{ .center_x = 0 }, "HIGH SCORE", data.hi_score.format(&buf));
    }

    fn drawScore(r: *Renderer, mode: DrawMode, label: [:0]const u8, score: [:0]const u8) void {
        r.drawText(label, mode, Palette.red);
        // Draw score one row below
        const score_mode = switch (mode) {
            .center_x => |y| DrawMode{ .center_x = y + 1 },
            .cell => |pos| DrawMode{ .cell = .{ .x = pos.x, .y = pos.y + 1 } },
            .centered => DrawMode.centered, // If somehow used for score
            .absolute => |pos| DrawMode{ .absolute = .{ .x = pos.x, .y = pos.y + 1 } },
        };
        r.drawText(score, score_mode, Palette.white);
    }
};
