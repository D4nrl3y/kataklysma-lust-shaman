# Cobertura de assets da campanha M30

**Escopo original:** Fase 2 — Echo Isles `QST_ECHO_001`–`QST_ECHO_008`. **Atualização de execução:** Fase 3 Sen’jin / `QST_SEN_009`, em 2026-10-08.

**Revisão:** integração e QA de assets em 2026-10-08.

**Status:** os recursos necessários às interações da Fase 2 estão ligados ao runtime e cobertos por QA. Arquivos marcados `CANDIDATE` seguem sem aprovação de arte final; presença, integração e aprovação continuam sendo estados diferentes.

## Legenda e conclusão

- **Integrado:** o runtime atual carrega o recurso no beat indicado e existe evidência de QA.
- **Integrado — candidato:** funciona no fluxo, mas a arte está explicitamente marcada para inspeção/aprovação posterior.
- **Falta:** recurso ainda não foi implementado para a fase correspondente.
- Arquivos `.import` do Godot são metadados de importação, não quadros de arte adicionais.

Echo Isles e Sen’jin estão ligados ao fluxo jogável local. Echo Isles usa um atlas candidato de 20 props para 37 âncoras. Sen’jin usa o background conceitual achatado, 10 regiões caminháveis, 26 blockers e cinco âncoras da Q009; o mapa/quest e o retorno por save/load estão automatizados e capturados. A aprovação visual completa, playtest externo e export/instalação limpa continuam pendentes.

## Mapas e camadas

| Zona | Recurso existente | Runtime | Faltas para M30 |
|---|---|---|---|
| Echo Isles | `01_ASSETS/kataklysma/maps/echo_isles/backgrounds/echo_isles_background_concept_v001.png` e interior de cabana candidato | Background, interior, whitelist/blockers, rotas, POIs e interações de campanha ligados; Phase 1 e âncoras de Phase 2 validadas | Camadas de mapa mais modulares e aprovação final dos assets candidatos continuam como polimento futuro |
| Sen’jin Village | `01_ASSETS/kataklysma/maps/senjin_village/backgrounds/senjin_village_background_concept_v001.png`; `01_ASSETS/kataklysma/maps/senjin_village/foregrounds/senjin_foreground_vegetation_candidate_v001.png` | Background carregado pela zona runtime; 10 regiões, 26 blockers físicos, chegada no cais, cinco POIs, Taz’Rima/Ruk’ka, Q009 e eventos por região | Background modular e arte aprovada; travessia visual humana de todas as bordas/rotas; playtest e clean export (Fase 3, KI-011/KI-013) |

Os outros backgrounds conceituais encontrados são Durotar, Razor Hill, Northern Barrens, Ratchet e o local especial Eye of the Storm Shrine. Orgrimmar não tem background. Esses locais estão fora do corte M30.

## Personagens e retratos

Os atores necessários à Fase 2 estão posicionados e usados nas cenas/interações: Zek’Ranu, Mok’Jala, Zal’Kiri, Mak’Jala, Rak’jin, Taz’Rima, espírito da água, aprendiz e crianças. Os NPCs nomeados usam seus conjuntos `IDLE`/`WALK`; aprendiz e crianças usam sprites identificados como `CANDIDATE`. A cobertura de atores, pontos, textos e props é validada por `campaign_content_integrity_test.gd`.

Retratos busto dedicados: Kataklysma e Zek’Ranu. Os demais falantes da Fase 2 exibem temporariamente crops dos sprites de gameplay no quadro de diálogo; esses crops são funcionais e foram capturados, mas não são portraits finais. O aprendiz e as crianças têm sprites candidatos dedicados. Para `QST_ECHO_008`, Mak’Jala + Rak’jin são os NPCs de despedida fixados pelo usuário e ambos aparecem no fluxo final.

## Entidades e combate

| Entidade | Arquivos encontrados | Adequação ao corte |
|---|---|---|
| `weakened_water_spirit` | render, identity lock, quatro `IDLE` e quatro `WALK` | Candidato para `QST_ECHO_005`; sem animação `COMBAT` |
| `corrupted_makrura` | render, identity lock, quatro `IDLE` e quatro `COMBAT` | Candidato direto ao boss de `QST_ECHO_006`; sem animação `WALK` |
| `eye_of_storm_avatar` | quatro `IDLE` e quatro `CAST` | Fora do corte M30; sem integração de campanha |
| Javali/boar de caça | Candidato estático v002 em `01_ASSETS/kataklysma/character/entities/sprites/wild_boar/CANDIDATE/entity_wild_boar_candidate_v002.png`; integrado ao encontro de caça de Q003 | Captura `18_q003_hunt_battle.png` revisada. É uma pose/quadros únicos; animação e aprovação de arte final continuam abertas (KI-012) |
| Inimigos do arco | Espírito enfraquecido e Makrura corrompido com sprites existentes; perfil de combate comum e boss integrados | Boss tem teste próprio de três fases/arena; o javali cobre a rota de caça. Não há pacote final de animação de combate para todo o bestiário do jogo |

