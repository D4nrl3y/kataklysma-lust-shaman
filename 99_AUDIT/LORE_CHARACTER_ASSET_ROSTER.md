# Roster de personagens para produção de arte

Fonte de verdade: `Doocumentes/Lust_Shamans_Journey_Complete_Game_Narrative_Bible_V2.0.docx`.

## Personagens nomeados

| Personagem | Função no lore | Região ou contexto |
|---|---|---|
| Zek’Ranu | Xamã veterano e primeiro mentor formal | Echo Isles e tutorial |
| Zal’Kiri | Caçadora e amiga de infância | Echo Isles |
| Rak’jin | Guerreiro jovem, competitivo e carismático | Echo Isles e Razor Hill |
| Seer Mak’jala | Anciã e médium das Echo Isles | Echo Isles, ancestrais e sonhos |
| Grik’Zan | Comerciante e intermediário de informação | Ratchet e Underworld |
| Vexa Geargrin | Engenheira goblin de artefatos elementais | Ratchet e laboratório |
| Kor’gash | Guerreiro orc e rival de arena | Razor Hill |
| Az’Karra | Xamã troll disciplinada e rival ideológica | Durotar e rituais |
| Taz’Rima | Alquimista e fonte de quests de coleta | Sen’jin |
| Mok’Jala | Caçador e instrutor de sobrevivência | Tutorial e Durotar |
| Ruk’ka | Jovem ladrão de suprimentos | Sen’jin |
| Razzik Coilthumb | Fence goblin e concorrente de Grik’Zan | Ratchet |
| Sister Aruka | Médium Darkspear itinerante | Durotar e Barrens |

## Entidades e antagonistas prioritários

- Pequeno espírito da água enfraquecido.
- Makrura corrompido, primeiro boss.
- Espíritos elementais e ancestrais.
- Avatar do Eye of the Storm, boss/ritual final.
- Arquétipos de inimigos: melee chaser, ranged harasser, controller, support, brute e spirit/elemental.

## Primeira versão de arte

Para cada personagem nomeado, a produção deve gerar um render neutro de referência, portrait e sprite jogável. Os sprites devem começar com `IDLE` e `WALK`; `CAST` e `COMBAT` entram quando o personagem tiver função ativa em combate.

CGs são assets de cena, não apenas retratos grandes. A primeira leva deve priorizar as cenas do tutorial, o espírito da água, o Makrura corrompido, o duelo com Kor’gash, o ritual do Eye e os finais principais.

Como o lore fornece função, personalidade e contexto, mas não uma ficha visual completa para todos, os arquivos iniciais devem usar sufixo `v001` e passar por revisão visual antes de serem tratados como cânone definitivo.

## Status desta rodada

- 13/13 personagens nomeados: renders neutros v001 gerados em `01_ASSETS/kataklysma/character/npcs/renders`.
- 13/13 personagens nomeados: sprites v001 gerados em `01_ASSETS/kataklysma/sprites/npcs`, com 4 frames de `IDLE`, 4 de `WALK` e uma sheet combinada por personagem.
- 3/3 entidades prioritárias: renders neutros v001 gerados em `01_ASSETS/kataklysma/character/entities/renders`.
- 3/3 entidades prioritárias: sprites v001 gerados em `01_ASSETS/kataklysma/character/entities/sprites`, com `IDLE` e uma segunda animação (`WALK`, `COMBAT` ou `CAST`).
- 8 CGs de cena v001 geradas em `01_ASSETS/kataklysma/cg/scenes`; índice em `99_AUDIT/CG_ASSET_ROSTER.md`.

## Pendências deliberadas

- Portraits específicos para os 13 NPCs ainda podem ser derivados dos renders após aprovação do design visual.
- Arquétipos genéricos de inimigos e a família completa de espíritos elementais/ancestrais ainda não receberam arte individual.
- As imagens são uma primeira direção visual; validar proporções, silhuetas, paleta e continuidade com a protagonista antes de canonizar.
