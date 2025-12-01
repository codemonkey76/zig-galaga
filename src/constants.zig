const rl = @import("raylib");

pub const LOGICAL_W: i32 = 224 * 3;
pub const LOGICAL_H: i32 = 288 * 3;
pub const SSAA_FACTOR: i32 = 4;
pub const TARGET_W: i32 = LOGICAL_W * SSAA_FACTOR;
pub const TARGET_H: i32 = LOGICAL_H * SSAA_FACTOR;
pub const CENTER_X: i32 = TARGET_W / 2;
pub const CENTER_Y: i32 = TARGET_H / 2;
pub const INITIAL_WIDTH: i32 = 1280;
pub const INITIAL_HEIGHT: i32 = 720;
pub const TITLE = "Galaga Clone";

pub const LOGICAL_W_F: f32 = @floatFromInt(LOGICAL_W);
pub const LOGICAL_H_F: f32 = @floatFromInt(LOGICAL_H);

pub const RT_W: i32 = LOGICAL_W * SSAA_FACTOR;
pub const RT_H: i32 = LOGICAL_H * SSAA_FACTOR;

pub const RT_W_F: f32 = @floatFromInt(RT_W);
pub const RT_H_F: f32 = @floatFromInt(RT_H);

pub const SRC_RECT = rl.Rectangle{
    .x = 0,
    .y = 0,
    .width = RT_W_F,
    .height = -RT_H_F,
};

pub const FONT = "src/assets/fonts/arcade.ttf";
pub const FONT_SIZE: i32 = 24;
pub const SCALED_FONT_SIZE: i32 = FONT_SIZE * SSAA_FACTOR;
pub const GRID_MARGIN_Y: f32 = 8.0;
pub const GRID_MARGIN_X: f32 = 8.0;

// Starfield constants
pub const MAX_STARS = 100;
pub const TWINKLE_MIN = 0.5;
pub const TWINKLE_MAX = 1.0;
pub const STAR_SPEED = 60.0;
pub const STAR_SPEED_RANDOMNESS = 40.0;
pub const STAR_SIZE_LOGICAL = 3;

// Assets
pub const EXPLODE_SOUND = "src/assets/sounds/explode.wav";
pub const SHOOT_SOUND = "src/assets/sounds/shoot.mp3";
pub const COIN_SOUND = "src/assets/sounds/coin.mp3";
pub const INTRO_SOUND = "src/assets/sounds/intro.mp3";

pub const MAX_CREDITS = 99;

// State Timers.
pub const INFO_DURATION = 5.0;
pub const DEMO_DURATION = 5.0;
pub const SCORES_DURATION = 5.0;

pub const INFO_DELAY = 1.0;

pub const SPRITE_SHEET = "src/assets/sprites.png";

pub const WING_ANIM_TIME = 0.5;
