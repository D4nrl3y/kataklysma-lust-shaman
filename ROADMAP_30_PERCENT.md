# Roadmap para uma build jogável de 30 por cento

**Baseline da revisão:** 7 de outubro de 2026
**Atualização de execução:** 8 de outubro de 2026

**Base revisada:** `39576a1` (`feat: implement Echo Isles blocker foundations`)

**Estado do repositório na revisão:** `main` sincronizada com `origin/main`, sem alterações locais antes deste documento.

**Execução atual:** Fases 0, 1 e 2 estão fechadas. Fase 3 liga Echo Isles a Sen’jin e entrega `QST_SEN_009`; QA automatizado/editor passou, o preset Windows foi criado e a build exportada passa smoke headless fora do projeto. O gate permanece aberto para playtest independente, revisão visual de percurso e validação GUI/save-load da build exportada. A estimativa de 35 pontos de 100 (faixa aproximada de 30%–45%) continua sendo planejamento, não percentual realizado; o M30 não está concluído.

## Decisão executiva

O projeto agora tem uma campanha contínua de Echo Isles até a resolução de `QST_SEN_009` em Sen’jin. As Fases 1 e 2 estão fechadas; a Fase 3 continua sem gate completo. Outras regiões, áudio liberado, revisão visual humana, playtest independente e QA GUI/save-load da build exportada continuam pendentes. Arte candidata integrada continua identificada como candidata, não como asset final aprovado.

O corte até `QST_SEN_009` em Sen’jin foi escolhido pelo usuário para a primeira campanha demonstrável. Esse recorte contém 9 das 15 quests principais. A primeira decomposição estima 35/100 pontos, com baixa confiança e faixa aproximada de 30%–45%; o fechamento das Fases 1 e 2 não valida essa estimativa nem mede percentual concluído. Revisar os pesos com dados de esforço observados na produção e no mapa/quest da Fase 3, sem usar contagem de quests ou arquivos como substituto.

O projeto não tem uma estimativa de esforço validada por histórico de execução que permita calcular seu percentual real concluído. A baseline v1 estabelece um denominador preliminar para planejar o escopo; “30%” continua sendo uma meta de entrega, não progresso atribuído por quantidade de arquivos.

## Estado encontrado

| Área | O que existe | O que isso ainda não comprova |
|---|---|---|
| Projeto Godot | Cena principal com menu, campanha Echo Isles → Sen’jin, `QST_SEN_009`, save/load, pause, diálogo, opções, minimapa e combate por turnos; Godot 4.7.2 | Playtest independente, build exportada em instalação limpa e release público ainda não foram aprovados |
| Código | Catálogo de campanha e interações separados em JSON, runtime de estado e diálogo PT-BR separados; `demo_game.gd` ainda centraliza integração e apresentação | Refatoração adicional para reduzir acoplamento e componentes de UI independentes |
| Mundo | Echo Isles, interior de cabana e Sen’jin estão ligados ao fluxo; 42 POIs totais, walkability em Sen’jin com 10 regiões/26 blockers, foreground candidate | Sen’jin usa background achatado e arte de foreground candidata; revisão visual ampla e outras regiões seguem pendentes |
| Personagens | NPCs necessários às oito quests estão posicionados e interativos; sprites específicos do aprendiz e das crianças permanecem candidatos | Retratos dedicados para todos os falantes, animações gerais de combate/cast e elenco das regiões futuras |
| CGs | Quatro sequências de quatro imagens integradas às quests 002, 003 (rota de caça), 005 e 006 | Outras CGs do catálogo não entram automaticamente no arco; a visão de Q008 não foi associada sem confirmação canônica |
| Quest e diálogo | Nove quests até `QST_SEN_009`, ramos, consequências, flags, relações, estado e PT-BR integrados | Playtest independente da duração/legibilidade e futuras regiões continuam pendentes |
| Combate | Combate por turnos integrado à caça de Q003 e ao boss Makrura de Q006; armadilha e excedente são alternativas sem combate | Elenco/inimigos comuns finais e balanceamento externo continuam como produção/QA posterior |
| Objetos e áudio | Atlas candidato com 20 props de quest integrado; música candidata e tons procedurais mantidos | Música com watermark/direitos não liberados; SFX finais de autoria não fornecidos |
| QA | Godot import, smoke, 213 checks da Fase 1, 125 runtime checks, 320 escolhas Echo, 186 checks de conteúdo e 8 capturas GUI Sen’jin | Não foi feito playtest independente nem teste de export/instalação limpa; M30 permanece aberto |

