# Visual Identity QA — V002

**Data:** 2026-09-22  
**Escopo:** lock visual dos personagens e revisão das CGs continuadas.

## Resultado

| Lote | Cobertura | Resultado |
|---|---:|---|
| CGs continuadas | 12 cenas / 48 quadros | **PASS** |
| NPCs | 13 renders neutros + 13 fichas de lock | **PASS** |
| Entidades | 3 renders neutros + 3 fichas de lock | **PASS** |
| Kataklysma | referência canônica existente | **PASS** |
| Bloqueadores de identidade | 0 encontrados | **PASS** |

## Verificações executadas

- rosto, cabelo, pele, silhueta e proporções comparados contra o render neutro canônico;
- acessórios, armas, adornos, marcações e equipamentos-assinatura preservados;
- vistas frontal, perfil e costas conferidas nas fichas de identity lock;
- continuidade macro das 48 imagens: personagem, paleta, acessórios, iluminação narrativa e progressão da cena;
- ausência de troca de identidade, duplicação de personagem ou quadro estruturalmente inutilizável;
- enquadramento útil para CG: personagem legível e área inferior preservada para interface/diálogo quando aplicável.

## Decisão de produção

Os 13 NPCs e as 3 entidades estão **production_locked_v002** no manifesto de continuidade. O pacote mínimo obrigatório passa a ser:

1. render neutro canônico;
2. ficha de identity lock com vistas e detalhes;
3. qualquer variação posterior deve ser comparada a esse pacote antes de entrar em CG, retrato, render ou sprite.

Variações de pose, expressão, iluminação, dano e corrupção são permitidas quando exigidas pela narrativa. Não podem alterar sem aprovação explícita o rosto, cabelo, pele, silhueta, paleta-base ou equipamento-assinatura.

## Observações

- As 12 sequências de CG foram aprovadas no nível de identidade e continuidade visual macro.
- As fichas de lock são referências visuais 2D de produção; ainda será necessário validar a tradução para sprites pixelados, pivôs, escala e colisão dentro do Godot.
- O manifesto atualizado em `02_REFERENCE/00_CONTINUITY/character_continuity_manifest.json` é a fonte operacional para novos lotes.

## Evidências

- NPC locks: `01_ASSETS/kataklysma/character/npcs/identity_locks/`
- Entity locks: `01_ASSETS/kataklysma/character/entities/identity_locks/`
- Manifesto: `02_REFERENCE/00_CONTINUITY/character_continuity_manifest.json`
- Validador: `99_AUDIT/validate_identity_locks.ps1`
