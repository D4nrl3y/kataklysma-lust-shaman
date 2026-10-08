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

## Current playable prototype

The active runtime is an Echo Isles prototype. Its movement sprites support front, back, left and right; no dedicated diagonal animations are present. The other region backgrounds, NPC sprite sets and CG sequences are not automatically playable content: each needs scene integration and QA before being counted as delivered.

The project is for internal review. Check `03_GODOT/KNOWN_ISSUES.md` and the dated note in `03_GODOT/QA_REPORT.md` before relying on any historical PASS result.
