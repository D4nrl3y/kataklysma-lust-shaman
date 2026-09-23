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
