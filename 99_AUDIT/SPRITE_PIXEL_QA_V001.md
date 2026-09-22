# Sprite Pixel QA — V001

**Motor:** Godot 4 (`Image`)

**Resultado:** `PASS`

- Grupos verificados: 60
- Falhas de consistência: 0
- Avisos de recorte/edge contact: 220

## Critérios

- quatro frames por animação;
- mesma resolução por sequência;
- silhueta não vazia;
- deriva de baseline e pivô dentro do limite;
- filtro padrão do Godot configurado para nearest (`0`).

## Falhas

Nenhuma.

## Avisos

- player/idle: kataklysma_idle_001.png touches image edge (79 pixels)
- player/idle: kataklysma_idle_002.png touches image edge (79 pixels)
- player/idle: kataklysma_idle_003.png touches image edge (81 pixels)
- player/idle: kataklysma_idle_004.png touches image edge (80 pixels)
- player/cast: kataklysma_cast_001.png touches image edge (91 pixels)
- player/cast: kataklysma_cast_002.png touches image edge (93 pixels)
- player/cast: kataklysma_cast_003.png touches image edge (162 pixels)
- player/cast: kataklysma_cast_004.png touches image edge (91 pixels)
- attribute_sets/agility_max/IDLE: kataklysma_agility_max_idle_002.png touches image edge (6 pixels)
- attribute_sets/agility_max/IDLE: kataklysma_agility_max_idle_003.png touches image edge (2 pixels)
- attribute_sets/agility_max/WALK: kataklysma_agility_max_walk_003.png touches image edge (64 pixels)
- attribute_sets/agility_max/CAST: kataklysma_agility_max_cast_003.png touches image edge (73 pixels)
- attribute_sets/agility_max/CAST: kataklysma_agility_max_cast_004.png touches image edge (21 pixels)
- attribute_sets/corruption_max/IDLE: kataklysma_corruption_max_idle_001.png touches image edge (37 pixels)
- attribute_sets/corruption_max/IDLE: kataklysma_corruption_max_idle_002.png touches image edge (31 pixels)
- attribute_sets/corruption_max/WALK: kataklysma_corruption_max_walk_001.png touches image edge (24 pixels)
- attribute_sets/corruption_max/WALK: kataklysma_corruption_max_walk_002.png touches image edge (23 pixels)
- attribute_sets/corruption_max/WALK: kataklysma_corruption_max_walk_003.png touches image edge (50 pixels)
- attribute_sets/corruption_max/CAST: kataklysma_corruption_max_cast_002.png touches image edge (1 pixels)
- attribute_sets/corruption_max/CAST: kataklysma_corruption_max_cast_003.png touches image edge (53 pixels)
- attribute_sets/corruption_max/CAST: kataklysma_corruption_max_cast_004.png touches image edge (2 pixels)
- attribute_sets/intellect_max/IDLE: kataklysma_intellect_max_idle_001.png touches image edge (10 pixels)
- attribute_sets/intellect_max/IDLE: kataklysma_intellect_max_idle_002.png touches image edge (63 pixels)
- attribute_sets/intellect_max/IDLE: kataklysma_intellect_max_idle_003.png touches image edge (19 pixels)
- attribute_sets/intellect_max/IDLE: kataklysma_intellect_max_idle_004.png touches image edge (37 pixels)
- attribute_sets/intellect_max/WALK: kataklysma_intellect_max_walk_001.png touches image edge (43 pixels)
- attribute_sets/intellect_max/WALK: kataklysma_intellect_max_walk_002.png touches image edge (44 pixels)
- attribute_sets/intellect_max/WALK: kataklysma_intellect_max_walk_003.png touches image edge (58 pixels)
- attribute_sets/intellect_max/WALK: kataklysma_intellect_max_walk_004.png touches image edge (52 pixels)
- attribute_sets/intellect_max/CAST: kataklysma_intellect_max_cast_001.png touches image edge (99 pixels)
- attribute_sets/intellect_max/CAST: kataklysma_intellect_max_cast_002.png touches image edge (102 pixels)
- attribute_sets/intellect_max/CAST: kataklysma_intellect_max_cast_003.png touches image edge (193 pixels)
- attribute_sets/intellect_max/CAST: kataklysma_intellect_max_cast_004.png touches image edge (88 pixels)
- attribute_sets/lust_max/IDLE: kataklysma_lust_max_idle_001.png touches image edge (75 pixels)
- attribute_sets/lust_max/IDLE: kataklysma_lust_max_idle_002.png touches image edge (103 pixels)
- attribute_sets/lust_max/IDLE: kataklysma_lust_max_idle_003.png touches image edge (97 pixels)
- attribute_sets/lust_max/IDLE: kataklysma_lust_max_idle_004.png touches image edge (97 pixels)
- attribute_sets/lust_max/WALK: kataklysma_lust_max_walk_001.png touches image edge (32 pixels)
- attribute_sets/lust_max/WALK: kataklysma_lust_max_walk_002.png touches image edge (49 pixels)
- attribute_sets/lust_max/WALK: kataklysma_lust_max_walk_003.png touches image edge (52 pixels)
- attribute_sets/lust_max/WALK: kataklysma_lust_max_walk_004.png touches image edge (46 pixels)
- attribute_sets/lust_max/CAST: kataklysma_lust_max_cast_001.png touches image edge (76 pixels)
- attribute_sets/lust_max/CAST: kataklysma_lust_max_cast_002.png touches image edge (96 pixels)
- attribute_sets/lust_max/CAST: kataklysma_lust_max_cast_003.png touches image edge (123 pixels)
- attribute_sets/lust_max/CAST: kataklysma_lust_max_cast_004.png touches image edge (45 pixels)
- attribute_sets/lust_max/COMBAT: kataklysma_lust_max_combat_002.png touches image edge (8 pixels)
- attribute_sets/spirit_max/IDLE: kataklysma_spirit_max_idle_001.png touches image edge (23 pixels)
- attribute_sets/spirit_max/IDLE: kataklysma_spirit_max_idle_002.png touches image edge (21 pixels)
- attribute_sets/spirit_max/IDLE: kataklysma_spirit_max_idle_003.png touches image edge (32 pixels)
- attribute_sets/spirit_max/IDLE: kataklysma_spirit_max_idle_004.png touches image edge (18 pixels)
- attribute_sets/spirit_max/WALK: kataklysma_spirit_max_walk_001.png touches image edge (64 pixels)
- attribute_sets/spirit_max/WALK: kataklysma_spirit_max_walk_002.png touches image edge (69 pixels)
- attribute_sets/spirit_max/WALK: kataklysma_spirit_max_walk_003.png touches image edge (218 pixels)
- attribute_sets/spirit_max/WALK: kataklysma_spirit_max_walk_004.png touches image edge (68 pixels)
- attribute_sets/spirit_max/CAST: kataklysma_spirit_max_cast_001.png touches image edge (16 pixels)
- attribute_sets/spirit_max/CAST: kataklysma_spirit_max_cast_002.png touches image edge (83 pixels)
- attribute_sets/spirit_max/CAST: kataklysma_spirit_max_cast_003.png touches image edge (248 pixels)
- attribute_sets/spirit_max/CAST: kataklysma_spirit_max_cast_004.png touches image edge (98 pixels)
- attribute_sets/spirit_max/COMBAT: kataklysma_spirit_max_combat_003.png touches image edge (16 pixels)
- attribute_sets/stamina_max/IDLE: kataklysma_stamina_max_idle_001.png touches image edge (99 pixels)
- attribute_sets/stamina_max/IDLE: kataklysma_stamina_max_idle_002.png touches image edge (98 pixels)
- attribute_sets/stamina_max/IDLE: kataklysma_stamina_max_idle_003.png touches image edge (102 pixels)
- attribute_sets/stamina_max/IDLE: kataklysma_stamina_max_idle_004.png touches image edge (100 pixels)
- attribute_sets/stamina_max/WALK: kataklysma_stamina_max_walk_001.png touches image edge (45 pixels)
- attribute_sets/stamina_max/WALK: kataklysma_stamina_max_walk_002.png touches image edge (31 pixels)
- attribute_sets/stamina_max/WALK: kataklysma_stamina_max_walk_003.png touches image edge (34 pixels)
- attribute_sets/stamina_max/WALK: kataklysma_stamina_max_walk_004.png touches image edge (45 pixels)
- attribute_sets/stamina_max/CAST: kataklysma_stamina_max_cast_003.png touches image edge (39 pixels)
- attribute_sets/stamina_max/CAST: kataklysma_stamina_max_cast_004.png touches image edge (11 pixels)
- npcs/azkarra/IDLE: npc_azkarra_idle_001.png touches image edge (116 pixels)
- npcs/azkarra/IDLE: npc_azkarra_idle_002.png touches image edge (116 pixels)
- npcs/azkarra/IDLE: npc_azkarra_idle_003.png touches image edge (107 pixels)
- npcs/azkarra/IDLE: npc_azkarra_idle_004.png touches image edge (89 pixels)
- npcs/azkarra/WALK: npc_azkarra_walk_001.png touches image edge (40 pixels)
- npcs/azkarra/WALK: npc_azkarra_walk_002.png touches image edge (15 pixels)
- npcs/azkarra/WALK: npc_azkarra_walk_003.png touches image edge (42 pixels)
- npcs/azkarra/WALK: npc_azkarra_walk_004.png touches image edge (20 pixels)
- azkarra: missing planned animation folder CAST
- azkarra: missing planned animation folder COMBAT
- npcs/grikzan/IDLE: npc_grikzan_idle_001.png touches image edge (82 pixels)
- npcs/grikzan/IDLE: npc_grikzan_idle_002.png touches image edge (101 pixels)
- npcs/grikzan/IDLE: npc_grikzan_idle_003.png touches image edge (66 pixels)
- npcs/grikzan/IDLE: npc_grikzan_idle_004.png touches image edge (47 pixels)
- npcs/grikzan/WALK: npc_grikzan_walk_001.png touches image edge (1 pixels)
- npcs/grikzan/WALK: npc_grikzan_walk_002.png touches image edge (5 pixels)
- npcs/grikzan/WALK: npc_grikzan_walk_003.png touches image edge (12 pixels)
- npcs/grikzan/WALK: npc_grikzan_walk_004.png touches image edge (3 pixels)
- grikzan: missing planned animation folder CAST
- grikzan: missing planned animation folder COMBAT
- npcs/korgash/IDLE: npc_korgash_idle_001.png touches image edge (86 pixels)
- npcs/korgash/IDLE: npc_korgash_idle_002.png touches image edge (92 pixels)
- npcs/korgash/IDLE: npc_korgash_idle_003.png touches image edge (83 pixels)
- npcs/korgash/IDLE: npc_korgash_idle_004.png touches image edge (48 pixels)
- npcs/korgash/WALK: npc_korgash_walk_001.png touches image edge (1 pixels)
- npcs/korgash/WALK: npc_korgash_walk_002.png touches image edge (23 pixels)
- npcs/korgash/WALK: npc_korgash_walk_003.png touches image edge (3 pixels)
- npcs/korgash/WALK: npc_korgash_walk_004.png touches image edge (4 pixels)
- korgash: missing planned animation folder CAST
- korgash: missing planned animation folder COMBAT
- npcs/makjala/IDLE: npc_makjala_idle_001.png touches image edge (6 pixels)
- npcs/makjala/IDLE: npc_makjala_idle_002.png touches image edge (1 pixels)
- npcs/makjala/IDLE: npc_makjala_idle_004.png touches image edge (19 pixels)
- npcs/makjala/WALK: npc_makjala_walk_001.png touches image edge (11 pixels)
- npcs/makjala/WALK: npc_makjala_walk_002.png touches image edge (15 pixels)
- npcs/makjala/WALK: npc_makjala_walk_003.png touches image edge (12 pixels)
- npcs/makjala/WALK: npc_makjala_walk_004.png touches image edge (13 pixels)
- makjala: missing planned animation folder CAST
- makjala: missing planned animation folder COMBAT
- npcs/mokjala/IDLE: npc_mokjala_idle_001.png touches image edge (113 pixels)
- npcs/mokjala/IDLE: npc_mokjala_idle_002.png touches image edge (111 pixels)
- npcs/mokjala/IDLE: npc_mokjala_idle_003.png touches image edge (93 pixels)
- npcs/mokjala/IDLE: npc_mokjala_idle_004.png touches image edge (68 pixels)
- npcs/mokjala/WALK: npc_mokjala_walk_001.png touches image edge (5 pixels)
- npcs/mokjala/WALK: npc_mokjala_walk_002.png touches image edge (2 pixels)
- npcs/mokjala/WALK: npc_mokjala_walk_003.png touches image edge (7 pixels)
- npcs/mokjala/WALK: npc_mokjala_walk_004.png touches image edge (1 pixels)
- mokjala: missing planned animation folder CAST
- mokjala: missing planned animation folder COMBAT
- npcs/rakjin/IDLE: npc_rakjin_idle_001.png touches image edge (12 pixels)
- npcs/rakjin/IDLE: npc_rakjin_idle_002.png touches image edge (23 pixels)
- npcs/rakjin/IDLE: npc_rakjin_idle_003.png touches image edge (26 pixels)
- npcs/rakjin/IDLE: npc_rakjin_idle_004.png touches image edge (21 pixels)
- npcs/rakjin/WALK: npc_rakjin_walk_001.png touches image edge (7 pixels)
- npcs/rakjin/WALK: npc_rakjin_walk_002.png touches image edge (5 pixels)
- npcs/rakjin/WALK: npc_rakjin_walk_003.png touches image edge (10 pixels)
- npcs/rakjin/WALK: npc_rakjin_walk_004.png touches image edge (10 pixels)
- rakjin: missing planned animation folder CAST
- rakjin: missing planned animation folder COMBAT
- npcs/razzik_coilthumb/IDLE: npc_razzik_coilthumb_idle_001.png touches image edge (108 pixels)
- npcs/razzik_coilthumb/IDLE: npc_razzik_coilthumb_idle_002.png touches image edge (110 pixels)
- npcs/razzik_coilthumb/IDLE: npc_razzik_coilthumb_idle_003.png touches image edge (69 pixels)
- npcs/razzik_coilthumb/IDLE: npc_razzik_coilthumb_idle_004.png touches image edge (74 pixels)
- npcs/razzik_coilthumb/WALK: npc_razzik_coilthumb_walk_001.png touches image edge (21 pixels)
- npcs/razzik_coilthumb/WALK: npc_razzik_coilthumb_walk_002.png touches image edge (20 pixels)
- npcs/razzik_coilthumb/WALK: npc_razzik_coilthumb_walk_003.png touches image edge (8 pixels)
- npcs/razzik_coilthumb/WALK: npc_razzik_coilthumb_walk_004.png touches image edge (18 pixels)
- razzik_coilthumb: missing planned animation folder CAST
- razzik_coilthumb: missing planned animation folder COMBAT
- npcs/rukka/IDLE: npc_rukka_idle_001.png touches image edge (118 pixels)
- npcs/rukka/IDLE: npc_rukka_idle_002.png touches image edge (100 pixels)
- npcs/rukka/IDLE: npc_rukka_idle_003.png touches image edge (96 pixels)
- npcs/rukka/IDLE: npc_rukka_idle_004.png touches image edge (72 pixels)
- npcs/rukka/WALK: npc_rukka_walk_001.png touches image edge (25 pixels)
- npcs/rukka/WALK: npc_rukka_walk_002.png touches image edge (14 pixels)
- npcs/rukka/WALK: npc_rukka_walk_003.png touches image edge (9 pixels)
- npcs/rukka/WALK: npc_rukka_walk_004.png touches image edge (16 pixels)
- rukka: missing planned animation folder CAST
- rukka: missing planned animation folder COMBAT
- npcs/sister_aruka/IDLE: npc_sister_aruka_idle_001.png touches image edge (115 pixels)
- npcs/sister_aruka/IDLE: npc_sister_aruka_idle_002.png touches image edge (112 pixels)
- npcs/sister_aruka/IDLE: npc_sister_aruka_idle_003.png touches image edge (99 pixels)
- npcs/sister_aruka/IDLE: npc_sister_aruka_idle_004.png touches image edge (62 pixels)
- npcs/sister_aruka/WALK: npc_sister_aruka_walk_001.png touches image edge (6 pixels)
- npcs/sister_aruka/WALK: npc_sister_aruka_walk_002.png touches image edge (16 pixels)
- npcs/sister_aruka/WALK: npc_sister_aruka_walk_003.png touches image edge (2 pixels)
- npcs/sister_aruka/WALK: npc_sister_aruka_walk_004.png touches image edge (2 pixels)
- sister_aruka: missing planned animation folder CAST
- sister_aruka: missing planned animation folder COMBAT
- npcs/tazrima/IDLE: npc_tazrima_idle_001.png touches image edge (65 pixels)
- npcs/tazrima/IDLE: npc_tazrima_idle_002.png touches image edge (69 pixels)
- npcs/tazrima/IDLE: npc_tazrima_idle_003.png touches image edge (66 pixels)
- npcs/tazrima/IDLE: npc_tazrima_idle_004.png touches image edge (60 pixels)
- npcs/tazrima/WALK: npc_tazrima_walk_001.png touches image edge (34 pixels)
- npcs/tazrima/WALK: npc_tazrima_walk_002.png touches image edge (2 pixels)
- npcs/tazrima/WALK: npc_tazrima_walk_003.png touches image edge (28 pixels)
- npcs/tazrima/WALK: npc_tazrima_walk_004.png touches image edge (4 pixels)
- tazrima: missing planned animation folder CAST
- tazrima: missing planned animation folder COMBAT
- npcs/vexa_geargrin/IDLE: npc_vexa_geargrin_idle_001.png touches image edge (102 pixels)
- npcs/vexa_geargrin/IDLE: npc_vexa_geargrin_idle_002.png touches image edge (126 pixels)
- npcs/vexa_geargrin/IDLE: npc_vexa_geargrin_idle_003.png touches image edge (103 pixels)
- npcs/vexa_geargrin/IDLE: npc_vexa_geargrin_idle_004.png touches image edge (76 pixels)
- npcs/vexa_geargrin/WALK: npc_vexa_geargrin_walk_001.png touches image edge (3 pixels)
- npcs/vexa_geargrin/WALK: npc_vexa_geargrin_walk_002.png touches image edge (8 pixels)
- npcs/vexa_geargrin/WALK: npc_vexa_geargrin_walk_003.png touches image edge (1 pixels)
- npcs/vexa_geargrin/WALK: npc_vexa_geargrin_walk_004.png touches image edge (2 pixels)
- vexa_geargrin: missing planned animation folder CAST
- vexa_geargrin: missing planned animation folder COMBAT
- npcs/zalkiri/IDLE: npc_zalkiri_idle_001.png touches image edge (21 pixels)
- npcs/zalkiri/IDLE: npc_zalkiri_idle_002.png touches image edge (17 pixels)
- npcs/zalkiri/IDLE: npc_zalkiri_idle_003.png touches image edge (23 pixels)
- npcs/zalkiri/IDLE: npc_zalkiri_idle_004.png touches image edge (19 pixels)
- npcs/zalkiri/WALK: npc_zalkiri_walk_001.png touches image edge (6 pixels)
- npcs/zalkiri/WALK: npc_zalkiri_walk_003.png touches image edge (3 pixels)
- npcs/zalkiri/WALK: npc_zalkiri_walk_004.png touches image edge (5 pixels)
- zalkiri: missing planned animation folder CAST
- zalkiri: missing planned animation folder COMBAT
- npcs/zekranu/IDLE: npc_zekranu_idle_001.png touches image edge (1 pixels)
- npcs/zekranu/IDLE: npc_zekranu_idle_002.png touches image edge (2 pixels)
- npcs/zekranu/IDLE: npc_zekranu_idle_004.png touches image edge (9 pixels)
- npcs/zekranu/WALK: npc_zekranu_walk_001.png touches image edge (27 pixels)
- npcs/zekranu/WALK: npc_zekranu_walk_002.png touches image edge (34 pixels)
- npcs/zekranu/WALK: npc_zekranu_walk_003.png touches image edge (27 pixels)
- npcs/zekranu/WALK: npc_zekranu_walk_004.png touches image edge (34 pixels)
- zekranu: missing planned animation folder CAST
- zekranu: missing planned animation folder COMBAT
- entities/corrupted_makrura/COMBAT: entity_corrupted_makrura_combat_001.png touches image edge (3 pixels)
- entities/corrupted_makrura/COMBAT: entity_corrupted_makrura_combat_002.png touches image edge (12 pixels)
- entities/corrupted_makrura/COMBAT: entity_corrupted_makrura_combat_003.png touches image edge (14 pixels)
- entities/corrupted_makrura/COMBAT: entity_corrupted_makrura_combat_004.png touches image edge (15 pixels)
- entities/corrupted_makrura/IDLE: entity_corrupted_makrura_idle_001.png touches image edge (9 pixels)
- entities/corrupted_makrura/IDLE: entity_corrupted_makrura_idle_002.png touches image edge (9 pixels)
- entities/corrupted_makrura/IDLE: entity_corrupted_makrura_idle_003.png touches image edge (16 pixels)
- entities/corrupted_makrura/IDLE: entity_corrupted_makrura_idle_004.png touches image edge (7 pixels)
- entities/eye_of_storm_avatar/CAST: entity_eye_of_storm_avatar_cast_001.png touches image edge (7 pixels)
- entities/eye_of_storm_avatar/CAST: entity_eye_of_storm_avatar_cast_002.png touches image edge (5 pixels)
- entities/eye_of_storm_avatar/CAST: entity_eye_of_storm_avatar_cast_003.png touches image edge (3 pixels)
- entities/eye_of_storm_avatar/CAST: entity_eye_of_storm_avatar_cast_004.png touches image edge (20 pixels)
- entities/eye_of_storm_avatar/IDLE: entity_eye_of_storm_avatar_idle_001.png touches image edge (1 pixels)
- entities/eye_of_storm_avatar/IDLE: entity_eye_of_storm_avatar_idle_002.png touches image edge (3 pixels)
- entities/eye_of_storm_avatar/IDLE: entity_eye_of_storm_avatar_idle_003.png touches image edge (12 pixels)
- entities/eye_of_storm_avatar/IDLE: entity_eye_of_storm_avatar_idle_004.png touches image edge (1 pixels)
- entities/weakened_water_spirit/IDLE: entity_weakened_water_spirit_idle_001.png touches image edge (39 pixels)
- entities/weakened_water_spirit/IDLE: entity_weakened_water_spirit_idle_002.png touches image edge (42 pixels)
- entities/weakened_water_spirit/IDLE: entity_weakened_water_spirit_idle_003.png touches image edge (48 pixels)
- entities/weakened_water_spirit/IDLE: entity_weakened_water_spirit_idle_004.png touches image edge (37 pixels)
- entities/weakened_water_spirit/WALK: entity_weakened_water_spirit_walk_001.png touches image edge (1 pixels)
- entities/weakened_water_spirit/WALK: entity_weakened_water_spirit_walk_002.png touches image edge (6 pixels)
- entities/weakened_water_spirit/WALK: entity_weakened_water_spirit_walk_003.png touches image edge (3 pixels)
- entities/weakened_water_spirit/WALK: entity_weakened_water_spirit_walk_004.png touches image edge (16 pixels)

## Pós-correção

Os 24 grupos inicialmente reprovados foram recentralizados pelo pivô da faixa
inferior da silhueta e pela linha de base mediana. As sheets correspondentes
foram reconstruídas no Godot. Nova execução: **60/60 grupos aprovados, 0 falhas**.

Os PNGs anteriores foram preservados em
`90_SOURCE_ARCHIVE/legacy/pixel_prelock_v001/`. Permanecem 220 avisos de
contato com a borda, que exigem revisão artística caso representem recorte
visível no jogo. Os 13 NPCs ainda não possuem `CAST/COMBAT`; isso continua
registrado como lacuna de cobertura, não como falha de pivô.
