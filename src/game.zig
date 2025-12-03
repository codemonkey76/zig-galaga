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
const InputManager = @import("input_manager.zig").InputManager;
const DivePaths = @import("dive_paths.zig").DivePaths;

pub const Game = struct {
    renderer: *Renderer,
    allocator: std.mem.Allocator,
    input: InputManager,
    audio: Sounds,
    flags: Flags,
    starfield: Starfield,
    states: gs.GameStates,
    current_state: gs.GameState,
    data: GameData,
    dive_paths: DivePaths,

    pub fn init(allocator: std.mem.Allocator, renderer: *Renderer) !@This() {
        const audio = try Sounds.init();

        const dive_paths = try DivePaths.init(allocator) catch |err| {
            audio.deinit();
            return err;
        };

        return .{
            .renderer = renderer,
            .allocator = allocator,
            .input = InputManager.init(allocator),
            .audio = audio,
            .flags = Flags.init(),
            .starfield = Starfield.init(),
            .states = gs.GameStates.init(&renderer.sprites),
            .current_state = gs.GameState.attract,
            .data = GameData.init(),
            .dive_paths = dive_paths,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.input.deinit();
        self.audio.deinit();
        self.dive_paths.deinit();
    }

    pub fn update(self: *Game, dt: f32) void {
        self.input.newFrame();
        self.handleGlobalInput() catch {};

        if (self.flags.paused) return;
        self.renderer.update(dt);
        self.starfield.update(dt);

        switch (self.current_state) {
            .attract => self.states.attract.update(dt),
            else => {},
        }
    }

    pub fn draw(self: @This(), r: *Renderer) void {
        rl.clearBackground(Palette.black);
        r.draw(self.flags);

        self.starfield.draw(r);
        self.dive_path_test.draw(r);

        // switch (self.current_state) {
        //     .attract => self.states.attract.draw(r),
        //     else => {},
        // }
    }

    fn handleGlobalInput(self: *@This()) !void {
        const i = &self.input;

        if (try i.isKeyPressed(rl.KeyboardKey.f11, true)) {
            rl.toggleFullscreen();
        }

        if (try i.isKeyPressed(rl.KeyboardKey.f3, true)) {
            self.flags.show_fps = !self.flags.show_fps;
        }

        if (try i.isKeyPressed(rl.KeyboardKey.p, true)) {
            self.flags.paused = !self.flags.paused;
        }

        if (try i.isKeyPressed(rl.KeyboardKey.g, true)) {
            self.flags.show_grid = !self.flags.show_grid;
        }

        if (try i.isKeyPressed(rl.KeyboardKey.five, true)) {
            if (self.data.credits < c.MAX_CREDITS) {
                self.data.credits += 1;
            }
            rl.playSound(self.audio.coin);
        }

        if (self.current_state != .play) {
            if (try i.isKeyPressed(rl.KeyboardKey.one, true) and self.data.credits >= 1) {
                self.data.credits -= 1;
                self.startGame(1);
            } else if (try i.isKeyPressed(rl.KeyboardKey.two, true) and self.data.credits >= 2) {
                self.data.credits -= 2;
                self.startGame(2);
            }
        }
    }

    fn startGame(self: *@This(), _: u8) void {
        rl.playSound(self.audio.intro);
    }
};
