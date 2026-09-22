# Kataklysma — Development Kit

Kit organizado para iniciar o desenvolvimento de **Lust Shaman’s Journey** com a personagem **Kataklysma**.

## O que usar primeiro

- `assets/kataklysma/sprites/`: sprites jogáveis corrigidos da versão **v3.2 SPRITEFIX**.
- `assets/kataklysma/character/`: modelos, vistas e detalhes anatômicos.
- `assets/kataklysma/ui/portraits/`: portraits neutro, corrompido e cut-in mágico.
- `assets/kataklysma/equipment/`: cajado da personagem.
- `assets/kataklysma/promotional/`: concept art e key art.
- `tools/godot/`: helper e instruções atualizadas para Godot 4.

## Integração rápida com Godot

Copie `assets/` para a raiz do projeto Godot, preservando o caminho `res://assets/kataklysma/`.
Depois, use `tools/godot/kataklysma_spriteframes_setup.gd` para montar as animações em um `AnimatedSprite2D`.

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
assets/kataklysma/       material pronto para uso no jogo
docs/                    cânone, manifests, referências e documentação de produção
tools/godot/             helper atualizado e helper legado
source/                  fontes únicas, artes brutas e versões antigas
CATALOG.csv              inventário de todos os 242 arquivos originais
DUPLICATES.csv           cópias exatas e seu arquivo canônico
REVIEW_SUMMARY.csv       resumo quantitativo da revisão
```

## Critério aplicado

Foram encontrados **242 arquivos**, correspondentes a **171 conteúdos distintos**. As **71 cópias exatas** não foram repetidas na área de desenvolvimento; cada uma está registrada em `DUPLICATES.csv` e aponta para o arquivo canônico escolhido.

A versão `v3.2 SPRITEFIX` foi priorizada para sprites de produção. A versão `v3.0` foi mantida em `source/legacy` quando continha uma versão diferente, e seus documentos/helper foram preservados para consulta. As pastas originais no nível acima permanecem intactas.

## Regras canônicas importantes

- Kataklysma é uma troll adulta, alta, atlética e curvilínea.
- Pele azul/lilás fria; olhos âmbar; cabelo branco/platinado.
- Cada mão tem 3 dígitos no total: 1 polegar + 2 dedos.
- Cada pé tem exatamente 2 dedos.
- Cajado com foco de energia violeta.
- A corrupção visual segue as faixas 0–20, 21–40, 41–60, 61–80 e 81–100.

