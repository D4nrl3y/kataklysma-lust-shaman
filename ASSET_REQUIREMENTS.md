# Asset Requirements — Echo Isles Demo

## Kataklysma directional sprites

Identity lock: the existing Kataklysma troll shaman — lavender-blue skin, platinum ponytail, long ears, amber eyes, lower tusks, brown tribal shaman outfit, feathers and ornaments.

| Set | Directory | Frames | Canvas | Pivot/baseline | FPS | Status |
|---|---|---:|---|---|---:|---|
| Idle front | `01_ASSETS/kataklysma/sprites/idle/` | 4 | existing approved front canvas | existing feet baseline | 4 | COMPLETE |
| Idle back | `01_ASSETS/kataklysma/sprites/directional/idle_back/` | 2 | 362×543 PNG RGBA | centered feet baseline | 3 | COMPLETE |
| Idle left | `01_ASSETS/kataklysma/sprites/directional/idle_left/` | 2 | 362×543 PNG RGBA | centered feet baseline | 3 | COMPLETE |
| Idle right | `01_ASSETS/kataklysma/sprites/directional/idle_right/` | 2 | 362×543 PNG RGBA | centered feet baseline | 3 | COMPLETE |
| Walk front | `01_ASSETS/kataklysma/sprites/walk/` | 4 | existing approved front canvas | existing feet baseline | 8 | COMPLETE |
| Walk back | `01_ASSETS/kataklysma/sprites/directional/walk_back/` | 8 | 362×543 PNG RGBA | centered feet baseline | 8 | COMPLETE |
| Walk left | `01_ASSETS/kataklysma/sprites/directional/walk_left/` | 8 | 362×543 PNG RGBA | centered feet baseline | 8 | COMPLETE |
| Walk right | `01_ASSETS/kataklysma/sprites/directional/walk_right/` | 8 | 362×543 PNG RGBA | centered feet baseline | 8 | COMPLETE |

The eight walk frames are ordered as contact, down, passing, up, contact-inverse, down-inverse, passing-inverse and up-inverse. Right-facing frames are a horizontal mirror of the approved lateral silhouette; no asymmetric costume detail currently makes that mirror invalid.

## Runtime integration

- `03_GODOT/scripts/demo_game.gd` loads directional frames only for Kataklysma.
- `velocity.x < 0` routes to `walk_left`; `velocity.x > 0` to `walk_right`.
- `velocity.y < 0` routes to `walk_back`; `velocity.y > 0` to `walk_front`.
- Stopping preserves the last direction and selects the matching idle animation.
- Texture filtering remains nearest-neighbor.
- Final Phase 1 calibration: Kataklysma and Zek'Ranu scale `0.22`; player foot collision `20×12` at `40 px` below the actor origin; camera zoom `1.18`.
- Measured on the current map: sprite width `37.62` world px / road width `95.00` world px = `2.53:1`, within the `2.5–3.0:1` target. Cabin and training-area gameplay captures were reviewed.

## Dialogue assets

- Kataklysma: `01_ASSETS/kataklysma/ui/portraits/neutral/kataklysma_portrait_neutral.png` — existing approved bust.
- Zek'Ranu: `01_ASSETS/kataklysma/ui/portraits/neutral/zekranu_portrait_dedicated_v002.png` — separately generated square bust illustration based on the identity-locked render; replaces the earlier crop in the demo.
- Canonical Phase 2 PT-BR dialogue: `03_GODOT/data/dialogue/pt_BR/campaign_echo_isles.json`; integrated with quest interactions, branches and conditional responses. The older `quest_01.json` remains a labeled legacy prototype.
- Non-combat encounter strings: `03_GODOT/data/dialogue/pt_BR/encounters.json`.
- Other Echo Isles NPC speakers currently use their integrated gameplay sprite as a temporary dialogue crop, not a dedicated bust portrait. This is documented asset polish, not a final-art approval.

## Sen’jin / QST_SEN_009 — Phase 3

| Asset/system | Path or data | Current status |
|---|---|---|
| Sen’jin map background | `01_ASSETS/kataklysma/maps/senjin_village/backgrounds/senjin_village_background_concept_v001.png` | Integrated into the runtime zone; single flattened concept image, not a modular/artist-final map |
| Walkability and blockers | `03_GODOT/data/walkability/senjin_village.json` | 10 whitelist regions, 26 named blocker polygons, five-point foot probes, physical `CollisionPolygon2D` bodies; spawn `[1325, 690]`; 6,932 whitelist and 6,807 physical grid cells reachable in current test |
| Foreground foliage | `01_ASSETS/kataklysma/maps/senjin_village/foregrounds/senjin_foreground_vegetation_candidate_v001.png` | Generated transparent pixel-art candidate (1536×1024 RGBA), integrated at sprite scale 0.08 over an existing blocked vegetation area; visually checked in Godot, not final-art approved |
| Quest and interaction data | `03_GODOT/data/campaign/echo_isles.json`; `senjin_village_interactions.json`; `03_GODOT/data/dialogue/pt_BR/campaign_senjin_village.json` | Q009, five anchors, PT-BR arrival/investigation/resolution dialogue and four council outcomes are runtime-integrated |
| Regional events | `03_GODOT/data/encounter_tables.json` | Sen’jin plaza/dock regions; named NPC walk-by, supply issue, alchemy request and Makrura ambush entries; functional handler tests pass |
| Visual/functional evidence | `docs/qa/screenshots/phase3/` | Eight current GUI captures; see the Phase 3 section in `03_GODOT/QA_REPORT.md` |

