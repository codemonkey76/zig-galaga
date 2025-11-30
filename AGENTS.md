# AGENTS.md

## Project Overview

This is a Galaga clone implementation in Zig using the raylib game framework. The project is in early development with basic HUD, starfield, and attract mode scaffolding.

**Language**: Zig 0.15.2  
**Framework**: raylib-zig (version 5.6.0-dev from devel branch)  
**Build System**: Zig's native build system (build.zig)

## Essential Commands

### Build & Run

```bash
# Build the project
zig build

# Run the game
zig build run

# Build with release optimizations
zig build --release=fast    # Optimize for speed
zig build --release=safe    # Optimize with safety checks
zig build --release=small   # Optimize for size
```

### Testing

```bash
# Run all tests
zig build test
```

### Cleaning

```bash
# Remove build artifacts
rm -rf zig-cache/ zig-out/
```

## Project Structure

```
zig-galaga/
├── build.zig           # Build configuration
├── build.zig.zon       # Dependency manifest
├── src/
│   ├── main.zig        # Entry point with game loop
│   ├── game.zig        # Main Game struct coordinating all systems
│   ├── game_states.zig # State enum and state container struct
│   ├── game_data.zig   # Game data (scores, credits)
│   ├── renderer.zig    # Rendering system with SSAA and letterboxing
│   ├── constants.zig   # All game constants
│   ├── palette.zig     # Color definitions
│   ├── flags.zig       # Runtime flags (show_fps, etc.)
│   ├── grid.zig        # Text grid positioning system
│   ├── hud.zig         # HUD rendering (scores)
│   ├── score.zig       # Score type with formatting
│   ├── starfield.zig   # Animated background starfield
│   ├── states/         # Game state implementations
│   │   ├── attract.zig      # Attract mode coordinator
│   │   ├── attract/
│   │   │   ├── info.zig     # Info screen (mostly stubbed)
│   │   │   ├── demo.zig     # Demo playback (stubbed)
│   │   │   └── scores.zig   # High scores screen (stubbed)
│   │   ├── intro.zig        # Intro state (stubbed)
│   │   ├── credit.zig       # Credit insertion state (stubbed)
│   │   └── play.zig         # Gameplay state (stubbed)
│   └── assets/
│       ├── fonts/           # arcade.ttf font
│       ├── sounds/          # Audio assets
│       └── sprites.png      # Sprite atlas
```

## Code Architecture

### Rendering System

The game uses a sophisticated multi-pass rendering approach:

1. **Logical Resolution**: 224x3 × 288x3 (672×864) - the "virtual" game resolution
2. **SSAA (Super-Sample Anti-Aliasing)**: 4× factor = 2688×3456 render target
3. **Letterboxing**: Final render scales to fit window while preserving aspect ratio

**Key Flow**:

- All game drawing happens to `renderer.render_target` at SSAA resolution
- `Renderer.render()` scales down and letterboxes to actual window size
- Use `renderer.beginGameDraw()` / `renderer.endGameDraw()` around game drawing
- Font and text measurements use `SCALED_FONT_SIZE` (not `FONT_SIZE`)

### State Machine

Game states are managed through an enum-based state machine:

```zig
pub const GameState = enum {
    attract, intro, credit, play
};
```

- `Game.current_state` holds the active state
- `Game.states` holds all state instances (allocated once at init)
- State-specific `update(dt)` and `draw(r)` called via switch statement in `game.zig`
- The attract mode has its own internal sub-state machine (info → demo → scores)

### Grid System

Text positioning uses a character-based grid system:

- `Grid.init()` measures font dimensions to determine cell size
- `Grid.pos(col, row)` converts grid coordinates to pixel positions
- Accounts for margins defined in `constants.zig`
- Used by HUD for consistent text layout

### Coordinate Systems

Be mindful of coordinate space conversions:

- **Logical coords**: Used for game logic (starfield, etc.) - 672×864
- **SSAA coords**: Render target resolution - 2688×3456  
  Convert: `logical * c.SSAA_FACTOR`
- **Window coords**: Actual window size (can vary)
  Handled automatically by `Renderer.render()`

## Code Conventions

### Naming

- **Types**: PascalCase (`Game`, `Renderer`, `GameData`)
- **Functions**: camelCase (`init`, `update`, `draw`, `transitionMode`)
- **Constants**: UPPER_SNAKE_CASE (`LOGICAL_W`, `SSAA_FACTOR`, `MAX_STARS`)
- **Variables**: snake_case (`render_target`, `current_state`, `hi_score`)
- **Private functions**: Mark with `fn` without `pub`

