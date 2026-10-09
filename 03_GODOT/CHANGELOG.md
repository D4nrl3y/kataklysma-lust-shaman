# Changelog

## User-reported gameplay fixes — 2026-10-09

### Added

- Added `user_report_regression_test.gd` (110 checks) for cabin scale, normalized side-view frames, the real cabin-exit handler, walkability/physics/sand clearance and immediate movement.
- Added three reviewed visual QA captures under `docs/qa/screenshots/user_report_regression/`.

### Changed

- Added a cabin-only Kataklysma scale of `0.26`; the Echo Isles outdoor calibration remains `0.22` and its road-width target is unchanged.
- Normalized the four side-facing idle/walk animations to one visible alpha height while preserving the shared foot baseline. The source PNGs were not modified.
- Moved the cabin exit to the four-way-clear dirt-path point `(784, 336)` (260/273 foot-area pixels pass the dirt-color check) and changed the exit narration from a movement-blocking modal to a non-modal toast.

### Fixed

- Fixed the former cabin exit spawn `(745, 355)`, which was outside the authored walkable area.
- Fixed the exit interaction leaving the player unable to move until an unnecessary acknowledgement was confirmed.
- Fixed visible size pulsing across side-facing frames with source alpha heights from 405 to 470 px.

### Known limitations

- The screenshots and tests are local QA; the user should still confirm the presentation in a normal play session. Phase 3 remains open for its separate map traversal, independent playtest and exported-build checks.

## ROADMAP 30 — Phase 3 implementation in progress: Sen’jin — 2026-10-08

### Added

- Added Sen’jin runtime zone data, 10 whitelist walkable polygons, 26 named blocker polygons, a dock arrival spawn, five Q009 points and a transparent foreground vegetation candidate integrated over an existing blocked area.
- Added `QST_SEN_009` with the arrival/investigation sequence, Taz’Rima and Ruk’ka dialogue, four council resolutions, effects/fail-forward, event handlers and PT-BR strings.
- Added `senjin_walkability_test.gd` and `capture_senjin_qa.gd`; the current suite reports 6,932 whitelist and 6,807 physical reachable grid cells to all five quest anchors, and emits eight reviewed 1280×720 GUI captures.
- Expanded Sen’jin geometry QA with 11 expected-walkable route landmarks, 10 water/map-edge rejection landmarks, and an individual `CharacterBody2D.test_move` probe for each of the 26 named blocker polygons; all checks pass in the current headless run.

### Changed

- Q008 now transitions from Echo Isles into Sen’jin, accepts Q009 and preserves campaign state through cross-zone save/load. A completed Q009 save reloads into the `SENJIN_COMPLETE` chapter.
- Sen’jin uses its own encounter table and map markers; supply and alchemy events apply persistent results, and named NPC walk-bys do not start combat.
- Updated Phase 1 smoke/encounter tests for the nine-quest catalog and Sen’jin region routing.
- Added a Windows Desktop release preset and installed the official Godot 4.7.2 Windows x86_64 release template. Export succeeded and the executable passed a headless startup smoke outside the repository. The project metadata version is numeric (`0.1.0`) for Windows; the in-game demo label remains `0.1.0-demo`.

### Fixed

- Percentage costs can no longer be paid from a zero balance at zero effective cost.
- Restoring a completed Sen’jin save no longer downgrades the chapter checkpoint to `SENJIN_VILLAGE`.

### Known limitations

- Phase 3 remains open: an independent player, full visual map review, and GUI/save-load testing on the exported build in a clean account or second machine are not done. The map background is flattened and the integrated foreground sprite remains a candidate; do not call it final art or mark Phase 3 complete.
- The expanded local walkability suite and regression suite passed, but automated landmark/collision checks and static screenshot inspection do not count as the outstanding live visual route review or independent playtest.
- The initial export emitted a warning because the project version included a `-demo` suffix. `project.godot` now uses numeric package metadata (`0.1.0`); the final export was repeated and completed without that warning.
- The build remains **B — INTERNAL REVIEW READY**. Audio rights/final SFX, broader candidate-asset approval and the M30 release gate remain unresolved.

