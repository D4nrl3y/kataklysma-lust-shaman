# Kataklysma production status

**Snapshot:** 2026-10-08

**Project:** `Kataklysma — Lust Shaman's Journey`

**Current build:** `0.1.0-demo`, internal prototype

**Roadmap status:** Fases 0, 1 e 2 concluídas. Fase 3 implementada; preset Windows criado, export release e smoke headless externo ao projeto passaram. O gate permanece aberto para playtest independente, revisão visual e validação GUI/save-load da build exportada.

**M30 status:** não alcançado; percentual real do projeto não calculado.

## Production assets

- Kataklysma has front, back, left and right idle/walk sprites. There are no dedicated diagonal movement animations.
- 13 named NPCs have neutral renders and front-facing `IDLE`/`WALK` sets. They do not yet have production `CAST`/`COMBAT` sets.
- 3 priority entities have neutral renders and partial field/action sprite sets.
- 12 CG sequences have 48 v002 frames in the asset catalog. The current Phase 2 campaign integrates four-frame sequences for `QST_ECHO_002`, the hunt route of `QST_ECHO_003`, `QST_ECHO_005` and `QST_ECHO_006`; other variants remain catalog assets, not automatically playable scenes.
- Background concepts exist for Echo Isles, Sen'jin Village, Durotar, Razor Hill, Northern Barrens, Ratchet and the Eye shrine. Orgrimmar has no background. The Eye shrine is catalogued as a special finale location, not one of the seven campaign regions.
- Character identity locks, sprite production manifests, quest markers, menu/key art, portraits, fonts and a watermarked Echo Isles music candidate are present in the repository.

Asset presence does not establish runtime integration, licensing clearance or approval for the current build.

## Runtime prototype

The project opens from the repository root and its main scene is `03_GODOT/scenes/main.tscn`. New Game starts the canonical Echo Isles campaign and transitions into Sen’jin after Q008. The runtime contains all nine quests through `QST_SEN_009`, including 42 interaction points, data-driven PT-BR dialogue, branch outcomes, combat/events, four CG sequences and cross-zone save/load. Sen’jin's five quest anchors are connected from its dock spawn in the current walkability test.

The legacy tide-flow prototype is retained as historical content and is not the default New Game path. Campaign state, interactions and dialogue remain data-driven. Q008 now switches to the Sen’jin map, starts Q009, and preserves chapter/quest state through save/load; the Q009 ending also survives a fresh load.

`03_GODOT/data/zones.json` still tracks the seven campaign regions and the Eye shrine as a special scripted location. Echo Isles and Sen’jin are connected to the runtime; later regions remain unbuilt. Sen’jin uses a flattened concept background, 10 walkable regions, 26 named blockers, an arrival spawn, five quest POIs and one visibly labeled foreground-art candidate. Modular map art and a full human visual walkthrough remain open.

## QA and release status

- ROADMAP 30 Phases 1 and 2 are closed. The latest 11-script regression rerun passed, including 125 campaign runtime checks, 320 Echo Isles choice checks, 186 content checks, full-campaign save/load and Sen’jin walkability (6,932 whitelist / 6,807 physical reachable cells, five Q009 anchors, 11 expected-walkable landmarks, 10 rejected water/edge landmarks and 26 individual blocker collision probes). Eight editor GUI captures are in `docs/qa/screenshots/phase3/`. A 659,241,336-byte Windows release exported and launched in headless smoke outside the project; live visual route review, GUI/save-load on the export and independent playtest remain open. See `QA_REPORT.md`.
- `KI-001`, `KI-003`, `KI-004`, `KI-005`, `KI-006` and `KI-008` are closed for the Phase 1 Echo Isles scope. Broader NPC population/schedules remain later content work.
- `KI-002` remains open for music redistribution/commercial rights and final authored SFX. Runtime playback/routing was tested; that does not approve the current track for release.
- `KI-007` and `KI-010` are closed for the canonical Echo Isles and QST_SEN_009 content. `KI-011` remains open for Sen’jin's full visual/map review; `KI-012` remains open for candidate-asset finalization and broader M30 art. `KI-013` tracks external playtest and clean exported-install validation.
- The field music candidate is watermarked and not cleared for redistribution or commercial use. Final authored SFX are absent.
- Visual sprite QA recorded 60/60 groups after pivot corrections; the report still records edge-contact warnings and is not a substitute for current gameplay review.

**Classification remains B — INTERNAL REVIEW READY.** Phase 3 is not closed. Do not promote the build to public demo or M30 until Sen’jin visual review, an independent playtest, clean-install/export QA, rights-cleared audio and final asset review pass with current evidence.

## Production direction

- Combat remains **turn-based**, following the user's established direction. The Narrative Bible overview describes real-time combat; that source conflict must be formally reconciled before the Bible is used to author further combat content.
- The proposed M30 campaign scope is tracked in `ROADMAP_30_PERCENT.md`. The effort denominator and final cutoff must be settled before any numeric completion claim.
- Full regional scope: Echo Isles, Sen'jin Village, Durotar, Razor Hill, Orgrimmar, Northern Barrens and Ratchet. The Eye shrine is a scripted finale location associated with the Eye quests.
