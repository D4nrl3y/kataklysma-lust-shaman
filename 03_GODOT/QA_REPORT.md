# QA Report — Echo Isles

Build: Echo Isles — Public Demo Completion Sprint
Date: 2026-09-23
Engine: Godot 4.7.2 stable
Classification: **B — INTERNAL REVIEW READY**

The build launches and the end-to-end vertical slice is playable. It is not classified as PUBLIC DEMO READY because the walkability polygons still need a final map-authored pass and that remains a P0 release blocker under the sprint rules.

## Functional and visual results

| Test | Result | Evidence |
|---|---|---|
| Main Menu | PASS | `01_menu_final.png`; canonical title and button states render. |
| Player Scale | PASS | `02_scale_hut.png`, `03_scale_training_area.png`; scale `0.26`, foot collision recalibrated. |
| Zek'Ranu Scale | PASS | `02_scale_hut.png`; NPC uses scale `0.26`. |
| Camera Follow | PASS | Smoke test; smoothing and map limits are active. |
| Walkable Paths | PARTIAL | Polygon whitelist and F10 overlay work; shoreline/vegetation precision still needs map-authored refinement. |
| Water Collision | PARTIAL | Water probes are blocked; full coast perimeter still needs final polygon audit. |
| Rock Collision | PASS | `07_blocked_rocks.png` and smoke probe pass. |
| Cliff Collision | PASS | `06_blocked_cliff.png` and out-of-region probe pass. |
| Vegetation Collision | PARTIAL | Covered by polygon whitelist in tested routes; every dense cluster is not yet individually audited. |
| NPC Collision | PASS | Zek'Ranu blocker and interaction area pass smoke test. |
| Y-Sort | PASS | Player and NPC remain under the `Entities` y-sorted root. |
| Idle Front | PASS | Existing approved front idle frames remain active. |
| Idle Back | PASS | 2 dedicated frames integrated; `08_idle_back.png`. |
| Idle Left | PASS | 2 dedicated frames integrated; `09_idle_left.png`. |
| Idle Right | PASS | 2 dedicated frames integrated; `10_idle_right.png`. |
| Walk Front | PASS | Existing approved front walk sequence remains active. |
| Walk Back | PASS | 8 dedicated frames integrated; `11_walk_back.png`. |
| Walk Left | PASS | 8 dedicated frames integrated; `12_walk_left.png`. |
| Walk Right | PASS | 8 integrated lateral frames; `13_walk_right.png`. |
| Dialogue Portrait Zek'Ranu | PASS | Dedicated bust crop in `14_dialogue_zekranu.png`. |
| Dialogue Portrait Kataklysma | PASS | `15_dialogue_kataklysma.png`. |
| Dialogue Text | PASS | PT-BR intro and quest lines visible. |
| Dialogue Choices | PASS | `16_dialogue_vertical_choices.png`; five choices are listed vertically and selectable. |
| Attribute Change | PASS | Smoke test verifies choice effects. |
| Quest Update | PASS | `18_quest_before_accept.png` → `19_quest_after_accept.png`; tracker changes immediately. |
| CG Trigger | PASS | Smoke test traverses objective completion and four CG variants. |
| Minimap | PASS | `17_minimap_final.png`; player, quest and objective markers are visible. |
| Tutorial | PASS | Timer/distance fade and save flag implemented; no longer permanent. |
| Save | PASS | Smoke test writes position, quest, attributes, flags and POIs. |
| Load | PASS | Smoke test restores saved position and quest data. |
| Pause | PASS | ESC pause menu and actions remain functional. |

## Automated validation

- Godot editor/project launch validation: PASS.
- Parser validation: PASS; no script parse errors.
- `res://99_AUDIT/demo_smoke_test.gd`: PASS.
- `res://99_AUDIT/capture_sprint_qa.gd`: PASS under the OpenGL renderer; 20 PNGs generated.
- Visual QA performed on the required screenshot set; no missing player directional texture was observed.
- Headless dummy renderer is not suitable for screenshot capture because it exposes no viewport texture; this is an infrastructure limitation, not a game runtime error.

## Screenshot index

The required files are in `docs/qa/screenshots/`: `01_menu_final.png` through `20_gameplay_final.png`, including scale, walkability debug, blockers, directional frames, dialogue, minimap and quest states.

## Release gate

**B — INTERNAL REVIEW READY.** The P0 walkability gate remains open. The build must not be advertised as PUBLIC DEMO READY until the polygon pass is reviewed against the full map and the 13 required walkability zones are manually confirmed.
