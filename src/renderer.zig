const rl = @import("raylib");
const std = @import("std");

const Palette = @import("palette.zig").Palette;
const Grid = @import("grid.zig").Grid;
const Sprite = @import("sprites.zig").Sprite;
const c = @import("constants.zig");

pub const Renderer = struct {
    grid: Grid,
    render_target: rl.RenderTexture,
    font: rl.Font,
    wing_timer: f32,
    frame_index: usize,
    wing_open: bool,

    pub fn init() !@This() {
        const render_target = try rl.loadRenderTexture(c.TARGET_W, c.TARGET_H);

        const font = rl.loadFontEx(c.FONT, c.SCALED_FONT_SIZE, null) catch |err| {
            rl.unloadRenderTexture(render_target);
            return err;
        };

        return .{
            .grid = Grid.init(font),
            .render_target = render_target,
            .font = font,
            .wing_timer = 0,
            .frame_index = 0,
            .wing_open = false,
        };
    }

    pub fn update(self: *@This(), dt: f32) void {
        self.wing_timer += dt;

        if (self.wing_timer > c.WING_ANIM_TIME) {
            self.frame_index += 1;
            if (self.frame_index >= 7) self.frame_index = 0;
            self.wing_open = !self.wing_open;
            self.wing_timer = 0;
        }
    }

    pub fn deinit(self: *Renderer) void {
        rl.unloadRenderTexture(self.render_target);
        rl.unloadFont(self.font);
    }

    pub fn render(self: *Renderer, show_fps: bool) void {
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

        if (show_fps) {
            rl.drawFPS(10, 10);
        }

        rl.endDrawing();
    }

    pub fn beginGameDraw(self: *Renderer) void {
        rl.beginTextureMode(self.render_target);
        rl.clearBackground(Palette.black);
    }

    pub fn endGameDraw(_: *Renderer) void {
        rl.endTextureMode();
    }

    pub fn drawText(self: *@This(), text: [:0]const u8, mode: DrawMode, y: usize, color: rl.Color) void {
        const y_px = self.grid.pos(0, y).y;

        const x_px = switch (mode) {
            .centered => blk: {
                const text_width = rl.measureTextEx(self.font, text, c.SCALED_FONT_SIZE, 0).x;
                break :blk (@as(f32, @floatFromInt(c.TARGET_W)) - text_width) / 2.0;
            },
            .absolute => |x| self.grid.pos(x, y).x,
        };

        rl.drawTextEx(self.font, text, rl.Vector2{ .x = x_px, .y = y_px }, c.SCALED_FONT_SIZE, 0, color);
    }

    pub fn drawSprite(self: *@This(), sprite: Sprite, pos: rl.Vector2) void {
        // const frame = sprite.getIdle(self.wing_open);
        const frame = sprite.getFrame(self.frame_index);

        const scale: f32 = @floatFromInt(c.SSAA_FACTOR * 2);
        const dest = rl.Rectangle{
            .x = pos.x,
            .y = pos.y,
            .width = frame.source.width * scale,
            .height = frame.source.height * scale,
        };
        rl.drawTexturePro(sprite.texture, frame.source, dest, rl.Vector2{ .x = 0, .y = 0 }, 0, Palette.white);
    }
};

const DrawMode = union(enum) {
    centered,
    absolute: usize,
};