The map's collision polygons are hand-authored against the concept image. The automated route/connectivity checks pass, but a full human visual traversal of shore, waterfall/cliffs, village, stairs and dock remains a gate item. Candidate foliage must not be described as approved final art.

## Typography

- UI: Inter variable font at `01_ASSETS/kataklysma/ui/fonts/inter/inter_variable.ttf`, applied as the Godot project Theme default.
- Display: Cinzel variable font at `01_ASSETS/kataklysma/ui/fonts/cinzel/cinzel_variable.ttf`, applied to game/menu/dialogue headings.
- Both font folders include the corresponding upstream `OFL.txt` (SIL Open Font License 1.1). Source families: [Google Fonts Inter](https://github.com/google/fonts/tree/main/ofl/inter) and [Google Fonts Cinzel](https://github.com/google/fonts/tree/main/ofl/cinzel).

## Audio

- `01_ASSETS/kataklysma/audio/music/echo_isles_field_ambience_ai_v001.mp3` — generated instrumental field track (92 BPM, B minor, approximately 160 seconds), looped by the runtime audio manager on entering the demo.
- This candidate is watermarked by its generator and its redistribution/commercial-use terms have not been cleared. It is an integration candidate, not release-approved final audio.
- Final authored UI/quest/combat SFX are not yet present. The runtime looks for `<event>.ogg` files under `01_ASSETS/kataklysma/audio/sfx/`; existing procedural tones remain the temporary fallback.

## Walkability and NPC behavior

- `03_GODOT/data/walkability/echo_isles.json` defines 16 whitelist polygons and 17 named blocker polygons for the background-image map. Runtime creates physical collision polygons for blockers; the player's five foot probes must remain inside the whitelist and outside exclusions.
- F10 overlay is off by default and shown only for QA. The current `04_walkable_debug.png` was visually reviewed against the route art; route traversal plus deliberate water, cliff, rock, vegetation, stair, bridge and inaccessible-edge probes pass the Phase 1 criteria.
- Current boundary suite passes 15 named walkability points and 7 physical blocked-target probes; acceptance also physically traverses seven routes and checks representative training props.
- Zek'Ranu has a six-point ambient route, waits between steps, pauses when Kataklysma approaches and keeps interaction/collision/name/marker/minimap anchors synced. A 20-second deterministic routine test passes.
- Options persist separate bindings for four movement directions, interaction/confirm, and pause; arrow keys and the default interaction alternatives remain available.
- Phase 1 QA captures are under `docs/qa/screenshots/`; the current Phase 2 campaign walkthrough (21 images, 1280×720) is under `docs/qa/screenshots/phase2/`. Older `*_release_*.png` files are historical and do not approve the current build.

## Remaining asset requirements

- Release-approved unwatermarked Echo Isles score/ambience and authored SFX: OPEN, P1 (KI-002). Runtime playback/routing passed; rights and final authoring did not.
- Phase 1 walkability, options, scale and Zek'Ranu routine acceptance: COMPLETE; see `03_GODOT/QA_REPORT.md`.
- Phases 1 and 2 are complete. Sen’jin/`QST_SEN_009` and cross-zone persistence are implemented and automated-tested; Phase 3 remains open for full human visual route review, independent playtest and clean exported-install validation (KI-011/KI-013).
- `01_ASSETS/kataklysma/static_objects/CANDIDATE/echo_isles_quest_props_candidate_sheet_v001.png` provides the 20 atlas props used by all 37 Phase 2 interaction points. The file is explicitly a candidate atlas, not final approved art.
- Phase 2 also integrates the candidate apprentice and children actors, and a static wild-boar candidate (`entity_wild_boar_candidate_v002.png`) in the Q003 hunt path. The boar is a one-frame combat sprite; animation/style approval remains open (KI-012).

## Roadmap M30 — coverage beyond the Echo Isles prototype

The current inventory and integration evidence for `QST_ECHO_001`–`QST_ECHO_008` and Sen’jin `QST_SEN_009` are documented in `docs/production/M30_ASSET_COVERAGE.md` and `03_GODOT/QA_REPORT.md`. Later regions, final portraits for every speaker, approved enemy animation sets and release audio remain open. Candidate assets are not described as final; presence, integration and art approval are tracked separately.
