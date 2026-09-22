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

## Controles

- `WASD` ou setas: mover
- `E`, `Espaço` ou `Enter`: interagir / confirmar
- `F`: abrir encontro de teste
- `R`: reiniciar a demo
- Combate: `1` ataque físico, `2` canalizar espírito, `3` guarda, `4` purificar, `5` fugir; depois `E` para continuar

## Execução

Abra a raiz `Kataklysma_Dev_Kit` no Godot 4.7 e pressione Play. A cena principal já aponta para `03_GODOT/scenes/main.tscn`.

## Combate implementado

O combate possui turnos de jogador e inimigo, HP, espírito, defesa física e espiritual, guarda, ataques críticos, custo de recursos, purificação, corrupção com dano periódico, fuga com chance, IA inimiga, vitória, derrota e retorno à exploração. As regras estão isoladas em `03_GODOT/scripts/combat_system.gd` para futura reutilização em uma cena de batalha dedicada.

O próximo marco é expandir o conteúdo: múltiplos inimigos por formação, habilidades específicas por atributo, animações de ação completas, inventário/equipamento e balanceamento baseado nos dados finais do jogo.