### Import Aliases

Standard import pattern:

```zig
const std = @import("std");
const rl = @import("raylib");
const c = @import("constants.zig");  // Note: imported as 'c'
```

Other modules typically imported by full name without alias.

### Struct Patterns

Common patterns observed:

```zig
pub const TypeName = struct {
    field1: Type1,
    field2: Type2,
    
    pub fn init() @This() {
        return .{
            .field1 = value1,
            .field2 = value2,
        };
    }
    
    pub fn update(self: *@This(), dt: f32) void {
        // Update logic
    }
    
    pub fn draw(self: @This(), r: *Renderer) void {
        // Drawing logic
    }
};
```

- `@This()` used for return types instead of repeating struct name
- `init()` returns by value (not pointer)
- `update()` takes mutable pointer `self: *@This()`
- `draw()` takes immutable copy `self: @This()` (unless needs mutation)
- `dt` is delta-time in seconds as `f32`

### Memory Management

- **No allocators used yet** - all data structures are fixed-size arrays or stack-allocated
- `defer` used consistently for cleanup (see `main.zig` with `defer rl.closeWindow()`)
- Renderer resources (`render_target`, `font`) cleaned up via `deinit()`
- Game struct currently has no `deinit()` - commented out in main.zig:19

### Error Handling

- Functions that can fail return error unions: `!Type`
- `try` used for error propagation
- `catch |err|` used when need to handle error (see `Renderer.init()`)
- Minimal error handling currently - project is early stage

### Constants Organization

All magic numbers live in `constants.zig`:

- Screen dimensions and scaling factors
- Font paths and sizes
- Grid margins
- Starfield parameters (speed, count, twinkle timing)

**Never hardcode these values elsewhere** - always reference from `c.*`

## Testing Approach

- Test framework configured in `build.zig` (lines 50-58)
- Tests added to `exe.root_module` so they can access all game code
- No tests written yet - project is in early development
- Test runner: `zig build test`

## Important Gotchas

### 1. SSAA Scaling

**All drawing must account for SSAA factor**:

```zig
// WRONG - uses logical size
rl.drawRectangle(x, y, 3, 3, color);

// CORRECT - scales by SSAA factor
const star_size_px = c.SSAA_FACTOR * c.STAR_SIZE_LOGICAL;
rl.drawRectangle(x, y, star_size_px, star_size_px, color);
```

Font rendering is particularly tricky - use `c.SCALED_FONT_SIZE` not `c.FONT_SIZE`.

### 2. Coordinate Space Conversions

When working with logical coordinates (like starfield), convert to SSAA before drawing:

```zig
const sx = star.x * c.SSAA_FACTOR;
const sy = star.y * c.SSAA_FACTOR;
rl.drawRectangle(@intFromFloat(sx), @intFromFloat(sy), ...);
```

### 3. Rectangle Y-Axis Flip

`SRC_RECT` in constants.zig has negative height (`-RT_H_F`) to flip the texture vertically for correct rendering. This is a raylib pattern for render textures.

### 4. Deferred Game Deinit

`game.deinit()` is commented out in main.zig:19. This is intentional as Game currently has no resources requiring cleanup. If you add heap allocations to Game, uncomment this and implement `deinit()`.

### 5. State Initialization

All state instances are created once in `GameStates.init()` and persist throughout the program. States should be designed to be reusable - implement `reset()` methods if needed (see `Info.reset()`).

### 6. Random Number Generation

The starfield uses `std.Random.DefaultPrng` seeded with timestamp:

```zig
var prng = std.Random.DefaultPrng.init(@intCast(std.time.timestamp()));
const random = prng.random();
```

Store the PRNG as a struct field, not just the random interface, so it maintains state.

### 7. Null-Terminated Strings

Font rendering requires `:0` null-terminated strings. When formatting:

```zig
var buf: [32:0]u8 = undefined;  // Note :0 in type
const text = data.score.format(&buf);  // Returns [:0]const u8
rl.drawTextEx(font, text, ...);
```

### 8. Raylib Try-Catch Pattern

Raylib bindings use Zig error unions. When multiple init functions can fail, clean up on error:

```zig
const render_target = try rl.loadRenderTexture(...);
const font = rl.loadFontEx(...) catch |err| {
    rl.unloadRenderTexture(render_target);  // Clean up already-allocated resource
    return err;
};
```

