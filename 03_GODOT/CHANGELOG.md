# Changelog

## Echo Isles Public Demo Polish Sprint

### Added

- Directional player animation states: `idle_front`, `idle_back`, `idle_left`, `idle_right`, `walk_front`, `walk_back`, `walk_left`, `walk_right`.
- Lateral movement state selection based on velocity, with the last direction preserved while idle.
- Dialogue portraits for Zek'Ranu and Kataklysma with a neutral fallback.
- Walkable-region validation, physical boundaries and NPC collision.
- QA screenshot capture pipeline under `docs/qa/screenshots/`.

### Changed

- Player and NPC world scale reduced and foot collision kept separate from the visual sprite.
- HUD tracker and minimap compacted.
- Main menu buttons received normal, hover, focus, pressed and disabled states.
- Dialogue panel received portrait area, wrapping and expanded choice layout.
- Main menu typography uses a readable fallback because no licensed project font exists yet.

### Fixed

- Movement outside the configured walkable regions.
- Crossing the configured water, rock, cliff and boundary blockers.
- Fixed NPC overlap through the NPC collision body.
- Missing dialogue portrait rendering.
- Dialogue choice text clipping in the expanded panel.
- Scale inconsistency between Kataklysma, Zek'Ranu and the map.

