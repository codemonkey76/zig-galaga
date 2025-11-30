const rl = @import("raylib");

const Palette = @import("palette.zig").Palette;
const c = @import("constants.zig");

pub const Renderer = struct {
    render_target: rl.RenderTexture,
    font: rl.Font,

    pub fn init() !@This() {
        const render_target = try rl.loadRenderTexture(c.TARGET_W, c.TARGET_H);

        const font = rl.loadFontEx(c.FONT, c.SCALED_FONT_SIZE, null) catch |err| {
            rl.unloadRenderTexture(render_target);
            return err;
        };

        return .{
            .render_target = render_target,
            .font = font,
        };
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
};
