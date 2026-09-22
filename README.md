# Kataklysma — Lust: Shaman's Journey

Development repository for the Godot RPG project.

The repository root is the portable Godot project. Open the folder containing
`project.godot` in Godot 4, or open `kataklysma.code-workspace` in VS Code.
No absolute local paths are required by the project files.

## Project layout

- `00_DOCS/` — lore source and legacy production documentation.
- `01_ASSETS/` — assets ready for game integration: characters, NPCs, entities, sprites, CGs, maps, UI and promotional art.
- `02_REFERENCE/` — canonical visual references for Kataklysma.
- `03_GODOT/` — Godot 4 import helpers, production data and gameplay scaffolding.
- `99_AUDIT/` — manifests, source maps, generation scripts and QA notes.

Start with:

- `project.godot`
- `kataklysma.code-workspace`
- `03_GODOT/IMPORT_GUIDE.md`
- `03_GODOT/PRODUCTION_STATUS_V001.md`
- `03_GODOT/data/zones.json`
- `README_START_HERE.md`

The `90_SOURCE_ARCHIVE/` folder is versioned because it contains legacy/raw material useful for recovery, comparison and future asset revisions. Temporary QA intermediates remain ignored.
