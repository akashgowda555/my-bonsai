# My Plant — illustrated art spec

The app renders in code (SpriteKit), but the *charm* comes from real
illustrated art wired onto that motion — the Lucky Dangle pipeline: a painted
master, cut into layers, each layer driven by code. This spec lists the assets
an illustrator (or an image model) should produce and how each maps to the
running app.

## Visual direction

Soft, cute, slightly watercolor. Warm neutral paper background (the pot is the
character). Reference vibe: cream ceramic pot with a sleepy/smiley face,
string-of-pearls (*Senecio rowleyanus*) trailing down. Friendly, calm, not busy.

## Coordinate + scale conventions

- Author on a **300 x 480 pt** canvas at **@1x**, export **@2x and @3x** PNGs
  with transparent backgrounds.
- Pot centre sits at roughly **(150, 150)** from the top; strands anchor along
  the rim and trail downward. Keep ~300 pt of vertical room below the pot for
  long strands.
- Everything is 2D and flat-lit (no baked hard shadows on the plant itself; a
  soft contact shadow under the pot is fine as its own layer).

## Assets

### 1. Pot (the character) — a small set of "faces", like Lucky Dangle charms
- `pot_body.png` — the ceramic cup, front view, empty (no soil, no plant).
- `pot_face_sleeping.png`, `pot_face_smiley.png`, … — face layer(s) drawn on a
  transparent layer, aligned to the body. Ship as separate layers so faces are
  swappable and could blink.
- Optional `pot_blush.png` — cheeks, low opacity.
- Deliver 3–5 pot variants to start (the collectible hook).

### 2. Soil + crown
- `crown.png` — the mound of pearls sitting on the soil at the rim, drawn as one
  soft cluster. This is static (only gently sways with the pot).

### 3. Pearl + strand (the growing/dangling part) — **art, not a full strand**
The strands are assembled and animated in code from small pieces, so the art is
a *kit*, not a pre-drawn vine:
- `pearl_a.png` … `pearl_d.png` — 3–4 individual pearl beads, ~12 pt, subtle
  size/shade variation, each with a soft highlight. Code places one per chain
  point.
- `stem.png` (optional) — a short 1–2 pt tapered stem tile, or leave the stem as
  a drawn stroke in code (current approach). Prefer code stroke for flexibility.
- Provide pearls on transparent bg, centred, trim-tight.

### 4. Flowers (the bloom reward)
- `flower_pink.png`, `flower_white.png`, `flower_yellow.png` — small 5-petal
  blooms, ~16 pt, centred. Code scales them in on a break and fades them out.
- Optional 2-frame "open" variant if you want the bloom to animate rather than
  just scale.

### 5. Hanger
- `cord.png` or a code-drawn stroke — two thin jute cords from the top to the
  rim. Code stroke is fine.

## How each maps to the app

| Asset | Code hook |
|-------|-----------|
| `pot_body` + `pot_face_*` | Static `SKSpriteNode`s near the top; face is its own node so it can blink / swap. |
| `crown` | One node at the rim; parented to the pot so it sways with it. |
| `pearl_*` | One `SKSpriteNode` per verlet chain point in `PlantScene.syncStrand`, replacing the current `SKShapeNode` circles. |
| `flower_*` | Spawned by `PlantScene.bloom()` at a chain point, scaled in / faded out. |
| `cord` | Two nodes/strokes from the top of the window to the pot rim. |

## Growth, bloom, trim (behaviour the art must support)

- **Growth** — strands lengthen point-by-point over real time. Pearls should
  tile seamlessly at any length, so they must read fine whether a strand is 3 or
  20 beads long. No baked-in "tip" art on the strand.
- **Bloom** — flowers appear *on top of* pearls at random points during a break;
  they should sit visually in front of the strand.
- **Trim** — a strand can be cut at any point; beads below the cut are removed at
  runtime, so nothing can be one baked image.

## Delivery

- Layered source (`.svg`, `.ai`, `.fig`, or layered `.psd`) **plus** flattened
  transparent PNGs per layer at @2x/@3x.
- Consistent trim boxes and centred pivots; note the intended anchor/pivot for
  any layer that rotates (pot sway, face).
- Name files exactly as above so they drop into an asset catalog cleanly.