O acervo contém 48 quadros de CG em 12 sequências e backgrounds conceituais das regiões catalogadas. `static_objects/CANDIDATE/` contém o atlas de 20 props utilizado pelas interações de Echo Isles. A evidência atual de Sen’jin está em `docs/qa/screenshots/phase3/`; a busca em grade a partir do cais encontrou 6.932 células alcançáveis e validou conexão aos cinco POIs da Q009.

### Bloqueadores e inconsistências que afetam o roadmap

1. **Walkability P0:** `KI-001` foi fechado para o escopo da Fase 1. A geometria atual tem 16 regiões caminháveis, 17 blockers nomeados; 15 pontos permitidos/negados, 7 probes físicos e 7 rotas verificadas por busca e `CharacterBody2D` passaram. A proporção da protagonista foi medida em 2.53:1. Ajustes futuros por expansão do mapa voltam a exigir QA.
2. **Conteúdo canônico:** a campanha principal agora inicia nas oito quests canônicas de Echo Isles; as CGs integradas estão ligadas aos beats de Q002, Q003 (caça), Q005 e Q006. O antigo fluxo de maré permanece apenas como legado/protótipo e não é a campanha padrão.
3. **Combate em conflito documental:** o usuário definiu combate por turnos, enquanto a seção de controle da Bíblia descreve combate em tempo real. Este roadmap mantém turnos como direção de produção vigente; a Bíblia e os documentos derivados precisam ser reconciliados.
4. **Mapa do escopo:** a lista de sete regiões foi alinhada à Bíblia e Orgrimmar foi incluída; seu background ainda falta. O Eye shrine ficou catalogado como local especial do clímax, não como oitava região.
5. **Documentação:** `README_START_HERE.md`, `RELEASE_NOTES.md`, `PRODUCTION_STATUS_V001.md` e `CG_VARIANT_ROSTER.md` foram alinhados para separar asset produzido, runtime integrado, QA pendente e aprovação. Ver `docs/decisions/M30_CANONICAL_BASELINE.md`.
6. **Percentual não calculável:** há uma estimativa preliminar por pacote, mas não um backlog completo de tarefas calibrado. A Fase 1 concluída estabiliza a fundação, mas não fornece esforço validado suficiente para declarar percentual do jogo completo.

## Definição proposta do M30

Uma pessoa deve conseguir instalar/abrir a build, iniciar uma campanha, jogar uma sequência contínua em PT-BR, chegar à resolução de `QST_SEN_009`, salvar, fechar o jogo e continuar o save. Esse corte foi escolhido pelo usuário; a estimativa de esforço para verificar o limiar segue preliminar. Um conjunto de imagens ou uma cena de teste isolada não conta como conteúdo jogável.

### Conteúdo incluído

- Echo Isles como zona tutorial e de exploração, cobrindo `QST_ECHO_001`–`QST_ECHO_008`.
- Transição persistente para Sen’jin Village e implementação de `QST_SEN_009` como encerramento do corte M30.
- Personagens, inimigos, objetos, diálogos, escolhas e CGs necessários a essas quests. Os 4 quadros serão integrados para cada CG que entrar no recorte; arte fora do recorte permanece conteúdo de produção, não progresso jogável.
- Combate por turnos para encontros do recorte, com pelo menos inimigos comuns e o confronto de Makrura. Cada evento aleatório deve ser tipado e roteado: aparição de NPC, descoberta de recurso, presságio e emboscada não podem ser tratados como a mesma batalha.
- Estados consistentes de quest: disponível, em progresso, pronta para entrega e entregue; flags, atributos, relações e objetivos sobrevivem a save/load.

### Fora do M30

Durotar, Razor Hill, Orgrimmar, Ratchet, Northern Barrens e o clímax do Eye; quests `QST_DUR_010` em diante; finais e epílogos; inventário/equipamento/crafting gerais; suporte a todas as animações de combate dos 13 NPCs; polimento de todos os 48 quadros de CG; publicação comercial. Esses itens podem ter arte ou dados já preparados, mas não entram na build M30 sem integração e QA.

## Roadmap de entregas

### Fase 0 — Fechar a linha de base e o cânone

