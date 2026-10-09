# Kataklysma project start guide

This repository is the Godot project, not an asset pack that must be copied into a new project. Open the repository root containing `project.godot` in Godot 4. The configured main scene is `03_GODOT/scenes/main.tscn`.

## Read first

1. `README.md` — repository layout and portable setup.
2. `ROADMAP_30_PERCENT.md` — current milestone scope and delivery gates.
3. `docs/decisions/M30_CANONICAL_BASELINE.md` — canonical IDs, production decisions and open estimates.
4. `03_GODOT/PRODUCTION_STATUS_V001.md` and `03_GODOT/KNOWN_ISSUES.md` — implementation state and blockers.
5. `03_GODOT/IMPORT_GUIDE.md` — Godot asset paths and integration helpers.

## Project structure

- `00_DOCS/` — narrative bible and retained source documents.
- `01_ASSETS/` — game art, audio and other production assets.
- `02_REFERENCE/` — character canon, visual references and continuity locks.
- `03_GODOT/` — project scenes, scripts, data and engine-facing documentation.
- `90_SOURCE_ARCHIVE/` — source and legacy materials retained for recovery.
- `99_AUDIT/` — inventories, QA history, validation scripts and production rosters.
- `docs/` — current roadmap, decisions and QA evidence.

## Current playable build

The default New Game flow now continues from the eight Echo Isles quests into Sen’jin and `QST_SEN_009`. Phase 3 code, automated tests and eight editor GUI captures pass. A Windows release preset/template now produce an executable that passes headless startup outside the project; independent playtest and exported GUI/save-load validation are still open. See `03_GODOT/QA_REPORT.md`, `03_GODOT/KNOWN_ISSUES.md` and `docs/qa/screenshots/phase3/`. Character movement uses front/back/left/right sprites with cardinal-direction selection; there are no dedicated diagonal animations.

The project remains for internal review, not a public/M30 release. Candidate art, audio rights, Sen’jin visual review and clean-install/export QA remain open. Check `03_GODOT/KNOWN_ISSUES.md` before relying on a PASS outside the explicitly tested scope.