`spirit_elemental` continua como requisito de regiões futuras, fora das oito quests de Echo Isles. Os encontros da Fase 2 usam os atores e regras declarados pelas quests; a solução de armadilha e excedente não abre combate.

## Objetos e interação

`01_ASSETS/kataklysma/static_objects/CANDIDATE/echo_isles_quest_props_candidate_sheet_v001.png` contém um atlas de 20 células. O runtime instancia as regiões correspondentes como props individuais; `campaign_content_integrity_test.gd` confirma os 20 IDs referenciados e os nós/texturas das 37 interações. O atlas permanece candidato, não arte final aprovada. Cobertura incluída:

- Cabana de Awakening: colar, tigela ritual, janela/reflexo e bolsa de moedas (quatro objetos opcionais examináveis).
- Ritual de `QST_ECHO_002`: quatro totens e elementos visuais de canalização/recusa.
- Caça de `QST_ECHO_003`: rastros, carne/loot, isca ou armadilha e evidência de excedente do outro caçador.
- `QST_ECHO_004`: sapos vivos/coletáveis, reagentes/cesto e estação/lab do antídoto.
- `QST_ECHO_005`–`006`: peixes mortos, amostra/resíduo da contaminação, poças condutivas, ovos e pedra ritual.
- `QST_ECHO_007`: totem comunitário quebrado/reparável e pistas em areia/cabanas.
- `QST_ECHO_008`: bagagem/cartas e embarcação/cais.
- `QST_SEN_009`: caixas de suprimentos/comida, depósito e props de investigação/conselho (Fase 3; não incluídos no atlas atual).

Os props existentes no atlas têm instâncias, IDs e estados separados no runtime, mesmo compartilhando o arquivo de textura. Props exclusivos de Sen’jin serão produzidos na Fase 3.

## CGs do catálogo

`03_GODOT/data/cg_variants.json` declara 12 sequências; a pasta `VARIANTS/` contém 48 PNGs, quatro por sequência. Quatro sequências de Echo Isles estão integradas e passam por retorno de estado: Q002 ritual, Q003 caça, Q005 espírito da água e Q006 boss. Os quadros usam a ordem início → desenvolvimento → clímax → resolução, caption em PT-BR e retorno à quest/branch.

| Sequência | Quest M30 | Classificação de inventário |
|---|---|---|
| `echo_002_zekranu_totem_choice` | `QST_ECHO_002` | Integrada após a resposta ao ritual; quatro quadros e retomada durante CG testados |
| `echo_003_zalkiri_mokjala_hunt` | `QST_ECHO_003` (rota de caça) | Integrada após as quatro vitórias de caça; alternativas trap/surplus não exibem a CG de caça |
| `echo_004_rakjin_rivalry` | Nenhuma associação canônica aprovada | Não usar em `QST_ECHO_004`: a quest canônica é sobre sapos/antídoto, não rivalidade com Rak’jin |
| `echo_005_water_spirit_choice` | `QST_ECHO_005` | Integrada após a decisão do espírito; branch e retorno à quest testados |
| `echo_006_corrupted_makrura_boss` | `QST_ECHO_006` | Integrada após vitória/neutralização; save/load durante a apresentação testado |
| `echo_008_makjala_vision` | Possível `QST_ECHO_008` | Incerta: o cartão atual descreve despedida/embarque, não identifica uma visão como beat |
| `senjin_007_tazrima_rukka_herbs` | Possível `QST_SEN_009` | Não associar ainda: título “herbs” não corresponde ao roubo de suprimentos; o catálogo usa índice que não é o ID canônico da quest |
| `echo_009_azkarra_storm_ritual` e sequências de Razor Hill, Barrens, Ratchet e End | Fora do corte | Assets preservados para quests/localizações posteriores |

