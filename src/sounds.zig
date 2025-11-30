const rl = @import("raylib");
const c = @import("constants.zig");

pub const Sounds = struct {
    explode: rl.Sound,
    shoot: rl.Sound,
    coin: rl.Sound,
    intro: rl.Sound,

    pub fn init() !@This() {
        const explode = try rl.loadSound(c.EXPLODE_SOUND);
        rl.playSound(explode);
        return .{
            .explode = explode,
            .shoot = try rl.loadSound(c.SHOOT_SOUND),
            .coin = try rl.loadSound(c.COIN_SOUND),
            .intro = try rl.loadSound(c.INTRO_SOUND),
        };
    }

    pub fn deinit(self: *@This()) void {
        self.explode.unload();
        self.shoot.unload();
        self.coin.unload();
        self.intro.unload();
    }
};
