# My Bonsai

A tiny living bonsai for your macOS menu bar. It grows slowly over real time,
and you shape it by pruning. Pure decoration, in the spirit of
[Lucky Dangle](https://luckydangle.app) — no tracking, no nagging, just a small
tree that lives at the top of your screen.

## The idea

- The tree **grows on its own** — roughly one new foliage puff a week. Growth is
  computed from real elapsed time since it was planted, so it keeps growing
  between launches (and even while the app is closed).
- You **shape it by pruning**. Turn on *Grooming mode* and click a leafy puff to
  cut it. Cuts are permanent — the tree you end up with is the one you made.
- It **sways** gently so it feels alive, and stays out of your way: the window
  is transparent and click-through except when you're grooming.

## Status: v0 skeleton

This is the working architecture, not the finished app. What's here:

- A menu-bar-only agent app (no Dock icon).
- A borderless, transparent, click-through overlay window pinned to the top of
  the screen — the core Lucky Dangle trick.
- Real-time growth state persisted to `~/Library/Application Support/MyBonsai/state.json`.
- Grow / prune / sway, drawn in SwiftUI.

The foliage here is drawn procedurally (overlapping circles) as a stand-in. The
real charm will come from swapping in **painted / illustrated puff and trunk
art** wired to this same animation code — exactly how Lucky Dangle pairs
illustrated masters with code-driven motion.

## Run it

Requires macOS 13+ and Xcode's Swift toolchain.

```bash
swift run
```

A leaf icon appears in the menu bar and a small tree hangs at the top-center of
your screen. Use the menu to toggle *Grooming mode* (then click a puff to
prune), show/hide, or plant a new one.

Growth is slow by design. In a **debug** build (`swift run`), a new puff appears
every few seconds so you can watch it happen; a release build uses the true
~1-puff-per-week pace. See `growthInterval` in `BonsaiState.swift`.

## Layout of the code

| File | Role |
|------|------|
| `main.swift` | Entry point; sets `.accessory` policy (menu-bar only). |
| `AppDelegate.swift` | Status-bar item and menu; owns the window and store. |
| `OverlayWindow.swift` | The transparent, click-through top-of-screen window. |
| `BonsaiState.swift` | Growth model + JSON persistence (`BonsaiStore`). |
| `Puff.swift` | Tree layout: trunk curve, puff positions, grow order. |
| `BonsaiView.swift` | SwiftUI rendering: pot, trunk, limbs, puffs, sway. |
| `design/prototype-watercolor.html` | The look-and-feel prototype this is based on. |

## Roadmap to a shippable app

1. **Painted art** — replace procedural puffs with illustrated foliage pads and
   a curvy trunk (hand-drawn or generated to a spec), layered for grow/prune.
2. **Per-pixel click-through** — so only the tree catches the cursor and the
   rest of the window always passes clicks through, instead of the current
   grooming-mode toggle.
3. **Drag to reposition** along the top edge.
4. **Wiring** — bend a branch and let it "set", a second shaping tool alongside
   pruning.
5. **App bundle + distribution** — wrap in an Xcode app target, set
   `LSUIElement`, Developer ID sign + notarize, and ship auto-updates via
   [Sparkle](https://sparkle-project.org).
6. **More species / pots** as a gentle collection, like Lucky Dangle's charms.

## Credit

Inspired by Lucky Dangle by Karthik Mahadevan.
