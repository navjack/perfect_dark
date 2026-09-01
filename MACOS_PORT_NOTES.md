# macOS port notes — Perfect Dark (PC port)

**Built cleanly on the first attempt — no source changes were required.** This is a native PC port
with genuine upstream macOS support (arm64, macOS 11+), not an N64Recomp project. Installed as
`PerfectDark.app`; verified in-game with a live HUD.

## Build

```bash
cmake -G"Unix Makefiles" -Bbuild -DCMAKE_OSX_ARCHITECTURES=arm64 .
cmake --build build --target pd -j8
./tools/make_macos_app.sh
```

The upstream README asks you to install `SDL2.framework` into `/Library/Frameworks` with `sudo`.
That was already present on this machine, so no sudo step was needed; the bundler vendors the
framework into `Contents/Frameworks` so the installed app does not depend on it.

## ROM

Place the NTSC ROM as `pd.ntsc-final.z64` in a `data/` directory. The port resolves this via
`SDL_GetPrefPath("", "perfectdark")` (`port/src/system.c`), i.e.:

```
~/Library/Application Support/perfectdark/data/pd.ntsc-final.z64
```

That location is used deliberately so the signed bundle stays free of game data.

## About the OpenGL warnings

On startup the log prints `SDL: could not create GL3.0 context` followed by many
`GL: could not find function: gl*` lines. **These are expected and harmless.** The port tries a
ladder of GL versions (`port/fast3d/gfx_sdl2.cpp`); its first choice is a 3.0 *compatibility*
profile, which macOS does not provide, so it falls back to the 4.1 core profile — the entry the
code itself comments as "macs only have core profile and this is the latest". The missing
functions are legacy fixed-function entry points absent from any core profile.

## Changes made

**`tools/make_macos_app.sh`** (new) — the only addition. Bundles the binary, vendors
`SDL2.framework`, adds the `@executable_path/../Frameworks` rpath, and ad-hoc signs.
