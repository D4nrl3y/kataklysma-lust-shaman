# QA Report — Echo Isles demo / ROADMAP 30 Phase 1

Build: `0.1.0-demo`
QA date: 2026-10-07
Engine: Godot `4.7.2.stable.official` (portable QA engine; not bundled in the project)
Classification: **B — INTERNAL REVIEW READY**
Roadmap state: **Phase 1 in progress; gate not met; M30 delivery not complete.**

## Executed checks

| Test | Result | Actual evidence / limitation |
|---|---|---|
| Editor import and GDScript parser | PASS | `godot --headless --editor --path . --quit`, exit 0; no parser/resource errors in output |
| Main scene instantiation | PASS | `demo_smoke_test.gd` instantiates the main scene and reaches the menu/new-game flow |
| GUI project launch | PASS | Godot GUI renderer started the actual project main scene for 180 frames and exited 0 |
| Main menu | PARTIAL | Rendered in `01_menu_final.png`; the no-save disabled state of CONTINUAR was not isolated in this run |
| Options | PARTIAL | Menu opens and minimap visibility toggles both ways; sliders, resolution, fullscreen, key remapping and settings persistence were not all exercised |
| Player/NPC scale | PARTIAL | Scale `0.26` captured at cabin and training area; visual spot-check only, road-to-character ratio not measured against the 2.5–3 target |
| Camera follow/limits | PASS | Camera is attached to player and map limits are checked in smoke test; no long manual traversal recorded |
| Walkable Paths | PARTIAL | 15 named point checks pass; F10 capture still shows broad/approximate polygon edges against vegetation and props, so KI-001 stays OPEN |
| Water boundary | PASS | Water points are rejected by movement whitelist; south shoreline edge probe and current screenshot captured |
| Rock boundary | PARTIAL | Central exclusion rejects the tested target; full set of visible rocks/props has no individually verified physical collider |
| Training props | PASS — sampled footprints | Six representative training-object positions are rejected and seven local red debug footprints appear in the F10 capture; remaining map props are not all configured |
| Cliff boundary | PARTIAL | Cliff-side target is rejected; full cliff/platform perimeter has not received a complete manual escape pass |
| Vegetation boundary | PARTIAL | North vegetation sample is rejected; full vegetation perimeter remains visually unverified |
| NPC collision | PASS | Physics probe rejects Zek’Ranu’s blocker |
| Y-sort | PASS | Player and NPC share the Y-sorted world root |
| Idle front/back/left/right | PASS | Animation resources and counts checked; back/left/right appear in current screenshots |
| Walk front/back/left/right | PASS | Dedicated directional resources/counts checked; current back/left/right screenshots show non-front poses |
| Portraits | PASS | Zek’Ranu bust and Kataklysma portrait load in runtime dialogue and are visible in captures |
| Dialogue and vertical choices | PASS | Current dialogue is PT-BR; portrait and five vertical choices rendered |
| Attribute/affinity consequence | PASS | First choice increments Spirit and Zek’Ranu affinity; smoke test asserts both |
| Quest flow | PASS — prototype only | `available → in_progress → complete → turned_in` verified; it is not yet a canonical M30 quest |
| CG | PASS — prototype only | Four textures load, all three transitions advance, and the sequence closes; current CG remains mismatched with canonical quest lore (KI-007) |
| Minimap | PARTIAL | Background texture and markers render; toggle works; exit markers/transitions are not implemented |
| Tutorial | PASS | Three-second timeout sets `tutorial_movement_seen`, fade completes, and flag is persisted by save/load |
| Save/load | PASS — current prototype state | Position, quest, attributes, affinity, flags and POIs round-trip; no cross-zone/campaign migration exists yet |
| Pause | PASS | Opens and resumes in smoke test |
| Turn combat | PASS — basic prototype | Supported ambush opens battle, action input reaches a terminal state, and combat closes; balance/content not approved |
| Random event dispatch | PARTIAL | Only `monster_ambush` opens combat; NPC/resource events intentionally show pending notices, not complete interactions |
| Audio | PARTIAL | Not auditioned as release mix; watermarked generated track is not cleared for distribution; procedural tones remain fallback |
| Fonts | PARTIAL | Inter/Cinzel render in current menu/dialogue captures; alternate-resolution/layout review remains |
| NPC ambient route | PARTIAL | Route exists for Zek’Ranu only; movement schedule and all anchor updates were not visually tested end-to-end |

## Walkability probes

`final_release_qa.gd` completed 15 named walkability-point checks plus 7 blocked-target checks: **22/22 PASS** in the current geometry. The smoke test separately rejects six representative training-prop footprints. These are deterministic point/boundary probes, not a claim that every shoreline, rock, cliff, stair, prop and vegetation edge was manually traversed. The visual review of `04_walkable_debug.png` remains **PARTIAL** and is the reason KI-001 remains open.

`capture_release_qa.gd` completed in the GUI renderer with exit 0 and validated that the water, cliff and central-rock screenshot positions are walkable safe edges while their attempted targets are rejected. It wrote the current 22-image set below. No release screenshots were produced by headless rendering.

## Current screenshot evidence

Authoritative current set under `docs/qa/screenshots/`:

`01_menu_final.png`, `02_scale_hut.png`, `03_scale_training_area.png`, `04_walkable_debug.png`, `05_blocked_water.png`, `06_blocked_cliff.png`, `07_blocked_rocks.png`, `08_idle_back.png`, `09_idle_left.png`, `10_idle_right.png`, `11_walk_back.png`, `12_walk_left.png`, `13_walk_right.png`, `14_dialogue_zekranu.png`, `15_dialogue_kataklysma.png`, `16_dialogue_vertical_choices.png`, `17_minimap_final.png`, `18_quest_before_accept.png`, `19_quest_after_accept.png`, `20_gameplay_final.png`, `21_cg_sequence.png`, `22_turn_combat.png`.

The visually reviewed captures include menu, scale, F10 overlay, water/cliff/rock edges, directional poses, dialogue/portraits, minimap and combat. Older `*_release_*.png` files are historical and are not evidence for this run.

## Release gate

**B — INTERNAL REVIEW READY.** The automated parser, smoke and sampled boundary suites pass, but the Phase 1 gate is not met: visual walkability remains imprecise, options and scale need broader QA, and the active quest/CG flow is a non-canonical prototype. The M30 content gates KI-010/KI-011 and remain unimplemented. Do not label this build PUBLIC DEMO READY or “30% complete.”