**Entrega:** backlog M30 aprovado, fonte de verdade alinhada e estimativa total rastreável.

**Status:** concluída — baseline de planejamento v1 congelada; estimativa de baixa confiança será calibrada na Fase 1.

- [x] Revisar os dados de regiões, CG e quest protótipo contra a Bíblia e o runtime.
- [x] Registrar combate por turnos como direção vigente, sete regiões canônicas e Eye shrine como local especial.
- [x] Atualizar a lista de regiões e corrigir os documentos de início, status, release e roster de CG.
- [x] Receber decisão final sobre o corte do M30: Echo Isles `QST_ECHO_001`–`QST_ECHO_008` + Sen’jin `QST_SEN_009`.
- [x] Criar decomposição preliminar do escopo completo em pontos relativos; estimativa inicial do corte: 35/100, faixa aproximada de 30%–45% (`docs/production/M30_WORK_BREAKDOWN.md`).
- [x] Registrar objetivos, pré-requisitos de spine, estados, cenas, branches, flags, consequências e critérios de aceite das nove quests em `docs/production/M30_QUEST_ACCEPTANCE.md`.
- [x] Inventariar por quest recursos integrados, existentes candidatos e ausentes em `docs/production/M30_ASSET_COVERAGE.md`.
- [x] Fixar os dois NPCs prioritários da despedida de `QST_ECHO_008`: Mak’Jala e Rak’jin.
- [x] Congelar o escopo e os critérios da baseline v1. A incerteza de esforço e as lacunas de assets ficam visíveis, não são tratadas como conteúdo pronto.

**Gate:** baseline v1 aprovada para planejamento: conteúdo tem IDs, dependências conhecidas, estados, consequências e aceite; recursos estão classificados como integrados, candidatos ou ausentes; o total do jogo e o corte usam a mesma unidade relativa. A precisão será recalibrada quando houver dados reais de produção. Isso não declara 30% de progresso concluído.

### Fase 1 — Estabilizar a fundação jogável

**Entrega:** uma build de Echo Isles confiável para continuar a campanha.

- Importar e abrir o projeto na versão Godot acordada; corrigir erros de parser, recursos ausentes e warnings que afetem a execução.
- Fechar `KI-001`: calibrar escala, colisores, áreas transitáveis e blockers contra a arte atual; validar costa, água, cliffs, rochas, vegetação, escadas, ponte e rotas. F10 é somente ferramenta de QA.
- Validar menu, direções e pivôs, câmera, Y-sort, diálogo, retrato, opções, tutorial, minimapa, pause, áudio, save/load e os caminhos de CG.
- Separar o estado da quest e os dados PT-BR do grande script de demo antes de aumentar o conteúdo; manter a build jogável durante a mudança.
- Corrigir o roteamento de encontros e limitar cada tipo à sua região/regra; garantir que só `monster_ambush` abra combate.

**Gate:** iniciar do menu e completar o fluxo atual sem erro; screenshots atuais, não reaproveitados; testes de fronteira da walkability passam na geometria corrente. Nenhum P0 visual permanece aberto.

**Execução atual (2026-10-08):** **CONCLUÍDA E REVALIDADA.** Parser/import, `demo_smoke_test.gd`, acceptance suite (211 headless / 216 GUI na evidência de aceite), boundary suite (22/22) e captura GUI (23 imagens) passaram. Na reauditoria da transição, parser/import, smoke, 211 checks headless e 22/22 boundary probes passaram novamente. A escala foi medida em 2.53:1; opções, eventos de Echo Isles, rotina do Zek'Ranu durante uma travessia física do jogador, quest/diálogo separados, minimapa, fontes, áudio em runtime e fluxo atual foram testados. KI-001, KI-003, KI-004, KI-006 e KI-008 estão fechados para o escopo da fase. `03_GODOT/QA_REPORT.md` contém resultados e limites.

### Fase 2 — Entregar o arco de Echo Isles

**Entrega:** campanha de Echo Isles do despertar à partida, com estado e ramificações persistentes.

