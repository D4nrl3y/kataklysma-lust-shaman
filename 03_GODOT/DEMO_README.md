# Kataklysma — primeira demo jogável

Esta é a primeira vertical slice executável do projeto. Ela usa a zona **Echo Isles** como mapa inicial e valida o fluxo principal de exploração antes da implementação completa do combate por turnos.

## Fluxo coberto

1. Explorar Echo Isles com a Kataklysma.
2. Encontrar Zekranu com marcador `!` de quest disponível.
3. Aceitar `Purificar a Maré Corrompida`.
4. Ir até a `Maré Corrompida` marcada no mapa.
5. Purificar o objetivo e retornar ao Zekranu.
6. Entregar a quest com marcador `✓`.
7. Caminhar para acionar um encontro aleatório ou usar `F` para testar a tela imediatamente.

## Controles

- `WASD` ou setas: mover
- `E`, `Espaço` ou `Enter`: interagir / confirmar
- `F`: abrir encontro de teste
- `R`: reiniciar a demo
- Encontro: `1` ataque físico, `2` canalizar espírito, `3` recuar; depois `E` para continuar

## Execução

Abra a raiz `Kataklysma_Dev_Kit` no Godot 4.7 e pressione Play. A cena principal já aponta para `03_GODOT/scenes/main.tscn`.

## O que é deliberadamente um placeholder

O encontro já possui entrada, escolha e resolução, mas ainda não é o sistema final de combate por turnos. A próxima etapa deve substituir essa interface por iniciativa, habilidades, dano, estados, sprites de ação e retorno ao mapa.
