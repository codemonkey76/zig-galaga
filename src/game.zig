const std = @import("std");
const rl = @import("raylib");

const Renderer = @import("renderer.zig").Renderer;
const Flags = @import("flags.zig").Flags;
const Palette = @import("palette.zig").Palette;
const GameData = @import("game_data.zig").GameData;
const Starfield = @import("starfield.zig").Starfield;
const Hud = @import("hud.zig").Hud;
const Sounds = @import("sounds.zig").Sounds;
const Sprites = @import("sprites.zig").Sprites;
const gs = @import("game_states.zig");
const c = @import("constants.zig");

pub const Game = struct {
    renderer: *Renderer,
    audio: Sounds,
    sprites: Sprites,
    flags: Flags,
    starfield: Starfield,
    states: gs.GameStates,
    current_state: gs.GameState,
    data: GameData,

    pub fn init(renderer: *Renderer) !@This() {
        const sprites = try Sprites.init();

        const audio = Sounds.init() catch |err| {
            sprites.deinit();
            return err;
        };

        return .{
            .renderer = renderer,
            .audio = audio,
            .sprites = sprites,
            .flags = Flags.init(),
            .starfield = Starfield.init(),
            .states = gs.GameStates.init(sprites),
            .current_state = gs.GameState.attract,
            .data = GameData.init(),
        };
    }

    pub fn deinit(self: *@This()) void {
        self.audio.deinit();
        self.sprites.deinit();
    }

    pub fn update(self: *Game, dt: f32) void {
        self.renderer.update(dt);
        self.starfield.update(dt);
        self.handleGlobalInput();

        switch (self.current_state) {
            .attract => self.states.attract.update(dt),
            else => {},
        }
    }

    pub fn draw(self: @This(), r: *Renderer) void {
        rl.clearBackground(Palette.black);

        self.starfield.draw(r);
        Hud.draw(r, self.data);

        switch (self.current_state) {
            .attract => self.states.attract.draw(r),
            else => {},
        }
    }

    fn handleGlobalInput(self: *@This()) void {
        if (rl.isKeyPressed(rl.KeyboardKey.f11)) {
            rl.toggleFullscreen();
        }

        if (rl.isKeyPressed(rl.KeyboardKey.f3)) {
            self.flags.show_fps = !self.flags.show_fps;
        }

        if (rl.isKeyPressed(rl.KeyboardKey.five)) {
            if (self.data.credits < c.MAX_CREDITS) {
                self.data.credits += 1;
            }
            rl.playSound(self.audio.coin);
        }

        if (self.current_state != .play) {
            if (rl.isKeyPressed(rl.KeyboardKey.one) and self.data.credits >= 1) {
                self.data.credits -= 1;
                self.startGame(1);
            } else if (rl.isKeyPressed(rl.KeyboardKey.two) and self.data.credits >= 2) {
                self.data.credits -= 2;
                self.startGame(2);
            }
        }
    }

    fn startGame(self: *@This(), _: u8) void {
        rl.playSound(self.audio.intro);
    }
};
