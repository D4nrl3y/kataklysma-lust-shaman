# Changelog

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

- KI-001 remains OPEN until the new F10 overlay is reviewed against the actual map and deliberate escape attempts are repeated.
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

### Open

- User-selected content cutoff: Echo Isles `QST_ECHO_001`–`QST_ECHO_008`, transition to Sen'jin, and `QST_SEN_009`.
- Preliminary plan estimates this cutoff at 35/100 relative effort points (rough range 30%–45%); this is neither empirically validated nor completed progress.
- Phase 0 planning baseline is frozen. Asset creation/integration and current-build QA remain open; no numeric completion percentage is claimed.
- No runtime or parser QA was performed as part of this documentation/data alignment.
