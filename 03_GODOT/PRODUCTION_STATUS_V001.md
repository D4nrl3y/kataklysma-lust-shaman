# Kataklysma — production status v001

## Já produzido

- 13 NPCs nomeados: render neutro e 8 frames jogáveis por personagem.
- 3 entidades prioritárias: render neutro e 8 frames por entidade.
- 12 CGs base de cenas, preservadas como `legacy_keyframes`.
- 12 sequências CG aprovadas em produção com 48 imagens distintas: Echo 002 até End 015.
- Manifesto de continuidade visual para Kataklysma, NPCs e entidades.
- QA visual concluído: 13 NPCs e 3 entidades com render neutro + ficha de identity lock; nenhum bloqueador de identidade encontrado.
- Auditoria executável para impedir que uma CG seja considerada completa sem os 4 arquivos.
- 7 backgrounds de zonas: Echo Isles, Sen'jin Village, Durotar Coast, Razor Hill, Ratchet, Northern Barrens e Eye of the Storm Shrine.
- Catálogo de zonas, encontros aleatórios, estados de quest e pontos de interação.
- Marcadores visuais de quest disponível, em progresso e pronta para entrega.
- Scripts Godot para markers, mapas, biblioteca de sprites e encontros aleatórios.

## Próximos lotes de arte

- O lote de 44 variações restantes foi concluído; as 12 cenas agora têm início, desenvolvimento, clímax e desfecho.
- Turnarounds técnicos, expressões e proporções de sprite derivados dos locks já aprovados.
- Regeneração controlada de CGs, retratos e sprites que não passarem pelo lock de continuidade.
- NPCs genéricos reutilizáveis de vila, guarda, comerciante, caçador, goblin, orc e viajante.
- Monstros de campo para cada arquétipo de encontro.
- Biblioteca de static objects separada dos backgrounds.
- Camadas finais de TileMap/collision, foreground, rotas, spawn points e encounter regions.

## Decisão de escopo

O combate por turnos fica desacoplado dos assets nesta etapa. Os monstros já têm slots de `IDLE`, movimento e ação reservados, mas a lógica de batalha será implementada depois que mapas, quests, encontros e posicionamento estiverem estáveis.
