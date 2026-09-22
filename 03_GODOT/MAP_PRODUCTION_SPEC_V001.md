# Especificação de mapas — Kataklysma v001

Os mapas são cenas jogáveis compostas por camadas, não apenas imagens únicas. Cada zona deve conter:

1. `background/` — arte de fundo ou tileset base do bioma.
2. `collision/` — áreas bloqueadas, bordas e água profunda.
3. `decor_foreground/` — elementos que passam à frente do personagem.
4. `interaction_markers/` — pontos sinalizados para diálogo, coleta, quest, passagem ou ambiente.
5. `spawn_points/` — jogador, NPCs, monstros e eventos aleatórios.
6. `npc_placements/` — posições fixas e rotas de NPCs.
7. `encounter_regions/` — regiões onde encontros aleatórios podem rolar.

## Zonas da primeira versão

- `echo_isles` — tutorial, cabana, totem, praia, caverna ancestral e penhasco da tempestade.
- `senjin_village` — vila, alquimia, suprimentos, cais e quests de Taz'Rima/Ruk'ka.
- `durotar_coast` — praia vulcânica, rastros, coleta e monstros de campo.
- `razor_hill` — arena, acampamento, ferreiro e rivalidade com Kor'gash.
- `ratchet` — porto goblin, mercado, oficina, becos e contrabando.
- `barrens` — estrada, acampamento de Sister Aruka, ruínas e encontros noturnos.
- `eye_of_storm_shrine` — mapa final com ritual, âncoras elementais e escolhas de final.

O catálogo completo das zonas está em `03_GODOT/data/zones.json`.

## Convenção de marcadores

Cada ponto interativo deve possuir `interaction_id`, `interaction_type`, `quest_id` opcional e `world_position`. O ícone só aparece quando fizer sentido para o estado do jogo; não é decoração livre.

Tipos mínimos: `dialogue`, `quest`, `quest_turn_in`, `collect`, `inspect`, `craft`, `shop`, `travel`, `arena`, `ritual`, `random_encounter_spawn`.
