# QA Report — ROADMAP 30 Phases 1–3

Build: `0.1.0-demo`
Windows package metadata version: `0.1.0` (the in-game label remains `0.1.0-demo`)
QA date: 2026-10-08
Engine: Godot `4.7.2.stable.official` (portable QA engine; not bundled in the project)
Classification: **B — INTERNAL REVIEW READY**
Roadmap state: **Phases 1 and 2 closed; Phase 3 implementation and local QA in progress; independent playtest and clean exported-install gate remain open; M30 delivery not complete.**

## Acceptance summary

The Phase 1 and Phase 2 gates are **CLOSED**. The Phase 3 runtime now continues from Echo Isles into Sen’jin and resolves `QST_SEN_009`; its current automated and GUI evidence is recorded in the dated section at the end of this report. The phase remains open pending independent playtest, comprehensive human visual review and export/clean-install validation.

This is not approval for public release or a claim that 30% of the game is complete. The build remains **B — INTERNAL REVIEW READY**: KI-011 remains open for Sen’jin visual/map review, the external test and clean installation have not been completed (KI-013), music redistribution/commercial terms and final authored SFX remain unresolved (KI-002), and candidate assets/portraits still need art finalization (KI-012).

## Executed checks

| Test | Result | Actual evidence |
|---|---|---|
| Godot editor import/parser | PASS | `Godot --headless --editor --path . --quit`, exit 0; no parser/resource errors |
| Main scene and menu/new game | PASS | `demo_smoke_test.gd`, exit 0; menu and new-game path instantiate |
| Main menu / Continue | PASS | Acceptance asserts five focused controls, Continue disabled without save and enabled after save; current menu screenshot |
| Options | PASS | Master/music/SFX sliders and buses, minimap/camera toggles, six remappable actions, duplicate rejection, settings reload/persistence and keyboard focus tested |
| Display mode and resolution | PASS | GUI readback confirms fullscreen and windowed modes, 1600×900 and 1280×720 |
| Player and NPC scale | PASS | Both at `0.22`; foot collider `20×12` at `40 px`; measured road-to-sprite ratio `2.53:1` (target `2.5–3.0:1`); cabin/training screenshots reviewed |
| Walkable map / F10 | PASS | 16 whitelist polygons, 17 named blocker polygons; F10 toggles and defaults off; full-map overlay reviewed against dirt routes, beach, bridge, stairs and blockers |
| Walkability paths | PASS | Grid search plus real `CharacterBody2D.move_and_collide` traversals to cabin access, Zek'Ranu approach, altar, cave, bridge and both beach objectives |
| Water, cliffs, rocks, vegetation, inaccessible edges | PASS | 15 named walkability point probes and 7 physical blocker probes; deliberate rejected targets include west/south/east water, waterfall, cliff, central rocks, north vegetation, small island and map boundary |
| Props and NPC collision | PASS | 17 physical polygons are instantiated; 6 representative training props and Zek'Ranu's moving blocker are checked |
| Camera / Y-sort | PASS | Smoke and runtime assertions verify camera limits/follow and shared Y-sorted world root |
| Directional idle/walk | PASS | All eight directions have dedicated resources and expected frames; front fallback rejected; current back/left/right captures generated |
| Dialogue, portraits, choices | PASS | PT-BR intro and five vertical choices load from data; dedicated Zek'Ranu bust and Kataklysma portrait appear; HUD competition is suppressed while open |
| Attributes and quest state | PASS — prototype | Choice effects and `available → in_progress → complete → turned_in` transitions tested using separated quest-state data |
| CG and investigation | PASS — prototype | CG sequence advances and closes; investigation is reachable and its sampled foot area is `273/273` sand pixels |
| Minimap | PASS — Echo Isles scope | Map background, player/NPC/quest/objective/resource markers render; visibility option toggles |
| Events / region rules | PASS — Echo Isles scope | NPC walk-by, collectable resource and spirit omen handlers execute without combat; resource persists; Echo Isles spawn region accepted and water/unbuilt Sen'jin rejected |
| Zek'Ranu routine | PASS — Echo Isles scope | Waypoint simulation advances; during a physical player-collider traverse to the cave the NPC routine runs concurrently, stays on whitelist and keeps its collision anchor synced |
| Audio routing | PASS — runtime integration | GUI test starts/stops the looping ambience and verifies procedural UI tone playback on SFX bus; headless confirms Music/SFX configuration; ffprobe/FFmpeg decode succeeds |
| Tutorial, pause, save/load | PASS — current prototype | Tutorial flag persists; pause/resume works; position, quest, attributes, affinity, flags and POIs round-trip |
| End-to-end current loop | PASS — prototype | Menu → new game → NPC dialogue → choice/attribute → quest update → CG → investigation → save/load, asserted by `phase_one_acceptance_test.gd` |

