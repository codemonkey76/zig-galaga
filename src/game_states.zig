const Attract = @import("states/attract.zig").Attract;
const Intro = @import("states/intro.zig").Intro;
const Credit = @import("states/credit.zig").Credit;
const Play = @import("states/play.zig").Play;

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

    pub fn init() @This() {
        return .{
            .attract = Attract.init(),
            .intro = Intro.init(),
            .credit = Credit.init(),
            .play = Play.init(),
        };
    }
};