## ROADMAP 30 — Phase 2 complete: Echo Isles campaign — 2026-10-08

### Added

- Integrated the canonical `QST_ECHO_001`–`QST_ECHO_008` campaign into the main New Game flow with PT-BR dialogue, 37 world interaction points, named/candidate actors and a 20-prop atlas.
- Connected four-frame CG sequences to Q002, the Q003 hunt route, Q005 and Q006; added campaign continuation through save/load during quest and CG states.
- Integrated the Q003 boar hunt with real turn-based victories and the Makrura three-phase boss/arena flow; trap and surplus remain noncombat alternatives.
- Added `campaign_branch_matrix_test.gd` (320 checks across all 32 authored choices), `campaign_content_integrity_test.gd` (130 checks), and 21 current campaign QA screenshots under `docs/qa/screenshots/phase2/`.
- Added a second wild-boar image as `entity_wild_boar_candidate_v002.png`; it remains a static candidate, not final/animated art.

### Changed

- New Game now starts the canonical Echo Isles campaign; the legacy tide-flow prototype is no longer the default path.
- Q004 now preserves frog/inventory consistency across branch outcomes and grants the antidote once, with quality reflecting captured reagents.
- Branch responses, interaction dialogue, quest objective labels and campaign CG captions remain PT-BR and reflect saved choices.
- NPC speaker anchors are data-driven, checked against walkable ground, and remain visible during their dialogue even when the interaction objective completes immediately.
- Q008 now ends at a persistent `ECHO_ISLES_COMPLETE` departure state; it does not load the unbuilt Sen’jin zone.
- Updated roadmap, acceptance matrix, asset coverage, production status, QA report and known-issues register to record the completed Phase 2 gate and separate later scope.

### Fixed

- Corrected world-marker visibility/clamping and modal HUD competition in dialogue/combat.
- Corrected campaign dialogue variants for Q001 choice, Q003 route, Q004 method/antidote quality, Q007 resolution and Q008 farewells.
- Corrected the Q004 delivery gate to require all six live frogs and made the antidote reward idempotent.
- Renamed the Q004 progress screenshot so it no longer claims to show a dedicated portrait.

### Known limitations

- Phase 2 is complete for Echo Isles and is classified **B — INTERNAL REVIEW READY**, not public-demo or M30 ready.
- Sen’jin and `QST_SEN_009` are Phase 3. The 35/100 roadmap estimate remains planning only; no game-completion percentage is claimed.
- Apprentice/children/quest props and wild-boar art are candidates; most NPC dialogue portraits are temporary sprite crops; final enemy animation assets remain open.
- Music redistribution/commercial rights and final authored SFX are unresolved. No external player playtest or clean exported-install test is claimed.

## ROADMAP 30 — Phase 2 implementation progress (historical checkpoint) — 2026-10-08

### Added

- Generated a static wild-boar sprite candidate at `01_ASSETS/kataklysma/character/entities/sprites/wild_boar/CANDIDATE/entity_wild_boar_candidate_v001.png`; transparency and in-game rendering were checked, but the art remains a candidate pending identity/style approval and animation work.
- Added a common-turn-combat stat profile and asset routing for wild boar; corrected the combat enemy name label to follow the resolved enemy.
- Added a GUI capture for the wild-boar encounter at `docs/qa/screenshots/24_wild_boar_candidate.png`.

### Changed

- Echo Isles' common monster-ambush pool now includes wild boar alongside the existing water spirit and Makrura candidates.

### Fixed

- The combat nameplate no longer stays hardcoded to “Makrura Corrompida” when another enemy is loaded.

### Known limitations

- This is one common enemy candidate, not the canonical hunt quest integration. The campaign runtime, QST_ECHO_001–008 progression, quest-specific props/dialogue/CG triggers and campaign save flow remain outside the playable scene; Phase 2 stays open (KI-007/KI-010/KI-012).

## Echo Isles — Public Demo Completion Sprint

### Added

- Real Kataklysma directional sprite assets under `01_ASSETS/kataklysma/sprites/directional/`:
  - 2 idle frames for back, left and right;
  - 8 walk frames for back, left and right;
  - right-facing frames mirrored from the approved lateral silhouette, with the same canvas and baseline.
