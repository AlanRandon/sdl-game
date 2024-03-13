const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn main() !void {
    const subsystems = sdl.SDL_INIT_VIDEO | sdl.SDL_INIT_EVENTS | sdl.SDL_INIT_TIMER | sdl.SDL_INIT_AUDIO;
    if (sdl.SDL_Init(subsystems) != 0) {
        panic();
    }
    defer sdl.SDL_Quit();

    const window = sdl.SDL_CreateWindow(
        "SDL Test",
        sdl.SDL_WINDOWPOS_UNDEFINED,
        sdl.SDL_WINDOWPOS_UNDEFINED,
        100,
        100,
        sdl.SDL_WINDOW_RESIZABLE | sdl.SDL_WINDOW_SHOWN,
    ) orelse panic();
    defer _ = sdl.SDL_DestroyWindow(window);

    const renderer = sdl.SDL_CreateRenderer(window, -1, sdl.SDL_RENDERER_ACCELERATED) orelse panic();
    defer _ = sdl.SDL_DestroyRenderer(renderer);

    _ = sdl.SDL_RenderClear(renderer);
    sdl.SDL_RenderPresent(renderer);

    var event: sdl.SDL_Event = undefined;
    while (true) {
        _ = sdl.SDL_PollEvent(@as([*c]sdl.SDL_Event, &event));

        switch (event.type) {
            sdl.SDL_QUIT => break,
            sdl.SDL_WINDOWEVENT => {
                if (event.window.event == sdl.SDL_WINDOWEVENT_RESIZED) {
                    sdl.SDL_RenderPresent(renderer);
                }
            },
            sdl.SDL_KEYUP => {
                if (event.key.keysym.scancode == sdl.SDL_SCANCODE_ESCAPE) {
                    break;
                }
            },
            else => {},
        }
    }
}

fn panic() noreturn {
    const str = @as(?[*:0]const u8, sdl.SDL_GetError()) orelse "unknown error";
    std.debug.panic("Panic! {s}", .{str});
}
