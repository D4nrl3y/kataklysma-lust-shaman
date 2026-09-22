# Kataklysma — production status v001

## Já produzido

- 13 NPCs nomeados: render neutro e 8 frames jogáveis por personagem.
- 3 entidades prioritárias: render neutro e 8 frames por entidade.
- 12 CGs base de cenas, preservadas como `legacy_keyframes`.
- 1 sequência CG aprovada em produção com 4 imagens distintas: Echo 002 / Zekranu.
- Manifesto de continuidade visual para Kataklysma, NPCs e entidades.
- Auditoria executável para impedir que uma CG seja considerada completa sem os 4 arquivos.
- 7 backgrounds de zonas: Echo Isles, Sen'jin Village, Durotar Coast, Razor Hill, Ratchet, Northern Barrens e Eye of the Storm Shrine.
- Catálogo de zonas, encontros aleatórios, estados de quest e pontos de interação.
- Marcadores visuais de quest disponível, em progresso e pronta para entrega.
- Scripts Godot para markers, mapas, biblioteca de sprites e encontros aleatórios.

## Próximos lotes de arte

- 44 variações restantes das 12 CGs (11 cenas × 4 quadros).
- Turnarounds, expressões e locks de produção para os NPCs que hoje possuem apenas render neutro.
- Regeneração controlada de CGs, retratos e sprites que não passarem pelo lock de continuidade.
- NPCs genéricos reutilizáveis de vila, guarda, comerciante, caçador, goblin, orc e viajante.
- Monstros de campo para cada arquétipo de encontro.
- Biblioteca de static objects separada dos backgrounds.
- Camadas finais de TileMap/collision, foreground, rotas, spawn points e encounter regions.

## Decisão de escopo

O combate por turnos fica desacoplado dos assets nesta etapa. Os monstros já têm slots de `IDLE`, movimento e ação reservados, mas a lógica de batalha será implementada depois que mapas, quests, encontros e posicionamento estiverem estáveis.
