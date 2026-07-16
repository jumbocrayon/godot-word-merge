# Word Merge — a learn-by-doing Godot tutorial project

This folder is a **tutorial workspace**, not a finished demo. You will build the
game yourself, phase by phase, using the other demos in this repository as
reference material.

## The game in one sentence

Each level shows a static image; you merge random word tiles into compound
words and arrange six of them into a caption that describes the image, spending
coins on connector words ("and", "or", "of") to glue phrases together.

## What's in this folder

| File | Purpose |
| --- | --- |
| `GDD.md` | The game design document — *what* you are building. |
| `LEARNING_PLAN.md` | Seven phases, each ending with something playable — *in what order* you build it. |
| `CURRICULUM.md` | Every concept you'll touch, labeled **[Godot]** or **[GameDev]** — *what you are learning* along the way. |
| `project.godot` | A pre-configured empty project so this folder appears in the Godot Project Manager. |

## How to start

1. Install **Godot 4.6** (standard build, not .NET) from https://godotengine.org/download.
2. Open the Godot **Project Manager**, click **Scan**, and point it at the root
   of this repository. Every demo — including this one — appears in the list.
3. Open **Word Merge (Tutorial)**. It's empty on purpose; the first time you
   press <kbd>F5</kbd> Godot will ask you to pick a main scene. You'll create
   that scene in Phase 1 of `LEARNING_PLAN.md`.
4. Read `GDD.md` (10 minutes), skim `CURRICULUM.md`, then work through
   `LEARNING_PLAN.md` top to bottom.

## Reference demos you'll lean on

These live in this same repository, so you can open them side by side:

- [`gui/drag_and_drop`](../../gui/drag_and_drop/) — the exact drag-and-drop API
  you'll use for merging tiles (~30 lines of code total; read it early).
- [`gui/control_gallery`](../../gui/control_gallery/) — a tour of every UI
  widget. Run it once just to see what exists.
- [`2d/dodge_the_creeps`](../dodge_the_creeps/) — the canonical "first Godot
  game": scenes, signals, instancing, a HUD.
- [`2d/tween`](../tween/) — animation-by-code, used for merge/snap polish.
- [`gui/theming_override`](../../gui/theming_override/) — restyling UI widgets.
- [`gui/multiple_resolutions`](../../gui/multiple_resolutions/) — why the
  stretch settings in `project.godot` are set the way they are.

## The one rule

Type the code yourself. Copy-pasting from the demos defeats the purpose — the
demos are for *reading* when you're stuck or curious how the pros structured it.
