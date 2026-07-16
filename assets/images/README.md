# Level images

One image per level, named `level_<n>.png` (or `.webp`/`.jpg` — Godot imports
all of them).

- `level_1.png` — currently a generated sky/field placeholder. **Replace it
  with the real level 1 image, keeping the same filename**, and
  `scenes/level.tscn` picks it up automatically.

Guidelines for level images:

- Landscape orientation works best with the Phase 1 layout (the `Picture`
  TextureRect sits between the top bar and the caption row and expands to
  fill leftover vertical space).
- Any resolution is fine — the TextureRect is set to *Expand: Ignore Size /
  Stretch: Keep Aspect Centered*, so the image scales without distortion.
- The image should be describable by a 6-word caption built from the level's
  word list (see `GDD.md`).
