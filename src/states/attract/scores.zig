pub const Scores = struct {
    pub fn init() @This() {
        return .{};
    }
    pub fn update(_: *@This(), _: f32) void {}
    pub fn draw(_: @This()) void {}
};
