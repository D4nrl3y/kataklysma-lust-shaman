# QA REPORT

Build: Echo Isles Public Demo Polish Sprint
Commit: sprint commit reported in the final handoff (parent baseline: 5f2df6b)
Date: 2026-09-23
Engine: Godot 4.7.2 stable

## Tests

| Test | Result | Notes |
|------|--------|-------|
| Main Menu | PASS | Captured `01_main_menu.png`; buttons include disabled Continue without save and all requested states. |
| Player Scale | PASS | Visual capture `02_gameplay_scale.png`; player reduced to world scale 0.34 with foot collider. |
| Zek'Ranu Scale | PASS | Same capture; NPC uses proportional 0.34 scale. |
| Camera Follow | PASS | Camera2D enabled with smoothing and map limits; smoke test validates limits. |
| Walkable Paths | PARTIAL | Whitelist regions and collision boundaries are functional; final hand-drawn polygons remain pending. |
| Water Collision | PARTIAL | Out-of-region water probes are blocked; full shoreline polygon pass remains pending. |
| Rock Collision | PASS | Prototype central rock blocker and static obstacle collision are active; capture `05_blocked_rocks.png`. |
| Cliff Collision | PASS | Map boundary/cliff blockers are active; capture `04_blocked_water.png` covers boundary behavior. |
| NPC Collision | PASS | Zek'Ranu has a physical blocker and interaction area. |
| Y-Sort | PASS | Entities are under a y-sorted root; fixed z-index is not used for player/NPC depth. |
| Walk Front | PASS | `walk_front` state exists and uses the approved front walk frames. |
| Walk Back | PARTIAL | State exists, but dedicated back walk frames are not present; fallback frames are documented. |
| Walk Left | PARTIAL | State and velocity routing exist; dedicated lateral frames are missing. |
| Walk Right | PARTIAL | State and velocity routing exist; dedicated lateral frames are missing. |
| Idle Left | PARTIAL | State exists with fallback frames; dedicated lateral idle frames are missing. |
| Idle Right | PARTIAL | State exists with fallback frames; dedicated lateral idle frames are missing. |
| Dialogue Portrait Zek'Ranu | PASS | Render portrait appears in `08_dialogue_zekranu.png`, with fallback handling. |
| Dialogue Portrait Kataklysma | PASS | Portrait appears after a response in `09_dialogue_kataklysma.png`. |
| Dialogue Text | PASS | Wrapping and expanded panel validated visually. |
| Dialogue Choices | PASS | Five choices are visible and selectable. |
| Attribute Change | PASS | Smoke test and choice handlers update attributes. |
| Quest Update | PASS | Available → in progress → complete → turned in remains functional. |
| CG Trigger | PASS | Four-frame CG sequence remains connected to objective completion. |
| Minimap | PASS | HUD capture `10_minimap_hud.png`; player, quest and objective markers update. |
| Save | PASS | Save writes position, quest, attributes, affinity, flags and POIs. |
| Load | PASS | Smoke test restores saved position and quest data. |
| Pause | PASS | ESC opens pause menu with attributes, quests, map, options, save and menu actions. |

## Automated validation

- Godot project launch validation: PASS.
- Parser/script validation: PASS.
- `res://99_AUDIT/demo_smoke_test.gd`: PASS.
- Visual capture script: PASS; ten screenshots generated in `docs/qa/screenshots/`.
- No parser errors, missing-node errors or missing-resource errors were reported by the final validation run.
