const Info = @import("attract/info.zig").Info;
const Demo = @import("attract/demo.zig").Demo;
const Scores = @import("attract/scores.zig").Scores;
const Renderer = @import("../renderer.zig").Renderer;
const Sprites = @import("../sprites.zig").Sprites;
const c = @import("../constants.zig");

const Mode = enum {
    info,
    demo,
    scores,
};

pub const Attract = struct {
    mode: Mode,
    timer: f32,
    info_mode: Info,
    demo_mode: Demo,
    scores_mode: Scores,

    pub fn init(sprites: Sprites) @This() {
        return .{
            .mode = .info,
            .timer = 0,
            .info_mode = Info.init(sprites),
            .demo_mode = Demo.init(),
            .scores_mode = Scores.init(),
        };
    }

    pub fn update(self: *@This(), dt: f32) void {
        self.timer += dt;

        var duration: f32 = 0.0;

        switch (self.mode) {
            .info => {
                duration = c.INFO_DURATION;
                self.info_mode.update(dt);
            },
            .demo => {
                duration = c.DEMO_DURATION;
                self.demo_mode.update(dt);
            },
            .scores => {
                duration = c.SCORES_DURATION;
                self.scores_mode.update(dt);
            },
        }

        if (self.timer >= duration) {
            self.transitionMode();
        }
    }

    pub fn draw(self: @This(), r: *Renderer) void {
        switch (self.mode) {
            .info => self.info_mode.draw(r),
            else => {},
        }
    }

    fn transitionMode(self: *@This()) void {
        self.timer = 0;

        // Don't transition while we are working on the info screen.

        // self.mode = switch (self.mode) {
        //     .info => .demo,
        //     .demo => .scores,
        //     .scores => .info,
        // };
    }
};