## Test runs

- `--headless --editor --path . --quit`: **PASS**, exit 0.
- `--headless --path . --script res://99_AUDIT/demo_smoke_test.gd`: **PASS**, exit 0.
- `--headless --path . --script res://99_AUDIT/phase_one_acceptance_test.gd`: **PASS, 211 checks**, exit 0; no leak/crash warning.
- GUI `--path . --script res://99_AUDIT/phase_one_acceptance_test.gd`: **PASS, 216 checks**, exit 0; includes real display mode/resolution readbacks and SFX playback-state check.
- `--headless --path . --script res://99_AUDIT/final_release_qa.gd`: **PASS, 22/22 point/blocker probes**, exit 0.
- GUI `--path . --script res://99_AUDIT/capture_release_qa.gd`: **PASS, 23 current PNG captures**, exit 0.

## Walkability and scale detail

The map is a single background image, so walkability is authored as named polygons rather than TileSet data. A five-point foot footprint must remain within the 16 walkable regions and outside 17 polygonal blockers; physical collision polygons are created for blockers. The boundary suite covers representative named terrain and deliberate escape attempts; route QA additionally computes traversable paths and physically moves the player collider along them while Zek'Ranu's routine continues.

Scale is `0.22` for Kataklysma and Zek'Ranu. At the selected camera zoom (`1.18`), the measured sprite width is `37.62` world pixels against a `95.00`-pixel road (`2.53:1`). Foot collision and marker/interact offsets use the same calibration data. F10 is a QA-only overlay and is hidden by default.

Audio file inspection: the candidate decodes as MP3, 44.1 kHz stereo, 160.26 seconds; FFmpeg reports mean `-14.3 dB` and source peak `-0.0 dBFS`. The runtime player applies `-3 dB` gain. This verifies file/playback integrity and headroom configuration, not subjective mix quality or redistribution rights; KI-002 remains open for those release requirements.

## Current screenshot evidence

Fresh GUI captures live in `docs/qa/screenshots/`. The authoritative current set is `01_menu_final.png` through `23_options_menu.png`: menu; cabin/training scale; whole-map F10 overlay; water/cliff/rocks; idle and walk directions; both portraits/dialogue choices; minimap; quest before/after; gameplay; CG; combat; and options. Historical `*_release_*.png` captures are not part of this evidence set.

The current Sen’jin set is `docs/qa/screenshots/phase3/01_senjin_arrival_gameplay.png` through `08_senjin_walkability_debug.png`, plus the Ruk’ka/council/resolution sequence; all eight were freshly captured in Godot GUI on 2026-10-08 and visually reviewed.

## Remaining tracked issues outside the Phase 2 gate

- KI-002: generated music candidate's redistribution/commercial terms need clearance; final authored SFX remain a production task. Runtime playback/routing passed, but this is not release audio approval.
- KI-007: closed for the canonical Echo Isles campaign. The legacy tide prototype is not the default New Game flow.
- KI-010: QST_SEN_009 content is now implemented and its four branches are covered by runtime/playthrough tests. KI-011 remains open for human visual review of the flattened Sen’jin map/candidate foreground and complete edge validation.
- KI-013: no independent external playtest or clean exported-install run has been completed.
- KI-012: candidate props/apprentice/children/boar art, dedicated NPC busts and broader enemy assets remain post-Phase-2 visual production.
- KI-009: Orgrimmar and full-world coverage remain later production.
- Only Zek'Ranu has an ambient route in Echo Isles; broader NPC population/schedules are later content scope.
- No numeric project-completion percentage is claimed. **Do not label the build PUBLIC DEMO READY or “30% complete.”**

## Gate decision

**ROADMAP 30 — Phases 1 and 2: COMPLETE. Phase 3: IN PROGRESS; GATE OPEN.** Echo Isles and Sen’jin are playable in the local project; full acceptance still requires the two pending Phase 3 checks above.
**Build classification: B — INTERNAL REVIEW READY.** Public release and M30 gates remain open for Sen’jin, asset/audio clearance and clean-install/export QA.

## Phase 2 foundation check — 2026-10-08 (historical checkpoint; superseded by final acceptance below)

