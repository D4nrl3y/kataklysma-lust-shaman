# QA Report — Echo Isles Demo

Version: `0.1.0-demo`
Date: 2026-09-23
Engine: Godot 4.7.2 stable
Classification: **B — INTERNAL REVIEW READY**

The complete functional flow passes, including the 15 requested escape checks. The build remains B because visual inspection of the F10 overlay still shows polygon edges that need a final art-directed shoreline and vegetation pass. It is not honest to promote this to PUBLIC DEMO READY yet.

## Final test results

| Test | Result | Evidence |
|---|---|---|
| Main Menu | PASS | `01_release_main_menu.png` |
| Player Scale | PASS | `02_release_gameplay_scale.png`; scale `0.26` retained |
| Zek'Ranu Scale | PASS | Same scale capture; NPC scale `0.26` |
| Camera Follow | PASS | Smoke test; smoothing and map limits valid |
| Walkable Paths | PARTIAL | 15-point escape suite passes, but F10 overlay still needs visual edge refinement |
| Water Collision | PASS | West, south and east water probes pass |
| Rock Collision | PASS | Central rocks and `07_release_blocked_rocks.png` pass |
| Cliff Collision | PASS | Cliff probes and `06_release_blocked_cliff.png` pass |
| Vegetation Collision | PASS | North vegetation probe blocks movement |
| NPC Collision | PASS | NPC blocker and interaction area pass |
| Y-Sort | PASS | Entities remain under y-sorted root |
| Idle Front | PASS | Existing approved front sequence |
| Idle Back | PASS | Dedicated 2-frame set integrated |
| Idle Left | PASS | Dedicated 2-frame set integrated |
| Idle Right | PASS | Dedicated 2-frame set integrated |
| Walk Front | PASS | `08_release_walk_front.png` |
| Walk Back | PASS | `09_release_walk_back.png` |
| Walk Left | PASS | `10_release_walk_left.png` |
| Walk Right | PASS | `11_release_walk_right.png`; mirrored set visually inspected |
| Directional asset QA | PASS | 30 PNGs have consistent 362×543 RGBA canvases; montage inspection found no crop or frame mixing |
| Dialogue | PASS | `12_release_dialogue_zekranu.png`, `13_release_dialogue_kataklysma.png` |
| Portraits | PASS | Dedicated Zek'Ranu bust and Kataklysma portrait render correctly |
| Dialogue choices | PASS | Five vertical PT-BR choices; interaction prompt is hidden while open |
| Quest | PASS | Available → in progress → complete → turned in |
| CG | PASS | `16_release_cg.png`; sequence remains connected to objective completion |
| Combat | PASS | `17_release_combat.png`; turn UI and actions render |
| Minimap | PASS | `14_release_minimap.png`; markers remain in map bounds |
| Quest progress | PASS | `15_release_quest_progress.png` |
| Save | PASS | Position, quest, attributes, flags and POIs persist |
| Load | PASS | Smoke test restores saved state |
| Pause | PASS | ESC pause flow remains functional |
| Audio fallback | PASS | Procedural audio does not crash or clip in menu, quest and combat smoke paths |

## Walkability escape suite

| Region | Result |
|---|---|
| Costa oeste | PASS |
| Costa sul | PASS |
| Costa leste | PASS |
| Waterfall | PASS |
| Cliffs da arena | PASS |
| Bordas da cabana | PASS |
| Vegetação norte | PASS |
| Região do Zek'Ranu | PASS |
| Ponte | PASS |
| Plataforma de totens | PASS |
| Ilhas menores visíveis | PASS |
| Pedras centrais | PASS |
| Escadas | PASS |
| Bifurcação estreita | PASS |
| Extremidades do mapa | PASS |

The automated runner is `res://99_AUDIT/final_release_qa.gd`. It reports `FINAL_RELEASE_QA: PASS` and records the individual results in the console.

## Screenshot package

The final release set is in `docs/qa/screenshots/`:

`01_release_main_menu.png` through `18_release_final_gameplay.png`.

## Release gate

**B — INTERNAL REVIEW READY.** The remaining blocker is visual precision of the walkable polygon edges against the background art. Do not publish the demo externally until that final map-authored pass is reviewed and the F10 overlay no longer visibly crosses shoreline/cliff/vegetation areas.
