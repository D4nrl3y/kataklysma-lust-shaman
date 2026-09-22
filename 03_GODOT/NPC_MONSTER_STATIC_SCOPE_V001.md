# Roster de produção de personagens e objetos

## NPCs

Os 13 NPCs nomeados já possuem render e sprites v001. O próximo lote deve cobrir NPCs genéricos reutilizáveis:

- `village_shaman`, `elder`, `hunter`, `child`, `fisher`, `gatherer`
- `merchant`, `guard`, `scout`, `warrior`, `blacksmith`, `arena_spectator`
- `goblin_merchant`, `sailor`, `mechanic`, `smuggler`
- `orc_guard`, `nomad`, `pilgrim`

Cada tipo genérico precisa de pelo menos `IDLE`, `WALK` e, quando aplicável, `CAST` ou `COMBAT`.

## Monstros

Prioridade jogável: `water_spirit_weakened`, `makrura_corrupted`, `spirit_elemental`, `melee_chaser`, `ranged_harasser`, `controller`, `support`, `brute` e `eye_of_storm_avatar`.

Cada monstro precisa de render de referência, sprite de campo, `IDLE`, movimento e pelo menos uma ação de combate. O combate em turnos fica desacoplado dos assets nesta etapa.

## Static objects

Criar versões estáticas e, quando necessário, estados animados para: totems, campfires, chests, quest boards, supply crates, herb patches, ore nodes, alchemy stations, workbenches, boats, arena gates, weapon racks, ritual stones, storm anchors, ancestor gates, track markers, hidden caches e ruined totems.

Os objetos devem ser assets separados do background para permitir sinalização, colisão, interação e troca de estado.
