# CG variant roster

## Production asset status

The production catalog is `03_GODOT/data/cg_variants.json`. It declares **12 sequences**, each with four separate images (`01_start`, `02_development`, `03_climax`, `04_resolution`). The repository inventory contains **48 PNGs** in `01_ASSETS/kataklysma/cg/scenes/VARIANTS/`.

The `approved_sequence_v002` status means the sequence and visual continuity were approved in the asset review recorded by `99_AUDIT/VISUAL_IDENTITY_QA_V002.md`. It does not mean the scene has been implemented or QA-tested in Godot.

## Runtime integration status

The current demo hardcodes only the four frames of `echo_002_zekranu_totem_choice` in `03_GODOT/scripts/demo_game.gd`. The remaining eleven sequences are production assets, not active game content. The active demo triggers this ritual-choice CG after its prototype tide-purification objective; that event wiring must be reconciled with the canonical quest before the sequence is counted as correctly integrated.

## Catalogued sequences

- `echo_002_zekranu_totem_choice`
- `echo_003_zalkiri_mokjala_hunt`
- `echo_004_rakjin_rivalry`
- `echo_005_water_spirit_choice`
- `echo_006_corrupted_makrura_boss`
- `senjin_007_tazrima_rukka_herbs`
- `echo_008_makjala_vision`
- `echo_009_azkarra_storm_ritual`
- `raz_011_korgash_duel`
- `barrens_012_sister_aruka_roadside_vision`
- `ratchet_013_grikzan_razzik_vexa_bargain`
- `end_015_eye_ritual`

Legacy one-image keyframes remain under `01_ASSETS/kataklysma/cg/scenes/legacy_keyframes/`. They are historical references and are not counted among the 48 v002 sequence frames.
