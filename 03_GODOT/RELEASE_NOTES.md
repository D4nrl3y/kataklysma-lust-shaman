# Kataklysma — Lust Shaman's Journey

## Echo Isles prototype 0.1.0-demo

**Classification:** B — internal review only. This is not a public-release build.

### In the current prototype

- Echo Isles exploration with the cardinal movement sprite sets for Kataklysma.
- Zek'Ranu interaction, a short prototype quest/dialogue, attribute choices and quest markers.
- One four-frame CG sequence, a turn-based combat prototype, minimap, quest tracker, pause, options and local save/load.
- F10 walkability overlay for development review.

These features are implemented in the prototype code, but changes from 2026-10-07 have not been verified in Godot. See `QA_REPORT.md` and `KNOWN_ISSUES.md`; historical PASS entries apply only to the older build and walkability geometry.

### Controls documented for the prototype

- `WASD` / arrows: move
- `E` / `Space`: interact and confirm
- `1–5`: choose a dialogue response or combat action
- `F`: start a combat test encounter
- `F10`: toggle the development walkability overlay
- `Esc`: pause
- `R`: restart the prototype

### Current release blockers

- `KI-001`: current walkability geometry has not received visual/runtime QA.
- The music candidate is watermarked and its redistribution/commercial-use rights are uncleared; final authored SFX are absent.
- Options, fonts, portrait presentation and NPC route need runtime QA.
- The active quest is a prototype, not the canonical quest chain in the Narrative Bible. Only Echo Isles is connected to the runtime flow.
- Random event routing and the full M30 content scope remain to be implemented.

Do not publish or describe this as the M30 build until its roadmap gates have passed and current build evidence has been recorded.
