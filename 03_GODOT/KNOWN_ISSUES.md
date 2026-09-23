# KNOWN ISSUES

| ID | Priority | System | Problem | Impact | Status |
|----|----------|--------|---------|--------|--------|
| KI-001 | P0 | Directional sprites | Dedicated back/left/right idle and walk PNGs are not present. Current directional states use the existing front frames as a safe fallback; lateral visuals are not considered final. Expected names include `chr_kataklysma_idle_left_f001_v001.png`, `chr_kataklysma_idle_right_f001_v001.png`, `chr_kataklysma_walk_left_f001_v001.png` and `chr_kataklysma_walk_right_f001_v001.png`. | High | OPEN |
| KI-002 | P1 | Audio | Procedural tone feedback is active, but authored Echo Isles ambience, music and final SFX are not in the repository. | Medium | OPEN |
| KI-003 | P1 | Walkable map | Current walkability uses broad prototype regions plus static blockers. A final polygon/TileSet pass is still needed to trace every shoreline, vegetation cluster and inaccessible platform. | Medium | OPEN |
| KI-004 | P1 | Options | Menu and pause options are functional entry points, but audio sliders, video settings and keybinding UI are still simplified. | Medium | OPEN |
| KI-005 | P2 | Portraits | Zek'Ranu currently uses his identity-locked full render inside the portrait frame because no dedicated NPC portrait asset exists. | Low | OPEN |
| KI-006 | P2 | Gameplay polish | Final authored display font, particles, camera transition animation and NPC routines are still pending. The current UI uses a readable system fallback. | Low | OPEN |