The canonical Echo Isles campaign catalog and isolated quest runtime were added after the Phase 1 gate. `campaign_quest_runtime_test.gd` passes **84/84 checks**, covering eight quest definitions, ordered unlocks, objectives, optional and conditional branches, attribute thresholds with fail-forward, consequence application, Makrura fragment ownership, and save/restore of quest state, flags, attributes, relationships, chapter, safe position, tutorial and deterministic event state. Regression after this addition: Godot parser/import **PASS**, Phase 1 headless acceptance **211/211 PASS**, boundary suite **22/22 PASS**, demo smoke **PASS**. The earlier Phase 1 GUI acceptance evidence remains recorded above; GUI was not rerun as part of this isolated data/runtime change.

This does **not** pass the Phase 2 gameplay gate. The new runtime is not wired to the main scene, menu, HUD, dialogue or CG system; the existing playable flow remains explicitly non-canonical. No Phase 2 quest, CG sequence or boss encounter is reported as integrated or visually approved.

## Phase 2 final acceptance — 2026-10-08

| Test | Result | Actual evidence |
|---|---|---|
| Godot editor import/parser | PASS | Godot 4.7.2 `--headless --editor --path . --quit`, exit 0; all changed campaign scripts and PNG imports load |
| Main menu / canonical New Game | PASS | `campaign_playthrough_test.gd` starts at `QST_ECHO_001` from the public New Game button |
| Campaign runtime and save data | PASS | `campaign_quest_runtime_test.gd`: 90 checks; quest state, objectives, flags, attributes, relationships, chapter, safe position and event/tutorial state round-trip |
| All narrative choices | PASS | `campaign_branch_matrix_test.gd`: 320 checks across all 32 authored branches, including declared effects/flags/objective progress; low-attribute fail-forward is separately covered |
| Q004 charm/frog economy | PASS | `campaign_frog_branch_test.gd`: 15 checks for failed/successful charm, partial credit, barter inventory and restore consistency |
| Campaign content integrity | PASS | `campaign_content_integrity_test.gd`: 130 checks; 37 world interactions, PT-BR dialogue keys, speaker actors at walkable anchors, 20 prop IDs and loaded atlas nodes |
| Q001–Q008 story progression | PASS | `campaign_playthrough_test.gd`; includes CG interruption/resume, boss neutralization, fragment choice, conditional farewells, departure state and final save/load |
| Q003 alternatives and combat hunt | PASS | `campaign_alternate_routes_test.gd`: trap, four actual turn-based boar victories and optional post-hunt rite; surplus route is also exercised by the main playthrough |
| Makrura boss | PASS | `makrura_boss_test.gd`: all three phases, arena interactions and victory path; campaign flow separately verifies neutralization |
| POI placement | PASS | `campaign_anchor_validation.gd`: 37 named interaction anchors are within authored walkability; boundary/physical movement QA remains covered by Phase 1 suite |
| GUI campaign capture | PASS | `capture_campaign_qa.gd`: 21 current 1280×720 screenshots in `docs/qa/screenshots/phase2/`; reviewed cabin, choices, separated NPC/player placement, water-spirit dialogue, boss, departure and hunt/CG frames |
| Regression: base demo and Phase 1 | PASS | smoke; Phase 1 acceptance **211 headless / 216 GUI checks**; 22/22 walkability probes; editor import; all exit 0 |

**Testing scope note:** the campaign harness invokes the same scene interaction logic at authored POIs and saves/loads real runtime state; it positions the test actor at those anchors rather than simulating keyboard walking through all eight quests. Physical movement/walkability and reachable routes were independently tested in Phase 1, and every campaign anchor was revalidated against that geometry. No external player playtest or clean exported-install test is claimed.

**Phase 2 gate: CLOSED.** The build ends at the persisted Echo Isles departure state `ECHO_ISLES_COMPLETE`; it intentionally does not load Sen’jin. Candidate art and portrait polish remain tracked separately and are not described as final. Phase 3 and the overall M30/public-release gates remain open.

## Phase 3 implementation and QA — 2026-10-08

The current local main scene now runs the continuous campaign through Sen’jin. The following checks were executed against this project and current files; they do not replace an external playtest or a clean exported build.