CG de Q008 `echo_008_makjala_vision` permanece sem uso: o cartão implementado é despedida e embarque e não confirma uma visão. As outras sequências fora do arco continuam assets de catálogo. Cada CG integrada foi reproduzida no contexto da quest e suas transições de estado foram cobertas pelos testes/screenshot atuais.

## Conteúdo narrativo e outros recursos

- O diálogo canônico de Echo Isles está em `03_GODOT/data/dialogue/pt_BR/campaign_echo_isles.json` e é carregado pelo runtime; a matriz de branches está em `03_GODOT/data/campaign/echo_isles.json`. `quest_01.json` é legado e não define o fluxo padrão Novo Jogo. A fala e as escolhas cobrem as oito quests em PT-BR.
- A música de campo de Echo Isles é um candidato com watermark e direitos não liberados. SFX finais de UI, quest e combate não foram encontrados.
- Inter/Cinzel, portraits dedicados de Zek’Ranu/Kataklysma, menu e sistemas gerais estão em uso. Portraits dedicados para os demais falantes e liberação/autoria final de áudio continuam pendências de asset/release (KI-002/KI-012).

## Lacunas por quest

| Quest | Aproveitável do acervo | Lacunas principais / decisão pendente |
|---|---|---|
| `QST_ECHO_001` | Campanha/cabana, quatro props examináveis, escolha e flags | Integrada; saída reflete ramo e salva antes de prosseguir |
| `QST_ECHO_002` | Zek’Ranu, quatro totens e CG ritual | Integrada; recusa do ar e quatro respostas com efeitos testados |
| `QST_ECHO_003` | Mok’Jala, Zal’Kiri, javali candidato, armadilha/excedente e CG de caça | Caça por turnos, trap e surplus são rotas distintas; asset do javali permanece candidato estático |
| `QST_ECHO_004` | Taz’Rima, aprendiz candidato, sapos, cesto/reagentes | Captura, troca, mentira e charme (sucesso/fail-forward) implementados; qualidade do antídoto testada |
| `QST_ECHO_005` | Espírito da água, pistas e CG | Análise/ajuda aplicam consequências e influência no boss |
| `QST_ECHO_006` | Makrura, arena/props e CG | Três fases, mecânicas de arena, vitória/neutralização e decisão do fragmento integradas |
| `QST_ECHO_007` | Crianças candidatas, pistas/totem e resolução | Quatro respostas não violentas com consequências e despedida contextualizada |
| `QST_ECHO_008` | Bagagem, Mak’Jala, Rak’jin e barco | Despedidas e quatro opções testadas; ao entregar a quest, inicia a chegada em Sen’jin e `QST_SEN_009`; transição/save revalidados na Fase 3 |
| `QST_SEN_009` | Background conceitual Sen’jin, Taz’Rima, Ruk’ka, diálogo PT-BR e foreground candidate | Quest integrada com quatro resoluções e save/load; 5 âncoras caminháveis/conectadas; nenhuma CG foi associada por inferência. Visual map review, playtest e clean export seguem abertos |

## Execução da Fase 3 — 2026-10-08

- `campaign_quest_runtime_test.gd`: 125 checks, incluindo as quatro escolhas do conselho, sucesso/falha de charme, falta de ouro, efeitos persistentes e migração do save legado.
- `campaign_content_integrity_test.gd`: 186 checks; 42 pontos de interação (37 Echo Isles + 5 Sen’jin) e 20 props da Fase 2.
- `senjin_walkability_test.gd`: 6.932 células aprovadas pela whitelist e 6.807 alcançáveis via `CharacterBody2D.test_move` a partir do cais; os cinco pontos de Q009 ficam conectados; 26 blockers têm corpo/forma física.
- `campaign_playthrough_test.gd`: fluxo contínuo do New Game ao término de Q009, com save/load no meio da quest e depois de concluída.
- Oito capturas atuais revisadas em `docs/qa/screenshots/phase3/`. A sétima mostra o foreground candidate no contexto do mapa; a oitava mostra o overlay F10.
- O gate da fase ainda está aberto. Nenhum desses testes substitui o playtest independente nem a exportação/execução em instalação limpa.

## Fontes e regra de progresso

Inventário verificado contra dados da campanha/diálogo/interações, `cg_variants.json`, `M30_QUEST_ACCEPTANCE.md`, `ASSET_REQUIREMENTS.md`, pastas de NPCs/entidades/CGs e o runtime atual. Arte candidata integrada não é arte final aprovada. Fases 1 e 2 estão fechadas; a implementação da Fase 3 passa QA local, mas o gate permanece aberto para aceite humano e clean install.