- Walkability debug overlay toggled with `F10`, showing walkable polygons and collision blockers.
- PT-BR quest dialogue data at `03_GODOT/data/dialogue/pt_BR/quest_01.json`.
- Dedicated Zek'Ranu bust portrait cropped from the identity-locked render.
- Twenty named visual QA screenshots under `docs/qa/screenshots/`.

### Changed

- Kataklysma and Zek'Ranu scale set to `0.26`; player foot collision is now `20 × 12` at a `48 px` foot offset.
- Player animation routing now uses the last movement direction and does not reuse the frontal animation for Kataklysma's back/left/right states.
- Echo Isles movement uses hand-authored polygonal walkable areas rather than broad rectangular regions.
- Dialogue uses a taller panel, dedicated portraits, five readable PT-BR choices and reduced HUD competition while open.
- Tutorial fades after three seconds or 380 px of movement and persists through save/load.
- Main-menu title is canonicalized to `LUST SHAMAN'S JOURNEY`.

### Fixed

- Directional animation resources no longer resolve to frontal fallback frames for Kataklysma.
- The previous mixed English/PT-BR intro line was replaced with PT-BR.
- Zek'Ranu no longer uses the full-body render directly inside the dialogue portrait frame.
- F10 debug overlay is disabled by default and does not alter the release presentation.

### Known limitations

- Walkability is now polygonal and substantially narrower, but still requires a final in-editor shoreline/vegetation pass before a public release classification.
- Authored music, ambience, display font and a full options screen remain outside this sprint.

## Final Walkability & Release Gate Sprint

### Added

- Final-release QA runner covering 15 escape points and 7 physical blocker probes.
- Final-release screenshot capture covering menu, scale, walkability overlays, blockers, directional movement, dialogue, minimap, quest progress, CG, combat and gameplay.
- Explicit demo version `0.1.0-demo` in `project.godot` and the main menu footer.

### Changed

- Walkability polygons were narrowed around the arena, cabin approach, Zek'Ranu route, totem platform, bridge and southern paths.
- Central rock exclusion was added to the walkability whitelist.
- Release QA now records each requested map escape test individually.

### Known limitations

- The release overlay still shows areas where the polygon edges need another art-directed shoreline/vegetation pass. The release gate therefore remains B — INTERNAL REVIEW READY.

## KI-001–KI-006 implementation start — 2026-10-07

### Added

- Runtime options panel, reachable from the main menu and pause menu, with master/music/SFX volume, fullscreen, 1280×720/1600×900/1920×1080 window sizes, minimap and camera toggles, and saved remapping for movement, interaction and pause.
- Inter UI font and Cinzel display font, each with its upstream SIL OFL license file.
- Dedicated generated Zek'Ranu portrait v002, based on the existing identity-locked render.
- A generated Echo Isles field-music candidate, plus separate Music and SFX audio buses.
- Zek'Ranu ambient waypoint movement, timed waits, proximity pause and dynamic interaction/quest/minimap anchors.

### Changed

- Replaced the broad walkable regions with ten smaller land/path polygons and added five-point foot-area validation with axis-separated movement.
- The NPC dialogue now loads the new dedicated portrait. The old crop remains preserved as an earlier asset.
- Audio manager starts/stops the field track with gameplay and checks for event-specific OGG files before using its procedural fallback.
- Project-wide UI typography now defaults to Inter; selected headings use Cinzel.

### Fixed

- No issue is marked Fixed in this implementation pass because the changed systems have not yet received Godot runtime or visual QA.

### Known limitations

- KI-001 remains OPEN after current F10 visual review and sampled boundary probes; the remaining polygon/obstacle edge corrections are still required.
- The generated music is watermarked and its redistribution/commercial-use terms are not cleared; final authored SFX remain absent.
- Options, fonts, portrait integration and Zek'Ranu's route require Godot QA. NPC routines still cover only Zek'Ranu, not the entire population.
- The prior screenshot package shows the older walkability geometry and must not be cited as evidence for this revision.

## M30 baseline alignment — 2026-10-07

### Changed

