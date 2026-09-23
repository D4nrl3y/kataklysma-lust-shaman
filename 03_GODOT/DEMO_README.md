# Kataklysma — primeira demo jogável

Esta é a primeira vertical slice executável do projeto. Ela usa a zona **Echo Isles** como mapa inicial e valida o fluxo principal de exploração antes da implementação completa do combate por turnos.

## Fluxo coberto

1. Explorar Echo Isles com a Kataklysma.
2. Encontrar Zekranu com marcador `!` de quest disponível.
3. Aceitar `Purificar a Maré Corrompida`.
4. Ir até a `Maré Corrompida` marcada no mapa.
5. Purificar o objetivo e retornar ao Zekranu.
6. Entregar a quest com marcador `✓`.
7. Caminhar para acionar um encontro aleatório ou usar `F` para testar a batalha imediatamente.

## Fluxo de interface

O projeto inicia no menu principal com arte de abertura. `Novo Jogo` inicia a exploração; `Continuar` carrega o save local. Durante a exploração, o tracker, o minimapa e os prompts aparecem contextualmente.

## Controles

- `WASD` ou setas: mover
- `E`, `Espaço` ou `Enter`: interagir / confirmar
- `F`: abrir encontro de teste
- `R`: reiniciar a demo
- Combate: `1` ataque físico, `2` canalizar espírito, `3` guarda, `4` purificar, `5` fugir; depois `E` para continuar
- `Esc`: pause menu
- Pause menu: `1` atributos, `2` quests, `3` mapa, `4` opções, `S` salvar, `M` menu principal

## Execução

Abra a raiz `Kataklysma_Dev_Kit` no Godot 4.7 e pressione Play. A cena principal já aponta para `03_GODOT/scenes/main.tscn`.

## Combate implementado

O combate possui turnos de jogador e inimigo, HP, espírito, defesa física e espiritual, guarda, ataques críticos, custo de recursos, purificação, corrupção com dano periódico, fuga com chance, IA inimiga, vitória, derrota e retorno à exploração. As regras estão isoladas em `03_GODOT/scripts/combat_system.gd` para futura reutilização em uma cena de batalha dedicada.

O mapa agora usa câmera `Camera2D` com suavização e limites, escala de mundo reduzida, colisões físicas de limites/obstáculos, corpo de colisão nos pés da personagem, Y-sort de entidades, prompts contextuais, minimapa e tracker de quest compacto. A primeira conversa com Zek'Ranu possui cinco respostas; cada resposta altera atributos, afinidade ou flags e produz uma consequência textual distinta.

A conclusão da investigação executa uma sequência CG de quatro variações e apresenta a conclusão da quest. O save local preserva posição, atributos, quest, afinidade, flags e POIs descobertos.

O próximo marco é expandir o conteúdo: múltiplos inimigos por formação, habilidades específicas por atributo, animações de ação completas, inventário/equipamento e balanceamento baseado nos dados finais do jogo.
