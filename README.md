# My Plant

A tiny living hanging plant for your macOS menu bar. A cute face-pot with
strings of pearls that **trail down and grow over real time**, **bloom flowers
when you step away for a break**, and that you **shape by trimming**. Pure
decoration, in the spirit of [Lucky Dangle](https://luckydangle.app) — no
tracking, no nagging.

> This project began as a bonsai and pivoted to a hanging string-of-pearls
> plant, which is a much better fit for the dangling rope-physics approach.
> The Swift module is still named `MyBonsai` for now; that rename is cosmetic.

## The idea

- **Grows on its own** — each strand of pearls lengthens over real elapsed time
  since it was planted, so it keeps trailing further down between launches.
- **Blooms on a break** — when you've been away from the keyboard for a few
  minutes, little flowers open along the strands. It's a reward for stepping
  away, not a reminder to. Break detection uses only the system idle timer
  (how long since the last input) — no content, no tracking.
- **Shape it by trimming** — in *Grooming mode*, click a strand to cut it; the
  pearls below drop away and that strand won't regrow past the cut.
- **Dangles for real** — every strand is a small verlet rope simulation, so it
  hangs under gravity and sways in a soft breeze. This is the same technique
  Lucky Dangle uses; a trailing plant is an even better fit for it than a tree.

## Status: v0.2 skeleton (SpriteKit)

- Menu-bar-only agent app (no Dock icon).
- Borderless, transparent, click-through overlay window pinned to the top of the
  screen, hosting a **SpriteKit** scene.
- Verlet rope strands, real-time growth, idle-triggered bloom, click-to-trim.
- Growth + trims persisted to `~/Library/Application Support/MyBonsai/plant.json`.

The pearls, pot and flowers are drawn with plain SpriteKit shapes as
stand-ins. The finished look comes from swapping in illustrated art wired onto
this same motion — see [`design/art-spec.md`](design/art-spec.md).

## Run it

Requires macOS 13+ and Xcode's Swift toolchain.

```bash
swift run
```

A leaf icon appears in the menu bar and the plant hangs at the top-centre of the
screen. Menu:

- **Grooming mode** — makes the plant clickable so you can trim strands.
- **Bloom now (test)** — trigger a bloom without waiting for a real break.
- **Show / hide**, **Plant a new one**, **Quit**.

In a **debug** build (`swift run`) growth is fast and a break counts after ~8s
idle, so you can watch everything. Release builds use slow, real-time pacing
(strands grow over days; a break is ~3 min idle). See `PlantStore.swift`.

## Code layout

| File | Role |
|------|------|
| `main.swift` | Entry point; `.accessory` policy (menu-bar only). |
| `AppDelegate.swift` | Status-bar menu; idle→bloom timer; owns window + store. |
| `OverlayWindow.swift` | Transparent, click-through window hosting the `SKView`. |
| `PlantScene.swift` | SpriteKit scene: pot, strands, growth, bloom, trim. |
| `Strand.swift` | One verlet rope: integrate + distance constraints. |
| `PlantStore.swift` | Growth model + JSON persistence; per-strand trim caps. |
| `design/prototype-hanging-plant.html` | The look/behaviour prototype (SVG). |
| `design/art-spec.md` | The illustrated-art asset spec. |

> Note: earlier bonsai files (`Puff.swift`, `BonsaiView.swift`,
> `BonsaiState.swift`) may still linger in the repo as unused leftovers from the
> pivot — they aren't referenced and can be deleted.

## Roadmap

1. **Illustrated art** — replace shape-node pearls/pot/flowers with the painted
   assets in `design/art-spec.md`.
2. **Per-pixel click-through** — only the plant catches the cursor; everything
   else always passes through (instead of the grooming-mode toggle).
3. **Blinking / reactions** — the face blinks; strands lean away from the cursor.
4. **Drag to reposition** along the top edge.
5. **App bundle + distribution** — Xcode app target, `LSUIElement`, Developer ID
   sign + notarize, auto-updates via [Sparkle](https://sparkle-project.org).
6. **More pots** as a gentle collection, like Lucky Dangle's charms.

## Credit

Inspired by Lucky Dangle by Karthik Mahadevan.
