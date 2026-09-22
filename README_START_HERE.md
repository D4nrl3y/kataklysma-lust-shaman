# Kataklysma — Development Kit

Kit limpo para iniciar o desenvolvimento de **Lust Shaman’s Journey** com a personagem **Kataklysma**.

## Comece por aqui

- `01_ASSETS/kataklysma/sprites/`: sprites jogáveis corrigidos da versão **v3.2 SPRITEFIX**.
- `01_ASSETS/kataklysma/sprites/attribute_sets/`: seis conjuntos completos de sprites in-game, um para cada atributo no máximo. O guia está em `attribute_sets/README.md`.
- `01_ASSETS/kataklysma/character/`: modelos, vistas e detalhes anatômicos.
- `01_ASSETS/kataklysma/ui/portraits/`: portraits neutro, corrompido e cut-in mágico.
- `01_ASSETS/kataklysma/equipment/`: cajado da personagem.
- `01_ASSETS/kataklysma/promotional/`: concept art e key art.
- `03_GODOT/`: helper e instruções atualizadas para Godot 4.

## Integração rápida com Godot

Copie `01_ASSETS/` para a raiz do projeto Godot, preservando o caminho `res://01_ASSETS/kataklysma/`.
Depois, use `03_GODOT/kataklysma_sprite_library.gd` para montar as animações em um `AnimatedSprite2D`.

Configuração canônica dos sprites:

| Animação | FPS | Loop |
|---|---:|---|
| idle | 4 | sim |
| walk | 8 | sim |
| cast | 6 | não |
| combat | 10 | não |

Todos os frames têm canvas de **543×362 px** e pivô recomendado em **bottom-center**.

## Organização

```text
01_ASSETS/               material pronto para uso no jogo
02_REFERENCE/            cânone, turnaround, referências e pranchas
03_GODOT/                helper atualizado e instruções de importação
90_SOURCE_ARCHIVE/       fontes brutas e versões antigas
99_AUDIT/                catálogos, manifests e histórico da revisão
```

## Critério aplicado

Foram encontrados **242 arquivos**, correspondentes a **171 conteúdos distintos**. As **71 cópias exatas** não foram repetidas na área de desenvolvimento; cada uma está registrada em `DUPLICATES.csv` e aponta para o arquivo canônico escolhido.

A versão `v3.2 SPRITEFIX` foi priorizada para sprites de produção. A versão `v3.0` foi mantida em `90_SOURCE_ARCHIVE/legacy` quando continha uma versão diferente. As pastas originais no nível acima permanecem intactas.

Os nomes dos arquivos de uso direto foram normalizados: sem timestamps, sufixos de exportação ou nomes ambíguos. O mapa completo está em `99_AUDIT/RENAME_MAP.csv`.

## Regras canônicas importantes

- Kataklysma é uma troll adulta, alta, atlética e curvilínea.
- Pele azul/lilás fria; olhos âmbar; cabelo branco/platinado.
- Cada mão tem 3 dígitos no total: 1 polegar + 2 dedos.
- Cada pé tem exatamente 2 dedos.
- Cajado com foco de energia violeta.
- A corrupção visual segue as faixas 0–20, 21–40, 41–60, 61–80 e 81–100.
