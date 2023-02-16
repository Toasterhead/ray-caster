# ray-caster
A ray-casting engine for rendering a texture-mapped, first-person view from a 2D map.

Coded in Lua for the TIC-80 fanstasy computer. Actual, executable source code is located in the rayCaster.tic cartridge file. A copy of the source is broken down into separate LUA files for convenience and organization.

This project aims to recreate, and continue from, a previous ray-casting engine (the \retro-ray-caster repository) which used the Monogame library. It instead targets the TIC-80, the idea being that this platform better suits the engine's intended retro aesthetic, and simulates resource limitations (in memory, display resolution, color palette, sound waveforms, etc.) that are arguably more historically accurate to its style.

The eventual goal is to produce a first-person view with the following features:

- Texture-mapped walls.
- Scalable, sprite-based characters and objects.
- Optional animations for the aforementioned.
- Dithered lighting--both distance-based and radiating from light sources--that applies to both walls and sprites.
- Transparency in wall textures.
- A (non-scaling) background texture that renders behind the furthest transparent wall, and which scrolls horizontally as the observer turns.
- The ability to render walls/sprites with 1-bit, 2-bit, or 4-bit color, and to swap palettes for 1-or-2-bit rendering.

Some compromises may be necessary due to memory limitations (64 kilobytes per cartridge bank for source code). The final body text of the completed engine will be "scrunched" into a less readable form to make room for coding actual gameplay.
