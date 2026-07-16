# Word Merge — Curriculum

Everything you'll learn while building this game, split into two tracks:

- **Track A — Godot concepts:** engine-specific. If you switched to Unity or
  Unreal tomorrow, these would look different (though most have an equivalent).
- **Track B — General game dev concepts:** engine-agnostic. These transfer
  everywhere, including to your Unity project.

The distinction matters because tutorials usually blur them together, and then
you can't tell whether you're learning "games" or learning "this engine."
Phases refer to `LEARNING_PLAN.md`.

---

## Track A — Godot concepts

### A1. Nodes and the scene tree *(Phase 0–1)*
Godot's core idea. **Everything is a node**, and a running game is one big tree
of nodes. Unlike Unity's GameObject+Components, a Godot node *is* its behavior:
a `Button` node is a button, a `Label` node is text. You compose functionality
by **nesting** nodes rather than stacking components on one object. The tree
structure is meaningful: children move with parents, are drawn relative to
them, and are freed with them.
> See it: any demo's Scene dock. Docs: "Nodes and scene instances".

### A2. Scenes as reusable building blocks *(Phase 0, 2)*
A **scene** (`.tscn`) is a saved subtree — Godot's prefab, except there is no
separate concept: your whole game, a level, and a single word tile are all just
scenes. Scenes instance other scenes; `WordTile` instanced 10× inside `Level`
is the pattern. Rule of thumb: if you'll need more than one, or want to edit it
in isolation, make it a scene.
> See it: `hud.tscn` inside `main.tscn` in `2d/dodge_the_creeps`.

### A3. GDScript *(Phase 1+)*
Python-flavored scripting language, one script per node (a script *extends* a
node type). What you actually need: `func`, `var`, optional static typing
(`var x: int`, encouraged — this project enables the untyped-declaration
warning), `@export` to surface a variable in the Inspector, `_ready()` (≈
`Start()`), `_process(delta)` (≈ `Update()` — you barely need it in this game),
`$Path/To/Node` and `%UniqueName` to grab nodes, `preload()` for compile-time
resource loading.

### A4. Signals *(Phase 1, 3, 6)*
Godot's built-in observer pattern and its main decoupling tool. Built-in ones
(`Button.pressed`) you connect in the editor or in code; custom ones you
declare with `signal` and fire with `emit()`. The architecture rule this game
drills: **signal up, call down** — a child never reaches up to grab its parent;
it emits, and whoever cares connects.
> See it: `start_game` in `2d/dodge_the_creeps/hud.gd`.

### A5. Control nodes, anchors, and containers *(Phase 1–2)*
The UI system — this game is ~90% UI, which is why it teaches Godot UI better
than a platformer would. Two families of visible nodes exist: `Node2D` (game
world, freely positioned — sprites, physics) and `Control` (UI, laid out by
rules). Word Merge is almost pure `Control`. Layout comes from **anchors**
(pin edges to fractions of the parent) and, more usefully, **containers**
(`VBoxContainer`, `HBoxContainer`, `HFlowContainer`, `MarginContainer`,
`CenterContainer`, `PanelContainer`) that position children automatically.
Fight the urge to place UI by pixel coordinates; let containers do it.
> See it: `gui/control_gallery` is built entirely from containers.

### A6. Sprite2D vs. TextureRect *(Phase 1)*
Both draw an image. `Sprite2D` is a `Node2D` for game-world objects;
`TextureRect` is a `Control` that participates in UI layout. Your level image
sits inside a `VBoxContainer`, so it must be a `TextureRect`. Picking the right
family for each job is a small decision you'll make constantly in Godot.

