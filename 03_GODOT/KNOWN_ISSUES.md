# Known Issues

| ID | Priority | System | Problem | Impact | Status |
|---|---|---|---|---|---|
| KI-001 | P0 | Walkable map | Polygon whitelist is implemented and narrower than the previous prototype, but the final shoreline, waterfall, dense-vegetation and small-island audit is still open. | High | OPEN |
| KI-002 | P1 | Audio | Procedural tone feedback is active; authored Echo Isles ambience, music and final SFX are not yet in the repository. | Medium | OPEN |
| KI-003 | P1 | Options | Menu/pause options are functional entry points, but audio sliders, video settings and keybinding UI remain simplified. | Medium | OPEN |
| KI-004 | P1 | Typography | The current UI uses a readable system fallback. A redistributable display/UI font pairing still needs licensing and integration. | Low | OPEN |
| KI-005 | P2 | NPC presentation | Zek'Ranu now has a dedicated bust crop, but the crop is derived from the approved render rather than a separately authored portrait illustration. | Low | OPEN |
| KI-006 | P2 | NPC routines | Random events and combat are functional; authored ambient NPC routines and full population of every non-critical NPC are outside this Echo Isles sprint. | Low | OPEN |

## Closed this sprint

- Directional sprite blocker closed for Kataklysma: dedicated idle back/left/right and walk back/left/right assets are present and integrated. See `ASSET_REQUIREMENTS.md`.
- Mixed-language intro line closed for the demo path: the active quest dialogue is PT-BR and the first localization data file is checked in.
- Tutorial persistence blocker closed: timer/distance fade and save flag are implemented.