- Updated `zones.json` to the seven campaign regions in the Narrative Bible; Orgrimmar is explicitly marked as missing its map background.
- Catalogued the Eye shrine as a special scripted finale location instead of an eighth travel region.
- Marked the PT-BR tide dialogue JSON as a non-canonical prototype; the hardcoded runtime flow is not yet mapped to a canonical quest.
- Added `KI-007` for quest/CG canon mismatch, `KI-008` for event-type routing and `KI-009` for missing Orgrimmar background.
- Reconciled the CG roster, project start guide, release notes and production status so asset approval is distinguished from runtime integration and current-build QA.
- Recorded the production baseline and scope decisions in `docs/decisions/M30_CANONICAL_BASELINE.md`.
- Added `docs/production/M30_WORK_BREAKDOWN.md` with a preliminary effort-weighted estimate for the full game and M30 scope.
- Added `docs/production/M30_QUEST_ACCEPTANCE.md` with source-traced objectives, scene IDs, branch outcomes, flags and acceptance criteria for the nine-quest M30 cutoff.
- Added `docs/production/M30_ASSET_COVERAGE.md` separating integrated assets, candidates and missing requirements by quest; selected Mak’Jala + Rak’jin as the two `QST_ECHO_008` farewell NPCs per user decision.
- Updated zone metadata to distinguish Echo Isles' runtime-loaded concept map from Sen'jin's concept-only background; clarified the CG variants README about asset approval versus runtime integration.
- Versioned the zone catalogue as v003 after correcting the actual Echo Isles and Sen'jin map availability statuses.
- Added `KI-010`–`KI-012` for missing canonical M30 quest flows, the unbuilt Sen'jin map and missing quest support assets.

## Phase 1 QA and event-routing pass — 2026-10-07

### Changed

- Separated the Echo Isles zone ID from the encounter-table ID so step-based rolls query `echo_isles_day` rather than the non-table zone identifier.
- Restricted combat startup to `monster_ambush`; supported weakened water spirit and corrupted Makrura actor IDs are resolved explicitly. NPC walk-by and resource-find still display pending notices, not completed interactions.
- Added the Echo Isles background to the minimap with player/quest/objective markers.
- Added seven local training-prop exclusion polygons and smoke checks for their representative footprints; shoreline/cliff geometry remains approximate and KI-001 stays open.
- Updated key labels to use Godot's keycode string API so options and controls do not emit unsupported DisplayServer calls in headless runs.

### Added

- Expanded `demo_smoke_test.gd` to assert camera attachment, tutorial timer/fade, dialogue attribute and affinity consequences, all four CG frame transitions, and save/load of quest/attributes/affinity/flags/POIs.
- Updated `capture_release_qa.gd` to validate safe edge positions and rejected water/cliff/rock targets before capturing; it writes the current 22 named PNGs with the F10 overlay only in the dedicated debug capture.
- Current Godot 4.7.2 evidence and per-system results in `QA_REPORT.md`.

### Fixed

- The encounter table lookup no longer uses the Echo Isles zone ID, which previously prevented the intended table from rolling.
- Random non-combat events no longer start turn combat.
- QA capture no longer reports success when a viewport image is empty or an edge screenshot position is outside walkability.

### Known limitations

- Phase 1 is still in progress. The 22 geometry probes pass, but F10 visual review shows approximate polygon/obstacle edges; KI-001 remains OPEN and the build remains B — INTERNAL REVIEW READY.
- The current quest and CG are still a non-canonical prototype (KI-007); NPC/resource encounters are pending handlers; options, scale and NPC-route review remain partial.
- No new character sprites were generated in this QA pass; the already-present directional sets are the ones integrated and captured.
- M30 canonical Echo Isles quests and playable Sen'jin remain unimplemented (KI-010/KI-011).

### Open

- User-selected content cutoff: Echo Isles `QST_ECHO_001`–`QST_ECHO_008`, transition to Sen'jin, and `QST_SEN_009`.
- Preliminary plan estimates this cutoff at 35/100 relative effort points (rough range 30%–45%); this is neither empirically validated nor completed progress.
- Phase 0 planning baseline is frozen. Asset creation/integration and current-build QA remain open; no numeric completion percentage is claimed.
- No runtime or parser QA was performed as part of this documentation/data alignment.