### A7. Instancing at runtime *(Phase 2)*
`preload("res://word_tile.tscn")` → `.instantiate()` → `add_child()`. The
spawn-anything pattern (Unity's `Instantiate`), plus `queue_free()` for safe
deferred deletion (never free a node mid-signal-handler with `free()`).
> See it: mob spawning in `2d/dodge_the_creeps/main.gd`.

### A8. Drag and drop *(Phase 3)*
Control nodes get a complete drag-and-drop framework via three overridable
methods: `_get_drag_data()`, `_can_drop_data()`, `_drop_data()`. The engine
does the mouse tracking, preview-following, and target resolution. This is the
whole core mechanic of Word Merge in three functions.
> See it: `gui/drag_and_drop/drag_drop_script.gd` — read all 33 lines.

### A9. Resources and `.tres` files *(Phase 5)*
**Resources** are Godot's data containers — textures and fonts are resources,
and you can define your own (`LevelData`). Saved as `.tres` files, edited in
the Inspector, loaded with `load()`/`preload()`. This is Godot's answer to
Unity's ScriptableObject, and the key to data-driven levels.

### A10. Autoloads *(Phase 6)*
A script or scene registered in Project Settings to exist for the whole game
session, accessible from anywhere by name — Godot's blessed singleton. Correct
use: small cross-scene state (coins, settings, save/load). Classic misuse:
turning it into a god object. Word Merge keeps exactly one.

### A11. Filesystem: `res://` and `user://`, `FileAccess` *(Phase 5–6)*
`res://` = your project files, read-only in exported games. `user://` = a
per-user writable folder for saves and settings. `FileAccess` +
`JSON.stringify()/parse_string()` covers simple persistence.

### A12. Tweens *(Phase 3, 7)*
`create_tween()` animates any property over time in one line of code — the
workhorse for UI juice (snap, pop, flash, shake). For anything keyframed and
complex there's `AnimationPlayer`, which this game doesn't need.
> See it: `2d/tween` demo.

### A13. Project settings, stretch modes, themes *(Phase 0, 7)*
`project.godot` holds it all (this folder's is pre-configured — read it).
Notably `window/stretch/mode = canvas_items`, which is why your UI scales
across window sizes, and `Theme` resources for styling every widget at once.
> See it: `gui/multiple_resolutions`, `gui/theming_override`.

---

## Track B — General game dev concepts

### B1. The core loop *(GDD, Phase 4)*
The 15–60 second cycle the player repeats (scan → merge → place → submit).
Everything in a game design either feeds the core loop or distracts from it.
Writing the GDD's loop *before* coding is the discipline being taught.

### B2. Separating rules from presentation *(Phase 3)*
The tile knows how to *be dragged*; the level knows whether a merge is *valid*.
When input handling and game rules live in the same function, every future
change costs double. Godot's signals make this cheap, but the principle is
universal (it's the same instinct as MVC).

### B3. Game state *(Phase 4)*
Explicitly modeling "what mode is the game in" (`PLAYING` / `WON`) instead of
scattering booleans. Grows into full state machines
(`2d/finite_state_machine`) for bigger games.

### B4. Data-driven design *(Phase 5)*
Content (levels, words, prices) lives in data files; code is a generic
interpreter of that data. The test: **can a non-programmer add a level?**
After Phase 5, yes. This one idea separates "wrote a demo" from "built a game
that can grow."

### B5. Economy design *(GDD, Phase 6)*
Sources (win rewards) and sinks (connector prices, failed-merge penalties)
must balance or the currency becomes meaningless. Even this toy economy forces
the real questions: what if the player is broke and stuck? (Answer in the GDD:
the reward floor of 3 guarantees forward progress.)

### B6. Persistence *(Phase 6)*
What survives a restart (coins, progress) vs. what doesn't (current rack).
Deciding this *set* is design; serializing it is engineering.

### B7. Feedback and juice *(Phase 3, 7)*
Every player action needs an immediate, legible response — a failed merge that
does *nothing visible* feels like a broken game, not a wrong guess. Animation,
sound, and color are how a game communicates rules without text.

### B8. Scope control *(GDD §6)*
The GDD's "out of scope" list is not filler — it's the most load-bearing
section. Finishing a small game teaches more than starting a big one; the
skill is deciding what *not* to build, in writing, before you're tempted.

---

## Suggested docs bookmarks

- Step by step: https://docs.godotengine.org/en/stable/getting_started/step_by_step/
- GDScript reference: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- UI/Control guide: https://docs.godotengine.org/en/stable/tutorials/ui/
- Class reference (built into the editor too — F1): https://docs.godotengine.org/en/stable/classes/