| Test | Result | Actual evidence |
|---|---|---|
| Godot import/parser | PASS | Godot 4.7.2 `--headless --editor --path . --import`, exit 0 after importing the Sen’jin foreground PNG and updated scripts/data. |
| Main-menu smoke | PASS | `demo_smoke_test.gd`, exit 0; current nine-quest catalog is loaded by New Game. |
| Phase 1 regression | PASS | `phase_one_acceptance_test.gd`: 213 headless checks and 218 current GUI checks; updated routing checks prove the Sen’jin plaza is not dispatched through the Echo Isles table. |
| Campaign runtime / all Q009 branches | PASS | `campaign_quest_runtime_test.gd`: 125 checks, including payment, paid messenger, informant, charm pass/fail, zero-gold rejection, migration from the older save schema and consequence flags. |
| Echo Isles branch matrix | PASS | `campaign_branch_matrix_test.gd`: 320 checks across the 32 authored Echo Isles choices. Q009’s four branches are checked separately above. |
| Content and map anchors | PASS | `campaign_content_integrity_test.gd`: 186 checks; 42 total interaction points, PT-BR keys, NPC anchors and 20 existing quest props. |
| Continuous campaign / persistence | PASS | `campaign_playthrough_test.gd`: public New Game → Q001–Q008 → Sen’jin arrival → Q009 investigation → save/load mid-quest → council solution → save/load after completion. Flags, inventory, chapter and position are checked. |
| Sen’jin walkability | PASS — scripted geometry QA | `senjin_walkability_test.gd`: whitelist search reaches 6,932 cells; `CharacterBody2D.test_move` reaches 6,807 cells from the dock spawn. All five Q009 anchors connect within 48 px; 11 route landmarks and 10 water/edge landmarks match their expected walkability; every one of the 26 named blockers has an instantiated physics polygon and an individual `CharacterBody2D.test_move` collision probe. |
| Sen’jin random events | PASS — handler/table scope | Regional spawn/table tests plus the campaign harness exercise the supply reward (idempotent), alchemy request (reagent/affinity) and named-NPC walk-by. Investigation/resolution paths do not start combat; only `monster_ambush` is routed to combat. |
| GUI scene capture | PASS | `capture_senjin_qa.gd`, Godot GUI, exit 0: eight 1280×720 images; arrival, foreground candidate, F10 walkability, arrival dialogue, Ruk’ka reveal, vertical council choices, consequence and resolved quest. Captures were reviewed; the foreground remains labeled a candidate. |
| Export and clean-install smoke | PARTIAL / OPEN | Added a Windows Desktop preset and installed the official Godot 4.7.2 Windows x86_64 release template. Final `--export-release "Windows Desktop"` succeeded with no warning (659,241,336-byte executable; SHA-256 `0D6CB013E49551E270D441273A1E540F79CC1DF2E7B97835A367F8736E918DF6`) at `Builds/Phase3_Internal_Review_2026-10-08/Kataklysma.exe`, outside the repository. Launching it with `--headless --quit-after 90` exited 0; the runtime log contains only the Godot banner. GUI play, save/load from the exported build and a separate clean machine/account remain untested. |
| Independent playtest/duration | NOT RUN / OPEN | No non-developer tester has completed the sequence; request observations on instructions, duration and difficulty before accepting the phase. |

An attempt to pass `campaign_playthrough_test.gd` to the exported executable with `--script` did not emit the test marker or create its unique temporary save within the expected test window; the headless main loop remained active and was stopped. This attempt is **not a test result** and is not counted as a pass or failure.

### Phase 3 limits and gate

- Sen’jin uses one flattened concept background, not independently authored map layers. The integrated foreground clump is explicitly a candidate asset; the visual overlay and blocked samples passed, but do not constitute an artist-approved final map.
- The in-engine F10 polygons are hand-authored approximations of the concept image. Programmatic whitelist and physical-body connectivity pass; a person must still traverse the full shoreline, waterfall/cliffs, stairs, village, dock and map edges while visually comparing them to the art.
- On 2026-10-08 the source background and F10 capture were statically inspected and the named route/boundary tests were expanded. This does not replace a live full-route visual walkthrough by a player; KI-011 remains open until that route is physically traversed and the map alignment is accepted.
- Q009 can be completed and its result survives a fresh save/load. The chapter remains `SENJIN_COMPLETE`, and this slice stops in Sen’jin; no new region is loaded.
- The Computer Use UI controller (`node_repl` / `@oai/sky`) was unavailable in this session. This is why no interactive GUI playtest of the exported executable is claimed; the editor-side GUI captures above are separate evidence.
- Regression rerun on 2026-10-08: 11 headless audit scripts exited 0 — demo smoke, Phase 1 acceptance (213), campaign runtime (125), Echo Isles branch matrix (320), frog branch (15), content integrity (186), full campaign playthrough, alternate routes, Makrura boss, campaign anchors and Sen’jin walkability. This is local automated evidence only.
- **Phase 3 status: IN PROGRESS — GATE OPEN.** Do not advance the roadmap phase until the independent playtest, full visual map review and exported GUI/save-load validation pass. Audio rights/final SFX and broader candidate-art finalization remain release limitations.
