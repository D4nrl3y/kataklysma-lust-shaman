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
- Zek'Ranu: `01_ASSETS/kataklysma/ui/portraits/neutral/zekranu_portrait_dedicated_v002.png` — separately generated square bust illustration based on the identity-locked render; replaces the earlier crop in the demo.
- Quest PT-BR: `03_GODOT/data/dialogue/pt_BR/quest_01.json`.

## Typography

- UI: Inter variable font at `01_ASSETS/kataklysma/ui/fonts/inter/inter_variable.ttf`, applied as the Godot project Theme default.
- Display: Cinzel variable font at `01_ASSETS/kataklysma/ui/fonts/cinzel/cinzel_variable.ttf`, applied to game/menu/dialogue headings.
- Both font folders include the corresponding upstream `OFL.txt` (SIL Open Font License 1.1). Source families: [Google Fonts Inter](https://github.com/google/fonts/tree/main/ofl/inter) and [Google Fonts Cinzel](https://github.com/google/fonts/tree/main/ofl/cinzel).

## Audio

- `01_ASSETS/kataklysma/audio/music/echo_isles_field_ambience_ai_v001.mp3` — generated instrumental field track (92 BPM, B minor, approximately 160 seconds), looped by the runtime audio manager on entering the demo.
- This candidate is watermarked by its generator and its redistribution/commercial-use terms have not been cleared. It is an integration candidate, not release-approved final audio.
- Final authored UI/quest/combat SFX are not yet present. The runtime looks for `<event>.ogg` files under `01_ASSETS/kataklysma/audio/sfx/`; existing procedural tones remain the temporary fallback.

## Walkability and NPC behavior

- `demo_game.gd` now defines ten smaller walkable polygons for the training clearing, cabin access, north trail, mentor route, totem approach, cave road, bridge, stairs and beaches.
- The player's five foot probes (center and four corners) must all remain inside the whitelist and outside blockers. The polygons and blockers remain visible only while F10 debug is enabled.
- Zek'Ranu has a six-point ambient route around his current station, waits between steps, pauses when Kataklysma approaches, and keeps his interaction area, marker, name and minimap icon attached to his live position.
- Options persist separate bindings for four movement directions, interaction/confirm, and pause; arrow keys and the default interaction alternatives remain available.
- This remains an implementation candidate pending in-editor route and shoreline review; the old QA screenshots depict the previous larger polygons.

## Remaining asset requirements

- Release-approved unwatermarked Echo Isles score/ambience and authored SFX: OPEN, P1.
- Full visual review and final polygon adjustments for shorelines, cliffs, vegetation and small islands: OPEN, P0.
- In-game portrait presentation, options controls, typography and NPC routine need Godot QA before their issues can be closed.
