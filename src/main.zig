const std = @import("std");
const rl = @import("raylib");

const c = @import("constants.zig");
const Game = @import("game.zig").Game;
const Renderer = @import("renderer.zig").Renderer;

pub fn main() !void {
    rl.initAudioDevice();
    rl.initWindow(c.INITIAL_WIDTH, c.INITIAL_HEIGHT, c.TITLE);
    defer rl.closeWindow();

    rl.setWindowState(rl.ConfigFlags{ .window_resizable = true });

    var renderer = try Renderer.init();
    defer renderer.deinit();

    var game = try Game.init(&renderer);
    defer game.deinit();

    // Main game loop
    while (!rl.windowShouldClose()) {
        const dt = rl.getFrameTime();
        game.update(dt);

        {
            renderer.beginGameDraw();
            defer renderer.endGameDraw();

            game.draw(&renderer);
        }
        renderer.render(game.flags.show_fps);
    }
}