## Phase 1 acceptance closure — 2026-10-08

### Added

- Added data-driven Echo Isles walkability in `data/walkability/echo_isles.json`: 16 named walkable regions, 17 named physical blocker polygons and centralized player/NPC scale, foot-collider, interaction and camera calibration.
- Added `quest_state_runtime.gd`, `data/quest_states.json`, and PT-BR quest/encounter dialogue JSON; runtime now consumes the separated state and text while labeling the active story as a non-canonical prototype.
- Completed Echo Isles handlers for NPC walk-by, collectable resources and spirit omens; only `monster_ambush` starts combat, and zone/spawn rules prevent events in water or unbuilt regions.
- Added `phase_one_acceptance_test.gd` for menu/options, display mode/resolution, settings persistence/remapping, map route and blocker QA, audio routing, events/NPC routine, quest/CG, save/load and calibrated scale.
- Regenerated the current 23-image GUI QA set, including the F10 map overlay and full options panel.

### Changed

- Calibrated Kataklysma and Zek'Ranu to `0.22`, player foot collision to `20×12` at a `40 px` offset, and camera zoom to `1.18`; measured road-to-sprite ratio is `2.53:1`.
- Replaced the earlier broad/prototype south and east coast walkability shapes with polygons following the beach access, stairs and bridge landing; added physical collision geometry for the named map blockers.
- F10 overlay remains hidden by default and now visualizes the current full-map whitelist and blockers for QA.
- Options menu now passes focus, volume, resolution/fullscreen, remapping, duplicate binding, persistence and Continue save-state tests.

### Fixed

- Corrected the south quest investigation position to visible sand and adjusted its marker away from Kataklysma; visual ground sampling reports `273/273` sand pixels at the quest point and east bridge landing.
- Completed non-combat event behavior and collection/effect persistence for the Echo Isles encounter types rather than leaving pending notices.
- Corrected the final walkability probe to use the actual safe interaction approach to Zek'Ranu on the dirt path.
- Closed Phase 1 QA issues KI-001, KI-003, KI-004, KI-006 and KI-008 for the defined Echo Isles scope.

### Known limitations

- Phase 1 is complete: parser/import, smoke, 211 headless checks, 216 GUI checks, 22/22 boundary/blocker probes and the 23-image capture pass. Zek'Ranu's routine also passed while the player collider physically traversed a route. See `QA_REPORT.md`.
- KI-002 remains open for music distribution rights and final authored SFX; playback/routing integration is tested but not release-audio approval.
- KI-007 remains open because the current quest/CG is a non-canonical prototype. Canonical M30 quests, Sen'jin and associated content remain unimplemented (KI-010–KI-012).
- The 35/100 M30 effort estimate remains a planning estimate, not measured completion progress.

## Roadmap 30 Phase 2 foundation (historical checkpoint) — 2026-10-08

### Added

- Canonical Echo Isles campaign catalog for `QST_ECHO_001`–`QST_ECHO_008`, including PT-BR objective labels, scene IDs, branch groups, prerequisite order, consequence data, optional interactions, conditional departure and the documented noncombat alternatives.
- Reusable `CampaignQuestRuntime` for quest state transitions, objective progress, conditional branches/checks, one-time effects, flags, attributes, affinity/trust/reputation, inventory, journal/unlocks and save snapshots with safe position/chapter/tutorial/event state.
- `campaign_quest_runtime_test.gd` with 84 automated checks for campaign state and persistence behavior.

### Changed

- Updated roadmap, QA report, production status and issue tracking to mark Phase 2 as in progress while keeping the current main-scene flow explicitly non-canonical.

### Fixed

- Corrected the content model to distinguish NPC trust from affinity, and to award the Makrura fragment once on encounter resolution before applying its post-battle disposition.

### Known limitations

- The new campaign catalog/runtime is isolated and is not yet connected to the playable scene, menu, HUD, dialogue, CG system, map interactions or combat.
- Full canonical PT-BR dialogue, actor/prop assets, quest-specific CG approval and end-to-end campaign QA remain open. Phase 2 is not complete; the build remains B — INTERNAL REVIEW READY.
