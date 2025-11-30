const std = @import("std");
const rl = @import("raylib");

const Renderer = @import("renderer.zig").Renderer;
const Flags = @import("flags.zig").Flags;
const Palette = @import("palette.zig").Palette;
const GameData = @import("game_data.zig").GameData;
const Starfield = @import("starfield.zig").Starfield;
const gs = @import("game_states.zig");

pub const Game = struct {
    renderer: *Renderer,
    flags: Flags,
    starfield: Starfield,
    states: gs.GameStates,
    current_state: gs.GameState,
    data: GameData,

    pub fn init(renderer: *Renderer) @This() {
        return .{
            .renderer = renderer,
            .flags = Flags.init(),
            .starfield = Starfield.init(),
            .states = gs.GameStates.init(),
            .current_state = gs.GameState.attract,
            .data = GameData.init(),
        };
    }

    pub fn update(self: *Game, dt: f32) void {
        self.starfield.update(dt);
        if (rl.isKeyPressed(rl.KeyboardKey.f11)) {
            rl.toggleFullscreen();
        }

        if (rl.isKeyPressed(rl.KeyboardKey.f3)) {
            self.flags.show_fps = !self.flags.show_fps;
        }

        switch (self.current_state) {
            .attract => self.states.attract.update(dt),
            else => {},
        }
    }

    pub fn draw(self: @This(), r: *Renderer) void {
        rl.clearBackground(Palette.black);

        self.starfield.draw(r);
        // self.hud.draw(r, self.data);

        switch (self.current_state) {
            .attract => self.states.attract.draw(r),
            else => {},
        }
    }
};
