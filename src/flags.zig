pub const Flags = struct {
    show_fps: bool,
    show_grid: bool,
    paused: bool,

    pub fn init() @This() {
        return .{
            .show_fps = false,
            .show_grid = false,
            .paused = false,
        };
    }
};
