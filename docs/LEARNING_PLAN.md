# Word Merge — Phased Learning Plan

Seven phases. Each one ends with something you can **run and poke at** — never
more than a couple of hours from the last working state. Concepts are tagged
**[Godot]** (engine-specific — defined in `CURRICULUM.md`) or **[GameDev]**
(would apply in any engine).

Coming from Unity? Keep this mapping in your head; it covers 80% of the
translation:

| Unity | Godot |
| --- | --- |
| GameObject + Components | **Node** (each node type *is* one capability; you compose by nesting nodes) |
| Prefab | **Scene** (`.tscn`) — any scene can be instanced inside another |
| MonoBehaviour (C#) | **Script** (GDScript) attached to a node |
| Inspector | Inspector (same idea; `@export` ≈ `[SerializeField]`) |
| UnityEvent / C# event | **Signal** |
| Hierarchy window | **Scene tree** dock |
| `Instantiate()` | `scene.instantiate()` + `add_child()` |
| Canvas + RectTransform | **Control** nodes + anchors/**containers** |

---

## Phase 0 — Orientation (no code)

**Goal:** know your way around the editor before building anything.

1. Open [`gui/control_gallery`](../../gui/control_gallery/) and run it
   (<kbd>F5</kbd>). This is a live catalog of Godot's UI widgets — you'll use
   `Button`, `Label`, `TextureRect`, and several containers from it.
2. With it still open, click nodes in the **Scene dock** (left) and watch the
   **Inspector** (right) change. Find where the window layout is built out of
   `HBoxContainer`/`VBoxContainer` nodes.
3. Open [`2d/dodge_the_creeps`](../dodge_the_creeps/), run it, then open
   `main.tscn` and `hud.tscn`. Notice `hud.tscn` is a *separate scene* used
   *inside* `main.tscn` — that's the prefab-like pattern you'll use for tiles.

**Concepts:** the editor docks [Godot] · nodes & the scene tree [Godot] ·
scenes as prefabs [Godot].

**Checkpoint:** you can explain why `hud.tscn` is its own file.

---

## Phase 1 — A picture and a caption (first scene, first script)

**Goal:** open the Word Merge project, build the level screen skeleton, run it.

1. Create a new scene with a **`Control`** root named `Level`. Save as
   `level.tscn`. Press <kbd>F5</kbd> and set it as the main scene when asked.
2. Build this node tree using containers (drag nodes from **Add Child Node**):
   ```
   Level (Control, anchors = Full Rect)
   └── MarginContainer
       └── VBoxContainer
           ├── TopBar (HBoxContainer)
           │   ├── LevelLabel (Label)  "Level 1"
           │   └── CoinsLabel (Label)  "Coins: 0"
           ├── Picture (TextureRect)
           ├── CaptionRow (HBoxContainer)   ← slots go here later
           ├── Rack (HFlowContainer)        ← word tiles go here later
           └── SubmitButton (Button)  "Submit"
   ```
3. Drop any image into the folder (steal `icon.webp` for now), and assign it to
   `Picture.texture` in the Inspector. Set its **Expand Mode** and **Stretch
   Mode** so it scales instead of overflowing — experiment.
4. Attach a script to `Level` (`level.gd`). In `_ready()`, print something.
   Connect `SubmitButton`'s `pressed` **signal** to the script via the **Node
   dock → Signals tab**, and print "submitted!" in the handler.
5. Resize the game window while it runs. Containers reflow everything — this is
   the payoff of step 2. (Why: [`gui/multiple_resolutions`](../../gui/multiple_resolutions/).)

**Concepts:** Control vs. Node2D [Godot] · anchors & containers [Godot] ·
TextureRect vs. Sprite2D [Godot] · attaching scripts, `_ready()` [Godot] ·
connecting signals in the editor [Godot] · GDScript basics [Godot].

**Checkpoint:** window shows image + labels + button; clicking Submit prints to
the Output panel; resizing the window doesn't break the layout.

---

## Phase 2 — The word tile (your first reusable scene)

**Goal:** a `WordTile` scene you can stamp out with any word on it.

1. New scene: root **`Button`** named `WordTile`, save as `word_tile.tscn`.
   Give it a minimum size (Inspector → Layout → Custom Minimum Size) so tiles
   are finger-sized.
2. Attach `word_tile.gd`:
   ```gdscript
   extends Button

   var word: String:
       set(value):
           word = value
           text = value
   ```
   (A property with a `set` block — Godot's idiomatic way to keep data and
   display in sync.)
3. In `level.gd`, load the scene and spawn the starting rack:
   ```gdscript
   const WORD_TILE = preload("res://word_tile.tscn")

   func _ready() -> void:
       for w in ["sun", "flower", "dog", "sleepy", "the", "in", "a", "field"]:
           var tile := WORD_TILE.instantiate()
           tile.word = w
           %Rack.add_child(tile)
   ```
   Use **Scene Unique Names** (right-click Rack → *Access as Unique Name*) so
   `%Rack` keeps working when you reorganize the tree.
4. Run it. Eight buttons appear in the rack and wrap when the window narrows.

**Concepts:** scene instancing (`preload`/`instantiate`/`add_child`) [Godot] ·
`%` unique names vs. `$` paths [Godot] · property setters [Godot] · building UI
from data instead of by hand [GameDev].

**Checkpoint:** changing the word list in `_ready()` changes the rack. You
never touch the tile scene to do it.

**Reference:** `mob` spawning in [`2d/dodge_the_creeps/main.gd`](../dodge_the_creeps/main.gd).

---

## Phase 3 — Drag, drop, merge (the core mechanic)

**Goal:** drop one tile onto another; valid pairs merge into a new tile.

1. **Read** [`gui/drag_and_drop/drag_drop_script.gd`](../../gui/drag_and_drop/drag_drop_script.gd)
   — 33 lines, and it's the whole API: `_get_drag_data()` (what am I
   dragging?), `_can_drop_data()` (will I accept this?), `_drop_data()` (do
   it). Godot handles all the mouse tracking for you.
2. Implement all three in `word_tile.gd`:
   - `_get_drag_data()` → return `self` (drag the tile itself), and build a
     drag preview (a plain `Label` with the word is fine — see how the demo
     centers its preview on the cursor).
   - `_can_drop_data()` → accept only other `WordTile`s.
   - `_drop_data()` → don't decide the merge here; instead **emit a signal**:
     ```gdscript
     signal merge_requested(source: Node, target: Node)
     ```
     The tile *reports*, the level *decides*. This "signal up, call down" rule
     is the single most important Godot architecture habit.
3. In `level.gd`, connect each tile's signal when spawning it. Handle a merge
   with a hardcoded dictionary for now:
   ```gdscript
   var merges := {"sun flower": "sunflower", "sleepy dog": "sleepydog"}
   ```
   On success: `queue_free()` both tiles, spawn one merged tile. On failure:
   flash the target red (`modulate` + a `Tween` — see [`2d/tween`](../tween/)).

**Concepts:** the drag-and-drop virtual methods [Godot] · defining/emitting
custom signals [Godot] · `queue_free()` and safe deletion [Godot] · tweens
[Godot] · "signal up, call down" decoupling [Godot] · separating input from
rules [GameDev].

**Checkpoint:** dragging "sun" onto "flower" produces one "sunflower" tile;
dragging "dog" onto "flower" flashes red and does nothing.

---

## Phase 4 — Caption slots and the win condition

**Goal:** six slots under the image; filling them correctly wins the level.

1. New tiny scene `caption_slot.tscn`: root **`PanelContainer`** named
   `CaptionSlot` with a dashed/empty look. Spawn 6 of them into `CaptionRow`
   from `level.gd` (same instancing pattern as tiles).
2. Give slots `_can_drop_data()`/`_drop_data()` too: accept a `WordTile` only
   if the slot is empty; on drop, **reparent** the tile into the slot
   (`tile.reparent(self)`). Also let tiles drop back onto the rack.
3. On Submit, walk the slots, collect the words, compare against the accepted
   captions. Wire the result to a **win overlay**: a hidden
   `CenterContainer` + `PanelContainer` you `show()` on victory, with a "Next
   Level" button. (Pattern: `show_game_over()` in
   [`2d/dodge_the_creeps/hud.gd`](../dodge_the_creeps/hud.gd).)
4. Track game state with a tiny enum — `PLAYING`, `WON` — and ignore input
   when not `PLAYING`. (A full state machine like
   [`2d/finite_state_machine`](../finite_state_machine/) is overkill here, but
   skim it to see where this idea grows.)

**Concepts:** reparenting nodes [Godot] · `show()`/`hide()` and building
overlays [Godot] · win conditions & game state [GameDev] · enums for state
[GameDev].

**Checkpoint:** you can play one hardcoded level start-to-finish.

---

## Phase 5 — Data-driven levels (Resources)

**Goal:** levels defined as data files; the code becomes a generic player.

1. Create `level_data.gd`:
   ```gdscript
   class_name LevelData
   extends Resource

   @export var image: Texture2D
   @export var rack_words: PackedStringArray
   @export var merges: Dictionary[String, String]
   @export var accepted_captions: Array[PackedStringArray]
   ```
2. In the FileSystem dock: right-click → **New Resource → LevelData**. Fill in
   level 1 entirely in the Inspector — no code. Save as `levels/level_1.tres`.
   Make the three levels from the GDD content plan.
3. Refactor `level.gd`: add `@export var data: LevelData` and build everything
   (picture, rack, merge dictionary, captions) from it in `_ready()`. Delete
   every hardcoded word.
4. "Next Level" loads `level_%d.tres` for the next index and rebuilds.

**Concepts:** custom Resources & `.tres` files [Godot] · `@export` and typed
collections [Godot] · `class_name` [Godot] · data-driven design / separating
content from code [GameDev].

**Checkpoint:** adding a fourth level requires zero code — one `.tres` file
and one image.

---

## Phase 6 — Coins, the connector shop, and saving

**Goal:** the economy layer, plus persistence.

1. Create an **autoload** (Project Settings → Globals): `game_state.gd` with
   `var coins: int` and a `signal coins_changed(total: int)`. Autoloads are
   Godot's singletons — right for the tiny bit of state that outlives a level,
   and *only* that. Resist putting level logic in it.
2. `CoinsLabel` connects to `coins_changed` and just displays. Award coins on
   win, deduct on failed merges, per the GDD.
3. Build the **shop strip**: an `HBoxContainer` of buttons ("and — 2¢",
   "or — 2¢", "of — 3¢"). Buying spawns a normal `WordTile` in the rack and
   deducts coins; disable buttons you can't afford (bind to `coins_changed`).
4. Save/load coins with `FileAccess` + JSON to `user://save.json`. Load in the
   autoload's `_ready()`, save on every change. Find where `user://` actually
   lives on disk (Project → Open User Data Folder) — knowing this saves you
   debugging pain later.

**Concepts:** autoloads/singletons [Godot] · `user://` and `FileAccess`
[Godot] · JSON serialization [Godot] · game economy & sinks/sources [GameDev] ·
persistence [GameDev].

**Checkpoint:** buy "of" for 3 coins, win with it in the caption, quit,
relaunch — your coin total survived.

---

## Phase 7 — Polish (pick any two)

Not a phase so much as a menu. Each item is self-contained:

- **Juice:** tween tiles snapping into slots; scale-pop on merge; shake on
  wrong submit. Reference: [`2d/tween`](../tween/). [Godot + GameDev]
- **Theming:** a `Theme` resource so tiles/slots/buttons look like a real
  game instead of default gray. Reference: [`gui/theming_override`](../../gui/theming_override/). [Godot]
- **Sound:** `AudioStreamPlayer` for merge/win/buy SFX. [Godot]
- **Level select screen:** a second scene reached via
  `get_tree().change_scene_to_file()` — the last big Godot primitive you
  haven't used. [Godot]
- **Un-merge:** right-click a compound tile to split it (design the rule
  yourself — this is your first solo design decision). [GameDev]

**Checkpoint (course complete):** someone else plays all three levels on your
machine without you explaining anything.
