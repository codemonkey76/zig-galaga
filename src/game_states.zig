const Attract = @import("states/attract.zig").Attract;
const Intro = @import("states/intro.zig").Intro;
const Credit = @import("states/credit.zig").Credit;
const Play = @import("states/play.zig").Play;
const Sprites = @import("sprites.zig").Sprites;

pub const GameState = enum {
    attract,
    intro,
    credit,
    play,
};

pub const GameStates = struct {
    attract: Attract,
    intro: Intro,
    credit: Credit,
    play: Play,

    pub fn init(sprites: *const Sprites) @This() {
        return .{
            .attract = Attract.init(sprites),
            .intro = Intro.init(),
            .credit = Credit.init(),
            .play = Play.init(),
        };
    }
};
