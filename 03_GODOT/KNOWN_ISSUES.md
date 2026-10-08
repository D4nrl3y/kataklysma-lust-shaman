# Known Issues

| ID | Priority | System | Problem | Impact | Status |
|---|---|---|---|---|---|
| KI-001 | P0 | Walkable map | Current whitelist and five foot probes reject 22 sampled boundary points; seven local training-prop footprints were added and six representative positions are checked. The F10 capture still shows approximate vegetation/terrain edges, most solid map art has no dedicated physical collider, and the full rock/cliff perimeter has not been manually traversed. | High | OPEN — VISUAL MAP PASS REQUIRED |
| KI-002 | P1 | Audio | An AI-generated, watermarked Echo Isles field track is integrated as a looping candidate. Commercial/redistribution terms are not cleared; final authored SFX are still missing and procedural tones remain the fallback. | Medium | PARTIAL — RELEASE AUDIO OPEN |
| KI-003 | P1 | Options | Master/music/SFX, fullscreen, resolution, minimap/camera and saved key remapping are implemented. Current smoke covers opening the panel and minimap toggle only; other controls, persistence and focus states need runtime QA. | Medium | PARTIAL — SETTINGS QA OPEN |
| KI-004 | P1/P2 | Typography | Inter/Cinzel and their SIL OFL 1.1 licenses are present and both render in current menu/dialogue captures. Alternate-resolution layout and full UI readability pass remain. | Low | PARTIAL — LAYOUT QA OPEN |
| KI-005 | P2 | NPC presentation | Dedicated Zek'Ranu bust is wired into dialogue and is visible in the current runtime capture. | Low | CLOSED — PORTRAIT VERIFIED |
| KI-006 | P2 | NPC routines | Zek'Ranu has a short ambient waypoint/wait routine that pauses near the player and updates interaction/quest/minimap anchors. Other non-critical NPCs and broader schedules remain unimplemented; route was not manually verified end-to-end. | Low | PARTIAL — ROUTE QA / POPULATION OPEN |
| KI-007 | P1 | Canonical quest/CG wiring | The active tide-purification flow is a non-canonical prototype and triggers the Echo 002 totem-choice CG. The dialogue JSON is not loaded by the runtime. Map the prototype to no quest ID until its objectives, choices and CG trigger are reconciled with the Narrative Bible. | High | OPEN — CANONICAL FLOW NOT IMPLEMENTED |
| KI-008 | P1 | Random event routing | Only `monster_ambush` opens combat and supported water-spirit/Makrura actors resolve. NPC walk-by and resource-find currently display explicit pending notices; event presentation, collection and regional rules are not complete. | High | PARTIAL — NON-COMBAT HANDLERS OPEN |
| KI-009 | P2 | Full-world coverage | Orgrimmar is one of the seven canonical campaign regions but has no background asset. It is outside the proposed M30 playable cut; retain as a later full-game production requirement. | Medium | OPEN — ART NOT PRODUCED |
| KI-010 | P0 | M30 canonical quest content | The active runtime is still the non-canonical tide prototype. None of `QST_ECHO_001`–`QST_ECHO_008` or `QST_SEN_009` exists as a complete playable quest flow with canonical dialogue, branch state and consequences. | High | OPEN — CAMPAIGN NOT IMPLEMENTED |
| KI-011 | P0 | Sen'jin playable map | Sen'jin has only a concept background. There is no runtime zone scene, collision, interaction-point layer, NPC placement/routes, spawn points or encounter regions for the selected M30 ending. | High | OPEN — ZONE NOT BUILT |
| KI-012 | P1 | M30 quest support assets | Static-object asset folder is empty; generic children/apprentice/depot/council actors, boar/common-enemy sprites and most dedicated dialogue portraits are absent. See `docs/production/M30_ASSET_COVERAGE.md` for the per-quest inventory and approved CG candidates. | High | OPEN — ASSET PRODUCTION REQUIRED |

## Closed this sprint

- Directional sprite blocker closed for Kataklysma: dedicated idle back/left/right and walk back/left/right assets are present and integrated. See `ASSET_REQUIREMENTS.md`.
- KI-005 closed: dedicated Zek'Ranu bust is integrated and visibly rendered in the current dialogue capture.
- Mixed-language intro line closed for the demo path: the active quest dialogue is PT-BR and the first localization data file is checked in.
- Tutorial persistence blocker closed: timer/distance fade and save flag are implemented.

## Current implementation note — 2026-10-07

Godot 4.7.2 parser/import, 22 sampled walkability/blocker probes, the expanded end-to-end smoke test, and the GUI screenshot capture were run on this build. Results and limits are in `QA_REPORT.md`; current images are the numbered non-`release` set under `docs/qa/screenshots/`. KI-001 remains OPEN after visual review. The build remains B — INTERNAL REVIEW READY and is not approved for public release.
