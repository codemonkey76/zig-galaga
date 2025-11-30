const Score = @import("score.zig").Score;

pub const GameData = struct {
    hi_score: Score,
    p1_score: Score,
    p2_score: Score,
    credits: u32,
    pub fn init() @This() {
        return .{
            .hi_score = Score.init(20000),
            .p1_score = Score.init(0),
            .p2_score = Score.init(0),
            .credits = 0,
        };
    }
};