### 9. Integer/Float Conversions

Zig requires explicit conversions. Common patterns:

```zig
@floatFromInt(int_value)
@intFromFloat(float_value)
@as(f32, @floatFromInt(usize_value))  // Chain casts for non-standard int types
```

### 10. Switch Completeness

Zig requires exhaustive switches. Use `else => {}` for unimplemented states:

```zig
switch (self.current_state) {
    .attract => self.states.attract.update(dt),
    else => {},  // Other states not yet implemented
}
```

## Keyboard Controls (Current)

- **F11**: Toggle fullscreen
- **F3**: Toggle FPS display
- **ESC**: Quit (raylib default via windowShouldClose)

## Development Workflow

1. **Make changes** to source files
2. **Run immediately** with `zig build run` (builds automatically)
3. **Test changes** with `zig build test` when tests exist
4. **Check errors** - Zig compiler provides detailed error messages
5. **Iterate** - build times are fast, no separate compile step needed

## Future Agent Notes

### What's Stubbed/Incomplete

- Most state implementations are empty stubs (intro, credit, play, demo, scores)
- Info screen has commented-out drawing code (src/states/attract/info.zig:23-38)
- No gameplay logic yet
- No enemy entities, player ship, or collision detection
- No sound playback (audio device initialized but unused)
- Sprites loaded but not used (`sprites.png` exists in assets)

### Next Implementation Steps (Likely)

1. Complete attract mode info screen rendering
2. Implement player ship entity and movement
3. Add enemy formation system
4. Implement shooting mechanics
5. Add collision detection
6. Hook up sound effects
7. Implement high score persistence

### Adding New States

To add a new game state:

1. Create new file in `src/states/[state_name].zig`
2. Implement struct with `init()`, `update(dt)`, `draw(r)`
3. Add state to `GameState` enum in `game_states.zig`
4. Add field to `GameStates` struct and initialize in `init()`
5. Add case to switch statements in `game.zig` update/draw

### Adding New Constants

Add to `constants.zig` - never hardcode magic numbers. Use UPPER_SNAKE_CASE naming.

### Extending the Renderer

The Renderer is intentionally minimal. If adding helper drawing functions:

- Keep coordinate space conversions in mind
- Document whether functions expect logical or SSAA coords
- Consider adding to Grid for text-based helpers

## Dependencies

Only one external dependency:

- **raylib-zig** (v5.6.0-dev): Zig bindings for raylib game framework
  - Source: <https://github.com/raylib-zig/raylib-zig> (devel branch)
  - Provides windowing, rendering, input, audio
  - Defined in `build.zig.zon`

Zig's package manager fetches this automatically on first build.

## Build System Details

From `build.zig`:

- Creates executable named `zig_galaga`
- Imports raylib module as `"raylib"`
- Supports standard Zig target/optimize options
- Installs raylib artifact alongside executable
- Run step depends on install step (ensures up-to-date build)
- Supports passing arguments to executable via `zig build run -- args`

## File Permissions / Platform Notes

- No platform-specific code currently
- Should build on Windows, macOS, Linux (raylib is cross-platform)
- Assets loaded via relative paths from `src/assets/`
- No file I/O for game state persistence yet

## Comments & Documentation

Code is lightly commented. Generally:

- Complex logic has inline comments explaining "why"
- Simple/obvious code has no comments
- Struct fields are self-documenting via naming
- No doc comments (///) used yet

When adding features, follow existing style: comment intent, not mechanics.

## Performance Considerations

- SSAA rendering is expensive (4× resolution)
- Currently runs at full 60fps on modest hardware
- Main bottleneck will be entity count (when added)
- Consider spatial partitioning for collision detection
- Starfield is efficient - fixed array, no allocations

## Version Control

Git repository initialized. Current commits:

```
1d27dd1 Add HUD
e93c4b3 First commit
```

Standard gitignore excludes:

- `.zig-cache/` (Zig build cache)
- `zig-out/` (Build output directory)

## Additional Resources

- [Zig Language Reference](https://ziglang.org/documentation/master/)
- [raylib-zig Documentation](https://github.com/raylib-zig/raylib-zig)
- [raylib C API Reference](https://www.raylib.com/cheatsheet/cheatsheet.html) (Zig bindings closely mirror C API)

---

*This file should be updated as the project evolves. Future agents should add new patterns, gotchas, and conventions as discovered.*