- [x] Implementar `QST_ECHO_001`–`QST_ECHO_008` como quests separadas, com objetivos, interações, alternativas e fail-forward.
- [x] Integrar os NPCs necessários, 37 POIs, rotas do mapa e 20 objetos de quest instanciados por atlas.
- [x] Integrar caça por turnos, alternativas não-combate, boss de Makrura e consequências mecânicas para atributos, flags, confiança, afinidade, inventário e desbloqueios.
- [x] Integrar quatro CGs de quatro imagens nos beats aprovados para Q002, rota de caça Q003, Q005 e Q006, com legenda PT-BR e retorno ao estado correto.
- [x] Persistir quest/progresso, posição segura, objetivos, flags, atributos, relações, inventário, tutorial e capítulo; testar retomada durante quest, CG, boss e saída.

**Gate:** começo, quests, boss, escolhas, conclusão e saída da região podem ser jogados em uma campanha nova e após carregar save; nenhum texto final chama o protótipo de demo completa.

**Execução atual (2026-10-08):** **CONCLUÍDA — GATE FECHADO.** O fluxo de novo jogo inicia `QST_ECHO_001`; as oito quests, objetivos, 32 escolhas, rotas alternativas, 37 âncoras, 20 props, quatro sequências de CG, caça em turnos, boss Makrura, capítulo de partida e retomada por save/load estão integrados. Passaram `campaign_quest_runtime_test.gd` (90), `campaign_frog_branch_test.gd` (15), `campaign_branch_matrix_test.gd` (320), `campaign_content_integrity_test.gd` (130; inclui âncoras caminháveis dos NPCs), `campaign_playthrough_test.gd`, `campaign_alternate_routes_test.gd`, `makrura_boss_test.gd`, `campaign_anchor_validation.gd`, smoke e captura GUI (21 screenshots). O QA e os limites de assets estão em `03_GODOT/QA_REPORT.md` e `docs/production/M30_ASSET_COVERAGE.md`. O encerramento persiste como `ECHO_ISLES_COMPLETE`; Sen’jin não é carregada nesta fase e continua sendo a entrega da Fase 3.

### Fase 3 — Entregar Sen’jin e o primeiro encerramento de campanha

**Entrega:** primeira versão demonstrável termina `QST_SEN_009` em Sen’jin Village.

- [x] Carregar Sen’jin como zona runtime, com 10 regiões caminháveis, 26 blockers poligonais nomeados, spawn de cais, marcadores, 5 POIs da quest e overlay F10. O mapa permanece uma imagem conceitual achatada; foreground adicionado permanece identificado como candidate.
- [x] Implementar a chegada, Taz’Rima, Ruk’ka, investigação PT-BR e quatro resoluções de `QST_SEN_009`, com consequências/fail-forward e verificação de cada ramo, incluindo charme bem-sucedido/falho e falta de ouro.
- [x] Implementar a transição Echo Isles → Sen’jin sem resetar estado, HUD, opções ou save; validar migração de save legado, retomada durante investigação e novo load após concluir a quest.
- [x] Integrar a tabela regional de eventos, spawn regions próprios, aparição de NPC, pedido de alquimia e problema de suprimentos; os handlers persistem resultado e não abrem combate. `monster_ambush` permanece o tipo que inicia combate.
- [x] Expandir QA automatizado da malha: 11 marcos caminháveis, 10 marcos de água/borda bloqueados, colisão física individual dos 26 blockers e conectividade dos cinco POIs de Q009; todas as verificações passam.
- [ ] Fazer travessia visual em gameplay de toda a costa, cachoeira/cliffs, escadas, vila, cais e limites do mapa; aceitar ou corrigir o alinhamento dos polígonos contra a arte.
- [ ] Fazer playtest independente e passe de duração/balanceamento; recolher observações de alguém que não participou da implementação e ajustar onboarding/dificuldade conforme evidência.
- [x] Configurar preset Windows x86_64, instalar o template oficial Godot 4.7.2, exportar release e iniciar o executável headless fora do diretório do projeto (exit 0).
- [ ] Testar a build exportada em GUI, incluindo save/load em conta limpa ou segunda máquina; recolher playtest independente e duração/balanceamento.

**Gate M30:** campanha contínua do despertar à resolução em Sen’jin; menus e configurações persistem; save/load atravessa a mudança de zona; todos os caminhos críticos funcionam; sem crashes, referências ausentes ou bloqueador P0; build exportada e reproduzida em instalação limpa.

