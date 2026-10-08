# Known Issues

| ID | Priority | System | Problem | Impact | Status |
|---|---|---|---|---|---|
| KI-001 | P0 | Walkable map | Walkability polygons were narrowed and the foot collider now samples center plus four corners. The new geometry has not had an in-editor F10 shoreline/cliff/vegetation pass; no escape-test result is carried forward from the old polygon set. | High | OPEN — VISUAL QA PENDING |
| KI-002 | P1 | Audio | An AI-generated, watermarked Echo Isles field track is integrated as a looping candidate. Commercial/redistribution terms are not cleared; final authored SFX are still missing and procedural tones remain the fallback. | Medium | PARTIAL — RELEASE AUDIO OPEN |
| KI-003 | P1 | Options | Runtime settings now include master/music/SFX sliders, fullscreen, three window sizes, minimap/camera toggles and saved remapping for movement, interaction and pause. Not yet exercised in Godot. | Medium | IMPLEMENTED — QA PENDING |
| KI-004 | P1/P2 | Typography | Inter is the UI Theme default and Cinzel is used for display headings; both variable font files and SIL OFL 1.1 licenses are in the repository. Font import/rendering has not yet been checked in Godot. | Low | IMPLEMENTED — QA PENDING |
| KI-005 | P2 | NPC presentation | A separately generated Zek'Ranu bust portrait replaces the previous render crop in the dialogue path. In-game crop/identity presentation is not yet checked. | Low | IMPLEMENTED — QA PENDING |
| KI-006 | P2 | NPC routines | Zek'Ranu now has a short ambient waypoint/wait routine that pauses near the player and updates interaction/quest/minimap anchors. Other non-critical NPCs and broader schedules remain unimplemented; route needs Godot review. | Low | PARTIAL — ROUTE QA / POPULATION OPEN |
| KI-007 | P1 | Canonical quest/CG wiring | The active tide-purification flow is a non-canonical prototype and triggers the Echo 002 totem-choice CG. The dialogue JSON is not loaded by the runtime. Map the prototype to no quest ID until its objectives, choices and CG trigger are reconciled with the Narrative Bible. | High | OPEN — CANONICAL FLOW NOT IMPLEMENTED |
| KI-008 | P1 | Random event routing | The encounter callback starts combat for any event emitted by the weighted table, including non-combat event types. Actor resolution currently covers only a weakened water spirit and corrupted Makrura. | High | OPEN — EVENT DISPATCH REQUIRED |
| KI-009 | P2 | Full-world coverage | Orgrimmar is one of the seven canonical campaign regions but has no background asset. It is outside the proposed M30 playable cut; retain as a later full-game production requirement. | Medium | OPEN — ART NOT PRODUCED |

## Closed this sprint

- Directional sprite blocker closed for Kataklysma: dedicated idle back/left/right and walk back/left/right assets are present and integrated. See `ASSET_REQUIREMENTS.md`.
- Mixed-language intro line closed for the demo path: the active quest dialogue is PT-BR and the first localization data file is checked in.
- Tutorial persistence blocker closed: timer/distance fade and save flag are implemented.

## Current implementation note — 2026-10-07

No tests or in-editor visual QA were run for the changes above in this implementation pass. The previous QA results refer to the older build and old walkability polygons. KI-001 remains OPEN; the project remains B — INTERNAL REVIEW READY and is not approved for public release.
