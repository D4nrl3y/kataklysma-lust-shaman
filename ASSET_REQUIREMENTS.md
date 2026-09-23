# Asset Requirements — Echo Isles Demo

## Kataklysma directional sprites

Identity lock: the existing Kataklysma troll shaman — lavender-blue skin, platinum ponytail, long ears, amber eyes, lower tusks, brown tribal shaman outfit, feathers and ornaments.

| Set | Directory | Frames | Canvas | Pivot/baseline | FPS | Status |
|---|---|---:|---|---|---:|---|
| Idle front | `01_ASSETS/kataklysma/sprites/idle/` | 4 | existing approved front canvas | existing feet baseline | 4 | COMPLETE |
| Idle back | `01_ASSETS/kataklysma/sprites/directional/idle_back/` | 2 | 362×543 PNG RGBA | centered feet baseline | 3 | COMPLETE |
| Idle left | `01_ASSETS/kataklysma/sprites/directional/idle_left/` | 2 | 362×543 PNG RGBA | centered feet baseline | 3 | COMPLETE |
| Idle right | `01_ASSETS/kataklysma/sprites/directional/idle_right/` | 2 | 362×543 PNG RGBA | centered feet baseline | 3 | COMPLETE |
| Walk front | `01_ASSETS/kataklysma/sprites/walk/` | 4 | existing approved front canvas | existing feet baseline | 8 | COMPLETE |
| Walk back | `01_ASSETS/kataklysma/sprites/directional/walk_back/` | 8 | 362×543 PNG RGBA | centered feet baseline | 8 | COMPLETE |
| Walk left | `01_ASSETS/kataklysma/sprites/directional/walk_left/` | 8 | 362×543 PNG RGBA | centered feet baseline | 8 | COMPLETE |
| Walk right | `01_ASSETS/kataklysma/sprites/directional/walk_right/` | 8 | 362×543 PNG RGBA | centered feet baseline | 8 | COMPLETE |

The eight walk frames are ordered as contact, down, passing, up, contact-inverse, down-inverse, passing-inverse and up-inverse. Right-facing frames are a horizontal mirror of the approved lateral silhouette; no asymmetric costume detail currently makes that mirror invalid.

## Runtime integration

- `03_GODOT/scripts/demo_game.gd` loads directional frames only for Kataklysma.
- `velocity.x < 0` routes to `walk_left`; `velocity.x > 0` to `walk_right`.
- `velocity.y < 0` routes to `walk_back`; `velocity.y > 0` to `walk_front`.
- Stopping preserves the last direction and selects the matching idle animation.
- Texture filtering remains nearest-neighbor.
- World scale is `0.26`; foot collision is `20×12` at `48 px` below the actor origin.

## Dialogue assets

- Kataklysma: `01_ASSETS/kataklysma/ui/portraits/neutral/kataklysma_portrait_neutral.png` — existing approved bust.
- Zek'Ranu: `01_ASSETS/kataklysma/ui/portraits/neutral/zekranu_portrait_neutral_v001.png` — dedicated 512×512 bust crop for the demo.
- Quest PT-BR: `03_GODOT/data/dialogue/pt_BR/quest_01.json`.

## Remaining asset requirements

- Licensed display/UI font pair: OPEN, P2.
- Authored Echo Isles music, ambience and final SFX: OPEN, P1.
- Separately authored Zek'Ranu portrait illustration: OPEN, P2.
- Full final polygon pass for every shoreline, cliff, vegetation cluster and small island: OPEN, P0 map requirement.