**Execução atual (2026-10-08):** implementação jogável e QA automatizado/GUI do editor passaram. A regressão mais recente passou 11/11 scripts; `campaign_playthrough_test.gd` conclui Echo Isles → Sen’jin → Q009 e testa save/load durante e após a quest; runtime passa 125 checks; conteúdo passa 186 checks; walkability alcança 6.807 posições físicas, verifica 11 marcos caminháveis, 10 pontos de bloqueio, 26 blockers por colisão e os cinco POIs. A captura do editor gera oito PNGs. O preset Windows x86_64 exportou um executável de 659,241,336 bytes, iniciado fora do projeto em smoke headless (exit 0). Ainda faltam travessia visual integral em gameplay, teste GUI/save-load na build exportada e playtest independente. **Fase 3: EM ANDAMENTO — GATE NÃO FECHADO. A Fase 4 não começou.**

### Fase 4 — Qualidade de lançamento e manutenção

- Fechar opções, tipografia, retratos e rotas de NPC com QA real; limpar strings provisórias e divergências PT-BR.
- Substituir a faixa com watermark por áudio autorizado e adicionar SFX autorizados antes de distribuição pública; documentar licenças.
- Atualizar `CHANGELOG.md`, `QA_REPORT.md`, `KNOWN_ISSUES.md`, `ASSET_REQUIREMENTS.md` e notas de release com fatos da build M30.
- Executar regressão de menu, movimento, colisão, quests, escolhas, atributos, CG, combate, eventos, minimapa, tutorial, pause, save/load e instalação/export.

**Gate:** a classificação pública só pode ser dada após os P0 fechados e evidência atual. Se áudio ou outro requisito de distribuição continuar sem direitos confirmados, o resultado é build interna, não release pública.

## Como medir os 30 por cento

Na Fase 0 foi criada uma estrutura de trabalho que cobre **todo o jogo previsto** e estima cada pacote com a mesma unidade relativa. A métrica futura de progresso aceito será:

`progresso aceito = esforço dos itens concluídos e aceitos ÷ esforço estimado do escopo total`

Um item só conta como concluído quando está integrado, tem critério de aceite satisfeito e possui QA correspondente. Arte criada, JSON de catálogo, screenshot antigo, script de captura ou teste não executado não pontuam como funcionalidade pronta. O M30 precisa simultaneamente atingir pelo menos 30% nessa métrica e cumprir todos os gates de conteúdo e qualidade descritos acima.

O percentual atual continua **não calculado**: pontos estimados para o M30 não são pontos implementados. A classificação mais precisa é: **protótipo jogável em evolução; build atual para revisão interna; M30 ainda não atingido**.

## QA e regra de evidência

O baseline de 2026-10-07 foi uma revisão estática: naquele momento não houve execução do Godot. A atualização de execução em 2026-10-08 realizou parser/import, smoke, acceptance automatizada em headless e GUI, QA de fronteiras e captura gráfica; os resultados atuais e respectivos limites estão em `03_GODOT/QA_REPORT.md`. Os testes aprovam a build efetivamente aberta nesta pasta, não builds futuras ou conteúdo ainda não implementado.

Para cada gate futuro, guardar screenshots/capturas da build correspondente e registrar engine/commit. Um `PASS` só vale para a versão efetivamente testada; screenshots antigos e resultados de outra geometria não são evidência da build corrente.

## Fontes de referência revisadas

- `00_DOCS/source_lore/Lust_Shamans_Journey_Complete_Game_Narrative_Bible_V2.0.docx`
- `project.godot`, `03_GODOT/scenes/main.tscn` e `03_GODOT/scripts/`
- `03_GODOT/PRODUCTION_STATUS_V001.md`, `DEMO_README.md`, `MAP_PRODUCTION_SPEC_V001.md` e `NPC_MONSTER_STATIC_SCOPE_V001.md`
- `03_GODOT/QA_REPORT.md`, `KNOWN_ISSUES.md`, `CHANGELOG.md` e `RELEASE_NOTES.md`
- `03_GODOT/data/` e `ASSET_REQUIREMENTS.md`
- `docs/decisions/M30_CANONICAL_BASELINE.md`
- `docs/production/M30_WORK_BREAKDOWN.md`
- `docs/production/M30_QUEST_ACCEPTANCE.md`
- `docs/production/M30_ASSET_COVERAGE.md`
- `01_ASSETS/kataklysma/maps/README.md`, catálogo de assets, `99_AUDIT/CG_VARIANT_ROSTER.md` e `VISUAL_IDENTITY_QA_V002.md`
