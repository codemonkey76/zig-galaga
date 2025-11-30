pub const Flags = struct {
    show_fps: bool,

    pub fn init() @This() {
        return .{
            .show_fps = false,
        };
    }
};
