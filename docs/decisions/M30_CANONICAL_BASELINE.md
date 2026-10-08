# Linha de base canônica do M30

**Estado:** baseline v1 registrada — corte escolhido pelo usuário e critérios narrativos por quest documentados; estimativa preliminar, vínculo dos recursos e calibração de esforço ainda pendentes.

**Referência narrativa:** `00_DOCS/source_lore/Lust_Shamans_Journey_Complete_Game_Narrative_Bible_V2.0.docx`.

Este documento registra decisões de produção para que dados, código e arte usem a mesma estrutura. Ele não declara que conteúdo catalogado esteja integrado nem altera a Bíblia narrativa original.

## Cânone de campanha

A Bíblia define 15 quests principais distribuídas por sete regiões de campanha. O Eye of the Storm Shrine é tratado aqui como local especial de sequência final, não como uma oitava região de exploração. A imagem-conceito do santuário permanece preservada.

| Região | Quests principais | Observação de produção |
|---|---|---|
| Echo Isles | `QST_ECHO_001`–`QST_ECHO_008` | Tutorial, caça, primeiro espírito e Makrura; encerramento com a partida para Sen'jin |
| Sen'jin Village | `QST_SEN_009` | Missing Supplies; primeiro hub social |
| Durotar | `QST_DUR_010`, `QST_END_015` | Travessia e clímax da campanha |
| Razor Hill | `QST_RAZ_011` | Desafio de Kor'gash |
| Orgrimmar | `QST_ORG_012` | Dívida, favores e distritos selecionados; background ainda ausente |
| Ratchet | `QST_RAT_013` | Thunder for Sale |
| Northern Barrens | `QST_BAR_014` | Localização e ativação inicial do Eye |

O local especial `eye_of_storm_shrine` se relaciona a `QST_BAR_014` e `QST_END_015`, mas não conta como uma região de viagem adicional. A sequência dos dados está em `03_GODOT/data/zones.json` v002.

## Decisões de produção

| Tema | Decisão de linha de base | Evidência / consequência |
|---|---|---|
| Combate | Manter combate por turnos | Direção já definida pelo usuário. A descrição de combate em tempo real na Bíblia é uma divergência documental a reconciliar; não substituir silenciosamente o sistema vigente. |
| Quest atual | Tratar “Purificar a Maré Corrompida” como protótipo não canônico, sem ID de quest principal | O diálogo JSON e a lógica runtime não implementam por completo nenhum dos 15 cartões. O protótipo pode fornecer mecânicas/referências, mas não conta como uma quest canônica concluída. |
| CG atual | Tratar Echo 002 como asset candidato à cena do totem/ritual de `QST_ECHO_002` | O runtime dispara essa sequência após o objetivo da quest protótipo de maré; corrigir o vínculo ao implementar a quest canônica. |
| Inventário de CG | `cg_variants.json` é o catálogo de produção; `CG_VARIANT_ROSTER.md` distingue asset aprovado de cena integrada | Há 12 sequências e 48 PNGs v002. Só uma sequência está referenciada no script da demo; QA de assets não equivale a QA de gameplay. |
| Escopo de regiões | Sete regiões conforme a Bíblia; Orgrimmar incluída; santuário como local especial | Orgrimmar precisa de arte e cena. Todos os backgrounds existentes continuam classificados como conceito até receberem mapa jogável e QA. |
| Direções dos sprites | Kataklysma tem frente, costas, esquerda e direita; não há animações diagonais dedicadas | O controller seleciona a direção cardinal dominante em movimento diagonal. Não reutilizar isso como alegação de sprite diagonal. |

## Quest prototype e migração

`03_GODOT/data/dialogue/pt_BR/quest_01.json` está marcado como protótipo e não é consumido pelo runtime. A quest ativa está também codificada diretamente em `03_GODOT/scripts/demo_game.gd`. Não atribuir o protótipo a `QST_ECHO_005` nem a outro ID sem comparar objetivos, cenas, escolhas, flags e CG com o cartão canônico correspondente.

Na Fase 2, decompor o protótipo em elementos reaproveitáveis e reimplementar o arco usando IDs canônicos. A sequência `echo_002_zekranu_totem_choice` deve tocar somente no evento narrativo correspondente. Saves de teste do protótipo não são saves compatíveis garantidos com a campanha canônica.

## Escopo M30 e medição

O usuário escolheu uma campanha do início até `QST_SEN_009`: `QST_ECHO_001`–`QST_ECHO_008`, transição persistente e `QST_SEN_009`. O corte cobre nove dos quinze IDs de quest; essa razão não é usada como medida de esforço.

`docs/production/M30_WORK_BREAKDOWN.md` registra uma estimativa preliminar de 35 pontos M30 em 100 pontos para o jogo completo (faixa aproximada de 30%–40%; confiança baixa a média). É um plano de esforço, não progresso já realizado, nem uma baseline de custo validada. Revisar depois de estabilizar a fundação Godot e estimar uma quest e um mapa com dados reais. Só contar itens integrados, aceitos e com QA; não ajustar pesos retroativamente para preservar um rótulo percentual.

A matriz `docs/production/M30_QUEST_ACCEPTANCE.md` registra objetivos, dependências de spine, cenas, escolhas, flags, consequências e critérios de aceite das nove quests. A associação dos arquivos de arte/CGs ainda requer inventário, e a Fase 0 continua aberta até essa associação e a revisão dos pesos com evidência da Fase 1.

## Estados de produção

Usar estes estados em catálogos e relatórios:

- `produced`: arquivo de arte ou conteúdo foi criado.
- `integrated`: o runtime consome o conteúdo no fluxo previsto.
- `qa_pending`: integrado, mas ainda sem verificação na build corrente.
- `approved`: passou critérios de aceitação e QA registrados para o commit indicado.
- `prototype`: experimento ou conteúdo temporário sem aprovação canônica.

Um asset `produced` não conta como funcionalidade concluída. Resultados de QA históricos permanecem associados à versão que foi testada e não são herdados automaticamente por mudanças posteriores.
