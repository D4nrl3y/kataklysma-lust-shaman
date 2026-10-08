# Kataklysma production status

**Snapshot:** 2026-10-07

**Project:** `Kataklysma — Lust Shaman's Journey`

**Current build:** `0.1.0-demo`, internal prototype

**M30 status:** not reached; current project percentage is not calculated.

## Production assets

- Kataklysma has front, back, left and right idle/walk sprites. There are no dedicated diagonal movement animations.
- 13 named NPCs have neutral renders and front-facing `IDLE`/`WALK` sets. They do not yet have production `CAST`/`COMBAT` sets.
- 3 priority entities have neutral renders and partial field/action sprite sets.
- 12 CG sequences have 48 v002 frames in the asset catalog. The visual identity/continuity review is recorded in `99_AUDIT/VISUAL_IDENTITY_QA_V002.md`; only the four-frame Echo 002 sequence is hardcoded into the current demo.
- Background concepts exist for Echo Isles, Sen'jin Village, Durotar, Razor Hill, Northern Barrens, Ratchet and the Eye shrine. Orgrimmar has no background. The Eye shrine is catalogued as a special finale location, not one of the seven campaign regions.
- Character identity locks, sprite production manifests, quest markers, menu/key art, portraits, fonts and a watermarked Echo Isles music candidate are present in the repository.

Asset presence does not establish runtime integration, licensing clearance or approval for the current build.

## Runtime prototype

The project opens from the repository root and its main scene is `03_GODOT/scenes/main.tscn`. The current runtime is built largely by `03_GODOT/scripts/demo_game.gd`; it provides an Echo Isles prototype with a player, Zek'Ranu, a hardcoded quest/dialogue flow, one CG sequence, a turn-based combat test, menu/options, minimap, pause and local save/load.

The active quest and dialogue are a prototype, not a complete canonical quest. The file `03_GODOT/data/dialogue/pt_BR/quest_01.json` is explicitly marked as a prototype reference and is not loaded by the runtime. Several catalogs, including zones and CG variants, describe production scope but do not create playable scenes by themselves.

`03_GODOT/data/zones.json` now reflects the seven campaign regions in the Narrative Bible and tracks the Eye shrine as a special scripted location. Only Echo Isles is connected to the runtime. Sen'jin and the other backgrounds still need playable scenes, collisions, POIs, routes and event integration.

## QA and release status

- The most recent Godot QA report is historical. Its PASS results apply to the build and walkability polygons tested before the 2026-10-07 changes.
- The 2026-10-07 walkability, options, fonts, portrait, audio routing and NPC route changes have not received runtime/parser/visual QA.
- `KI-001` walkability remains P0 OPEN. `KI-002` audio remains partial pending cleared rights and final SFX. `KI-003` options, `KI-004` fonts, `KI-005` portrait and `KI-006` NPC routine require runtime QA; broader NPC routines are not implemented.
- The field music candidate is watermarked and not cleared for redistribution or commercial use. Final authored SFX are absent.
- Visual sprite QA recorded 60/60 groups after pivot corrections; the report still records edge-contact warnings and is not a substitute for current gameplay review.

**Classification remains B — INTERNAL REVIEW ONLY.** Do not promote this prototype to public demo or M30 until the relevant roadmap gates pass with evidence from the current commit.

## Production direction

- Combat remains **turn-based**, following the user's established direction. The Narrative Bible overview describes real-time combat; that source conflict must be formally reconciled before the Bible is used to author further combat content.
- The proposed M30 campaign scope is tracked in `ROADMAP_30_PERCENT.md`. The effort denominator and final cutoff must be settled before any numeric completion claim.
- Full regional scope: Echo Isles, Sen'jin Village, Durotar, Razor Hill, Orgrimmar, Northern Barrens and Ratchet. The Eye shrine is a scripted finale location associated with the Eye quests.
