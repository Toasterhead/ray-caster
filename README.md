# Ray Caster
A ray casting engine for rendering a texture-mapped, first-person view from a 2D map. Currently a work in progress.

### Development Environment

Coded in Lua for the [TIC-80](https://tic80.com/)  fanstasy computer. Actual, executable source code is located in the *rayCaster.tic* cartridge file. A copy of the source is broken down into separate LUA files for convenience and organization.

### Objective

This project aims to create a rendering engine in the style of early "Pre-*Doom*" first person games (e.g., *Wolfenstein 3D*, *Pathways into Darkness*, *Faceball 2000*) with the following features:

- Texture-mapped walls.
- Scalable, sprite-based characters and objects.
- Optional animations sprites and walls.
- Optional auto-generated black outline for sprites.
- Dithered lighting--based on distance from the observer or other light source--that applies to walls and sprites.
- Transparency in wall textures.
- A background image that renders behind the furthest transparent wall and scrolls horizontally as the observer turns.
- The ability to render individual walls/sprites with 1, 2, or 4-bit color, and to alternate palettes for 1 or 2-bit rendering.

### Current Progress

The engine is able to render walls in with textures and dithering. Some subtle fish-eye warping occurs. All three color depths are working.

Some screenshots can be seen below. A more nitty-gritty description of the engine follows.

### Images

<details>

![Ray Caster - First Person View](https://github.com/Toasterhead/ray-caster/blob/master/Screen%20Captures/Ray%20Caster%20-%20First%20Person%20View.PNG?raw=true)

![Ray Caster - Overhead View](https://github.com/Toasterhead/ray-caster/blob/master/Screen%20Captures/Ray%20Caster%20-%20Overhead%20View%203.PNG?raw=true)

![Ray Caster - First Person Dithering](https://github.com/Toasterhead/ray-caster/blob/master/Screen%20Captures/Ray%20Caster%20-%20First%20Person%20Dithering.PNG?raw=true)

![Ray Caster - Overhead Dithering](https://github.com/Toasterhead/ray-caster/blob/master/Screen%20Captures/Ray%20Caster%20-%20Overhead%20Dithering.PNG?raw=true)

![Ray Caster - Test Textures](https://github.com/Toasterhead/ray-caster/blob/master/Screen%20Captures/Ray%20Caster%20-%20Test%20Textures.PNG?raw=true)
</details>

### Technique

<details>

This section broadly explains how the final engine should hypothetically operate, and may be revised as development progresses.

##### Basic 2D Ray Casting

Walls are projected using using the traditional ray casting method. A series of 2D vectors (rays) are "cast" in a range of angles (representing a cone of vision) from an observer on a 2D map. When a ray intersects with a line segment representing a wall, the distance between the observer and the point of intersection determines the vertical length of a column of pixels to be rendered to the screen, with the column's horizontal placement corresponding to the angle of that particular ray.

##### Texture Mapping

If a line segment represents a wall, then the distance between one of its endpoints and the point of intersection, as a ratio of its total length, can be used to determine which column of pixels to "grab" from the source texture.

##### Lighting

Since the intersection's distance from the observer is now known, it can be used to apply a lighting effect where darkness increases with distance. This creates the impression that the observer is carrying a lamp. A similar concept can be applied using the intersection's distance from some point on the map defined as a light source.

Because the color pallette is very limited, darkness is represented by applying a dithering pattern to the pixel column.

##### Transparency and Background

If the intersected wall is marked as having transparency (i.e. pixels of a specified color are not to be rendered) then the ray may continue traversing until another intersection is discovered. This allows walls to be visible behind other walls, for example, through a window or grating. If the final intersected wall is transparent and the ray has exceeded its maximum draw distance, then the transparent pixels in the column can be filled in with a backgound texture.

##### Scaling Images

The TIC-80 has no inherent capability for drawing arbitrarily scaled images, but it does store the color of pixels for sprites/tiles (which serve as the source textures) in [addressable RAM](https://github.com/nesbox/TIC-80/wiki/RAM). To draw scaled sprites and pixel columns, a routine must be established for retrieving the appropriate address based on the position of a pixel to be rendered in the scaled image.

##### Color Palette and Memory Limitations

RAM for storing images on the cartridge is [limited](https://github.com/nesbox/TIC-80/wiki/RAM), but more images can be stored with a reduced color bit depth. For example, if an address stores the 4-bit value 0111 (7 in decimal) then the color value at index 7 will be used for that pixel (from a palette of 16 possible colors). However, if it's divided into a pair of 2-bit values, 01 and 11, it can now represent two pixels with color indices 1 and 3 (with the palette reduced to 4 possible colors).

A 4-color palette is pretty restrictive, but the entire screen needn't be rendered in 2-bit color. When the 2-bit image is drawn, an ordered list of 4 integers can be provided as a parameter, re-mapping the 4 possible colors to any of the 16 colors available in the grand palette. A similar technique can also be applied to 1-bit color.
</details>
