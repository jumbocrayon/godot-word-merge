# Word Merge — Game Design Document

*Deliberately small. A GDD for a tutorial project should fit in your head.*

## 1. High concept

A single-screen word puzzle. Each level shows a **static image** and a rack of
**random word tiles**. The player **merges** tiles to form compound words
("sun" + "flower" → "sunflower") and drags words into six **caption slots**
under the image. When the six slots form a valid caption for the image, the
level is won. **Coins** buy **connector words** ("and", "or", "of") that make
awkward captions grammatical.

## 2. Core loop

1. Look at the image. ("A dog sleeping in sunflowers.")
2. Scan the rack of ~10 random word tiles.
3. Drag one tile onto another. If the pair forms a known compound word, they
   **merge** into a single new tile; otherwise they bounce apart.
4. Drag finished words into any of the 6 caption slots (reorder freely).
5. Optionally spend coins on a connector tile from the shop strip.
6. Press **Submit**. If the caption matches one of the level's accepted
   captions, win → earn coins → next level.

## 3. Rules

### Tiles
- A tile shows one word. Tiles live in the **rack** (bottom of screen) or in a
  **caption slot** (under the image).
- Merging: drop tile A onto tile B. Valid if `A.word + B.word` (in that order)
  is in the level's merge dictionary. The result is one tile with the compound
  word. Invalid merges do nothing (with visual feedback).
- Merges can chain: "sun" + "flower" → "sunflower"; no un-merge in v1.

### Caption
- Exactly **6 slots**. All six must be filled to submit.
- The level defines 1–3 accepted captions (exact word sequences). v1 checks
  exact match; fuzzy/semantic matching is explicitly out of scope.

### Economy
- Win a level: **+10 coins**, minus 1 per merge attempt that failed (floor 3).
- Connector tiles ("and" = 2 coins, "or" = 2 coins, "of" = 3 coins) can be
  bought any time from a shop strip and placed like normal tiles.
- Coins persist across levels (saved to disk in the final phase).

### Level definition (data, not code)
Each level is a data file containing:
- image path
- rack words (the random starting tiles)
- merge dictionary (`"sun"+"flower" = "sunflower"`, …)
- accepted captions (arrays of 6 words)
- par (target number of merges, for future star ratings — not scored in v1)

## 4. Screens

1. **Level screen** (the game — 95% of the work)
   - Top ⅔: the image, level number, coin counter.
   - Middle: 6 caption slots in a row.
   - Bottom: word rack (wrapping grid), shop strip, Submit button.
2. **Win overlay**: "Caption complete!", coins earned, Next Level button.
3. *(stretch)* Level select.

## 5. Content plan for v1

Three levels, images from this repo or CC0 sources:
1. Tutorial level: 8 tiles, 1 forced merge, no connectors needed.
2. 10 tiles, 2 merges, one connector makes it much easier.
3. 12 tiles, 3 merges including a chain, connector required.

## 6. Explicitly out of scope (v1)

Timer, hints, animations beyond basic tweens, sound design beyond 2–3 SFX,
mobile input, localization, un-merging tiles, semantic caption matching.
