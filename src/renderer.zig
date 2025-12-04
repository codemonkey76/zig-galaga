const rl = @import("raylib");
const std = @import("std");

const DivePath = @import("dive_path.zig").DivePath;
const Palette = @import("palette.zig").Palette;
const Grid = @import("grid.zig").Grid;
const Sprite = @import("sprites.zig").Sprite;
const Sprites = @import("sprites.zig").Sprites;
const SpriteType = @import("sprites.zig").SpriteType;
const Flags = @import("flags.zig").Flags;
const c = @import("constants.zig");

const chars = [_]u8{
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
};

pub const Renderer = struct {
    allocator: std.mem.Allocator,
    grid: Grid,
    sprites: Sprites,
    render_target: rl.RenderTexture,
    font: rl.Font,
    anim_timer: f32,
    frame_index: usize,
    cell_timer: f32,
    grid_col: usize,
    grid_row: usize,
    char_timer: f32,
    char_index: usize,

    pub fn init(allocator: std.mem.Allocator) !@This() {
        const render_target = try rl.loadRenderTexture(c.TARGET_W, c.TARGET_H);

        const font = rl.loadFontEx(c.FONT, c.SCALED_FONT_SIZE, null) catch |err| {
            rl.unloadRenderTexture(render_target);
            return err;
        };

        const sprites = try Sprites.init(allocator);

        return .{
            .allocator = allocator,
            .grid = Grid.init(font),
            .sprites = sprites,
            .render_target = render_target,
            .font = font,
            .anim_timer = 0,
            .frame_index = 0,
            .cell_timer = 0,
            .grid_col = 0,
            .grid_row = 0,
            .char_timer = 0,
            .char_index = 0,
        };
    }

    pub fn update(self: *@This(), dt: f32) void {
        self.anim_timer += dt;

        if (self.anim_timer > c.ANIM_TIME) {
            self.frame_index += 1;
            self.anim_timer = 0;
        }

        self.cell_timer += dt;
        if (self.cell_timer >= 0.15) {
            self.cell_timer = 0;
            self.grid_col += 1;
            if (self.grid_col > self.grid.cols) {
                self.grid_col = 0;
                self.grid_row += 1;

                if (self.grid_row > self.grid.rows) {
                    self.grid_row = 0;
                }
            }
        }

        self.char_timer += dt;
        if (self.char_timer > 0.02) {
            self.char_timer = 0;
            self.char_index += 1;
            if (self.char_index > 26) {
                self.char_index = 0;
            }
        }
    }

    pub fn deinit(self: *Renderer) void {
        self.sprites.deinit();
        rl.unloadRenderTexture(self.render_target);
        rl.unloadFont(self.font);
    }

    pub fn render(self: *Renderer) void {
        const win_w: i32 = rl.getRenderWidth();
        const win_h: i32 = rl.getRenderHeight();

        const win_w_f: f32 = @floatFromInt(win_w);
        const win_h_f: f32 = @floatFromInt(win_h);

        // Scale to fit while preserving logical aspect
        const scale_x = win_w_f / c.LOGICAL_W_F;
        const scale_y = win_h_f / c.LOGICAL_H_F;
        const scale = if (scale_x < scale_y) scale_x else scale_y;

        const draw_w: f32 = c.LOGICAL_W_F * scale;
        const draw_h: f32 = c.LOGICAL_H_F * scale;

        // Center (letterboxing)
        const pos_x: f32 = (win_w_f - draw_w) / 2.0;
        const pos_y: f32 = (win_h_f - draw_h) / 2.0;

        const dst = rl.Rectangle{
            .x = pos_x,
            .y = pos_y,
            .width = draw_w,
            .height = draw_h,
        };

        rl.beginDrawing();
        rl.clearBackground(Palette.letterbox);

        rl.drawTexturePro(
            self.render_target.texture,
            c.SRC_RECT,
            dst,
            rl.Vector2{ .x = 0, .y = 0 },
            0.0,
            Palette.white,
        );

        rl.endDrawing();
    }
    pub fn drawGameScreen(self: @This()) void {
        self.drawLives(4);
    }
    // pub fn drawSampleDivePath(self: @This()) void {
    //     _ = self;
    //
    //     const screen_center_x: f32 = @as(f32, @floatFromInt(c.TARGET_W)) / 2.0;
    //
    //     const path1 = DivePath{
    //         .control_points = &[_]rl.Vector2{
    //             .{ .x = 300, .y = 0 }, // Start: top-center-left
    //             .{ .x = 300, .y = 350 }, // Control point 1
    //             .{ .x = 1100, .y = 400 }, // Control point 2: pull right
    //             .{ .x = 950, .y = 900 }, // Control point 3: curve down
    //             .{ .x = 350, .y = 850 }, // Control point 4: swing left
    //             .{ .x = 448, .y = 350 }, // End: center formation
    //         },
    //         .duration = 3.0,
    //     };
    //
    //     var mirror_buffer: [32]rl.Vector2 = undefined;
    //     const path2 = path1.mirror(screen_center_x, &mirror_buffer);
    //     path1.drawDebug(Palette.cyan, 50);
    //     path2.drawDebug(Palette.cyan, 50);
    // }
    pub fn drawLives(self: @This(), lives: u32) void {
        const margin_left: f32 = 16.0 * @as(f32, @floatFromInt(c.SSAA_FACTOR));
        const margin_bottom: f32 = 3.0 * @as(f32, @floatFromInt(c.SSAA_FACTOR));
        const gap: f32 = 2.0 * @as(f32, @floatFromInt(c.SSAA_FACTOR));
        const sprite_width: f32 = 16.0 * 3.0;
        const sprite = self.sprites.get(SpriteType.player);

        const y = @as(f32, @floatFromInt(c.TARGET_H)) - margin_bottom - (sprite_width);

        for (0..lives) |i| {
            const x = margin_left + @as(f32, @floatFromInt(i)) * (sprite_width + gap);
            const pos = rl.Vector2{ .x = x, .y = y };

            const frame = sprite.getIdle(self.frame_index);
            const dest = rl.Rectangle{
                .x = pos.x,
                .y = pos.y,
                .width = frame.source.width * 3,
                .height = frame.source.height * 3,
            };

            rl.drawTexturePro(sprite.texture, frame.source, dest, rl.Vector2{ .x = 0, .y = 0 }, 0, Palette.white);
            // self.drawSprite(self.sprites.get(SpriteType.player), .{ .cell = .{ .x = @as(f32, @floatFromInt(i)) * 2.2, .y = @as(f32, @floatFromInt(self.grid.rows)) *  } });
        }
    }
    pub fn draw(self: @This(), flags: Flags) void {
        self.drawGameScreen();
        if (flags.show_fps) {
            rl.drawFPS(10, 10);
        }
        if (flags.show_grid) {
            // self.drawGrid();
            self.drawSprites();
            // self.drawGridChars();
        }
    }
    pub fn drawRect(_: @This(), rect: rl.Rectangle, color: rl.Color) void {
        rl.drawRectangle(
            @intFromFloat(rect.x),
            @intFromFloat(rect.y),
            @intFromFloat(rect.width),
            @intFromFloat(rect.height),
            color,
        );
    }

    pub fn drawSprites(self: @This()) void {
        self.drawSprite(self.sprites.get(SpriteType.player), .{ .cell = .{ .x = 0, .y = 0 } });
        self.drawSprite(self.sprites.get(SpriteType.boss), .{ .cell = .{ .x = 2, .y = 0 } });
        self.drawSprite(self.sprites.get(SpriteType.goei), .{ .cell = .{ .x = 4, .y = 0 } });
        self.drawSprite(self.sprites.get(SpriteType.zako), .{ .cell = .{ .x = 6, .y = 0 } });
        self.drawSprite(self.sprites.get(SpriteType.scorpion), .{ .cell = .{ .x = 8, .y = 0 } });
        self.drawSprite(self.sprites.get(SpriteType.midori), .{ .cell = .{ .x = 10, .y = 0 } });
        self.drawSprite(self.sprites.get(SpriteType.galaxian), .{ .cell = .{ .x = 12, .y = 0 } });
        self.drawSprite(self.sprites.get(SpriteType.tombow), .{ .cell = .{ .x = 14, .y = 0 } });
        self.drawSprite(self.sprites.get(SpriteType.momji), .{ .cell = .{ .x = 16, .y = 0 } });
        self.drawSprite(self.sprites.get(SpriteType.enterprise), .{ .cell = .{ .x = 18, .y = 0 } });
    }

    pub fn drawGrid(self: @This()) void {
        const line_width = @as(f32, @floatFromInt(c.SSAA_FACTOR));

        // Draw vertical lines
        for (0..self.grid.cols + 1) |col| {
            const top = self.grid.pos(@floatFromInt(col), 0);
            const bottom = self.grid.pos(@floatFromInt(col), @floatFromInt(self.grid.rows));

            const rect = rl.Rectangle{
                .x = top.x,
                .y = top.y,
                .width = line_width,
                .height = bottom.y - top.y,
            };
            rl.drawRectangleRec(rect, Palette.grid);
        }

        // Draw horizontal lines
        for (0..self.grid.rows + 1) |row| {
            const left = self.grid.pos(0, @floatFromInt(row));
            const right = self.grid.pos(@floatFromInt(self.grid.cols), @floatFromInt(row));

            const rect = rl.Rectangle{
                .x = left.x,
                .y = left.y,
                .width = right.x - left.x + line_width, // Add line_width to reach the right edge
                .height = line_width,
            };
            rl.drawRectangleRec(rect, Palette.grid);
        }
    }

    pub fn beginGameDraw(self: *Renderer) void {
        rl.beginTextureMode(self.render_target);
        rl.clearBackground(Palette.black);
    }

    pub fn endGameDraw(_: *Renderer) void {
        rl.endTextureMode();
    }

    pub fn drawText(self: *@This(), text: [:0]const u8, mode: DrawMode, color: rl.Color) void {
        const pos = self.getVec(mode, text);

        rl.drawTextEx(self.font, text, pos, c.SCALED_FONT_SIZE, 0, color);
    }

    pub fn drawSprite(self: @This(), sprite: Sprite, mode: DrawMode) void {
        const frame = sprite.getIdle(self.frame_index);

        const pos = self.getVec(mode, "0");
        const dest = rl.Rectangle{
            .x = pos.x,
            .y = pos.y,
            .width = frame.source.width * 3,
            .height = frame.source.height * 3,
        };
        rl.drawTexturePro(sprite.texture, frame.source, dest, rl.Vector2{ .x = 0, .y = 0 }, 0, Palette.white);
    }
    fn getVec(self: @This(), mode: DrawMode, text: [:0]const u8) rl.Vector2 {
        return switch (mode) {
            .centered => blk: {
                const rect = rl.measureTextEx(self.font, text, c.SCALED_FONT_SIZE, 0);
                break :blk rl.Vector2{
                    .x = (@as(f32, @floatFromInt(c.TARGET_W)) - rect.x) / 2.0,
                    .y = (@as(f32, @floatFromInt(c.TARGET_H)) - rect.y) / 2.0,
                };
            },
            .center_x => |y| blk: {
                const text_width = rl.measureTextEx(self.font, text, c.SCALED_FONT_SIZE, 0).x;
                break :blk rl.Vector2{
                    .x = (@as(f32, @floatFromInt(c.TARGET_W)) - text_width) / 2.0,
                    .y = self.grid.pos(0, y).y,
                };
            },
            .cell => |pos| blk: {
                const rect = self.grid.pos(pos.x, pos.y);
                break :blk rl.Vector2{ .x = rect.x, .y = rect.y };
            },
            .absolute => |pos| rl.Vector2{ .x = @floatFromInt(pos.x), .y = @floatFromInt(pos.y) },
        };
    }
};

pub const DrawMode = union(enum) {
    center_x: f32,
    centered,
    cell: struct { x: f32, y: f32 },
    absolute: struct { x: usize, y: usize },
};
