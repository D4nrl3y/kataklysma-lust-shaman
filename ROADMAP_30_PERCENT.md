# Roadmap para uma build jogável de 30 por cento

**Revisão do projeto:** 7 de outubro de 2026

**Base revisada:** `39576a1` (`feat: implement Echo Isles blocker foundations`)

**Estado do repositório na revisão:** `main` sincronizada com `origin/main`, sem alterações locais antes deste documento.

**Execução:** Fase 0 em andamento. A linha de base canônica foi registrada em `docs/decisions/M30_CANONICAL_BASELINE.md`; a escolha final do corte M30 e a estimativa total ainda estão pendentes.

## Decisão executiva

O projeto já tem um protótipo funcional de Echo Isles e um acervo de arte amplo, mas ainda não tem uma build que possa ser chamada honestamente de 30% do jogo. Hoje, conteúdo produzido, conteúdo integrado e conteúdo validado são coisas diferentes: somente Echo Isles está ligada ao fluxo principal; várias regiões, quests, personagens e CGs existem como arte ou dados de referência, sem cenas jogáveis correspondentes. A atualização técnica mais recente também ainda não recebeu QA em runtime.

O corte até `QST_SEN_009` em Sen’jin continua sendo a recomendação da Bíblia para a primeira demo demonstrável, mas ainda não está provado que corresponda a 30% do esforço total. Esse recorte contém 9 das 15 quests principais. Está em consulta uma alternativa menor: encerrar o M30 em Echo Isles após `QST_ECHO_006`, com a luta contra a Makrura e a decisão do fragmento, deixando Sen’jin como uma entrega posterior. A escolha não altera o princípio de medição: quests ou assets não equivalem a esforço concluído.

O projeto não tem hoje uma estimativa total de esforço aprovada que permita calcular seu percentual real. Portanto, “30%” deve ser uma meta de escopo e esforço, não um número atribuído por quantidade de arquivos. A Fase 0 abaixo estabelece a linha de base para medir o progresso sem inflá-lo com assets ainda não usados.

## Estado encontrado

| Área | O que existe | O que isso ainda não comprova |
|---|---|---|
| Projeto Godot | Projeto na raiz, cena principal, menu, exploração de Echo Isles, UI construída em runtime e sistemas de save, pause, diálogo, opções e combate | Uma build limpa, reproduzível e validada após as mudanças de 7 de outubro |
| Código | 11 scripts Godot sob `03_GODOT`; `demo_game.gd` concentra aproximadamente 1.349 linhas e monta a maior parte da demo | Arquitetura de campanha com cenas de zona, quests e componentes de UI independentes |
| Mundo | 7 imagens de background conceitual e catálogo de zonas | Sete mapas jogáveis: só Echo Isles é carregada pelo jogo; os backgrounds não têm as camadas modulares de colisão, foreground, pontos e rotas descritas na especificação |
| Personagens | 13 NPCs nomeados com conjuntos de `IDLE`/`WALK`; 3 entidades com conjuntos parciais; retratos, locks e sprites da protagonista | Elenco integrado: a cena atual posiciona Zek’Ranu; os NPCs restantes não formam ainda a população jogável. Os 13 NPCs não têm conjuntos `CAST`/`COMBAT` |
| CGs | 48 PNGs em 12 sequências de quatro quadros, além de keyframes históricos | Doze cenas implementadas: a demo tem uma sequência ativa, definida por caminhos no script |
| Quest e diálogo | Uma quest curta, cinco escolhas iniciais, atributos, flags, marcadores de estado, save/load; há JSON de diálogo PT-BR | As 15 quests da Bíblia: o JSON de diálogo e vários catálogos não são a fonte consumida pelo fluxo ativo, que ainda contém texto e estado codificados em `demo_game.gd` |
| Combate | Sistema de turnos separado, cinco ações e dois perfis inimigos; encounter manager e tabelas de eventos | Sistema de campanha validado ou encontros variados: eventos de NPC/recurso/presságio podem cair no mesmo início de combate; apenas água e Makrura são mapeadas para inimigos. A tabela também declara regiões de spawn, mas o movimento atual tenta rolar encontros por distância percorrida, sem uma região por mapa |
| Objetos e áudio | Marcadores, ícones e música candidata; tons procedurais como fallback | A pasta `static_objects` está vazia. A faixa de campo está marcada com watermark e sem liberação de direitos; SFX finais não estão presentes |
| QA | Relatório e screenshots da build anterior, scripts de captura e QA | Evidência da build atual: o próprio relatório registra que os resultados anteriores pertencem à geometria antiga e que a atualização recente não foi testada |

O inventário do repositório encontra 48 imagens de CG na pasta de variantes, 7 backgrounds de zona e nenhum arquivo em `static_objects`. A inspeção visual do background de Echo Isles e do antigo overlay confirma que há uma base artística detalhada, mas o screenshot de walkability é histórico: ele não pode aprovar os polígonos estreitados no commit revisado.

### Bloqueadores e inconsistências que afetam o roadmap

1. **Walkability P0:** `KI-001` continua aberto. Polígonos e probes foram alterados, mas não há captura atual nem repetição de tentativas deliberadas de sair dos caminhos.
2. **Conteúdo ainda não canônico:** o fluxo ativo “Purificar a Maré Corrompida” é agora classificado como protótipo sem ID canônico. O runtime ainda liga esse objetivo à CG `echo_002_zekranu_totem_choice`, cujo evento narrativo é diferente. A Fase 2 precisa reconciliar a quest e o gatilho da CG com os cartões canônicos.
3. **Combate em conflito documental:** o usuário definiu combate por turnos, enquanto a seção de controle da Bíblia descreve combate em tempo real. Este roadmap mantém turnos como direção de produção vigente; a Bíblia e os documentos derivados precisam ser reconciliados.
4. **Mapa do escopo:** a lista de sete regiões foi alinhada à Bíblia e Orgrimmar foi incluída; seu background ainda falta. O Eye shrine ficou catalogado como local especial do clímax, não como oitava região.
5. **Documentação:** `README_START_HERE.md`, `RELEASE_NOTES.md`, `PRODUCTION_STATUS_V001.md` e `CG_VARIANT_ROSTER.md` foram alinhados para separar asset produzido, runtime integrado, QA pendente e aprovação. Ver `docs/decisions/M30_CANONICAL_BASELINE.md`.
6. **Percentual não calculável:** ainda não há backlog completo estimado em unidades consistentes. Os QA `PASS` anteriores não devem ser copiados para a nova build; `QA_REPORT.md` já delimita que são resultados históricos.

## Definição proposta do M30

Uma pessoa deve conseguir instalar/abrir a build, iniciar uma campanha, jogar uma sequência contínua em PT-BR, chegar a uma resolução de capítulo, salvar, fechar o jogo e continuar o save. O capítulo final do M30 depende da escolha de escopo e da estimativa do esforço total. Um conjunto de imagens ou uma cena de teste isolada não conta como conteúdo jogável.

### Conteúdo incluído

- Echo Isles como zona tutorial e de exploração; o corte será `QST_ECHO_006` ou `QST_SEN_009`, conforme a decisão de escopo e a estimativa aprovada.
- Se o corte chegar a Sen’jin, implementar também `QST_ECHO_007`, `QST_ECHO_008`, a transição persistente e `QST_SEN_009` em uma segunda zona jogável.
- Personagens, inimigos, objetos, diálogos, escolhas e CGs necessários a essas quests. Os 4 quadros serão integrados para cada CG que entrar no recorte; arte fora do recorte permanece conteúdo de produção, não progresso jogável.
- Combate por turnos para encontros do recorte, com pelo menos inimigos comuns e o confronto de Makrura. Cada evento aleatório deve ser tipado e roteado: aparição de NPC, descoberta de recurso, presságio e emboscada não podem ser tratados como a mesma batalha.
- Estados consistentes de quest: disponível, em progresso, pronta para entrega e entregue; flags, atributos, relações e objetivos sobrevivem a save/load.

### Fora do M30

Durotar, Razor Hill, Orgrimmar, Ratchet, Northern Barrens e o clímax do Eye; quests `QST_DUR_010` em diante; finais e epílogos; inventário/equipamento/crafting gerais; suporte a todas as animações de combate dos 13 NPCs; polimento de todos os 48 quadros de CG; publicação comercial. Esses itens podem ter arte ou dados já preparados, mas não entram na build M30 sem integração e QA.

## Roadmap de entregas

### Fase 0 — Fechar a linha de base e o cânone

**Entrega:** backlog M30 aprovado, fonte de verdade alinhada e estimativa total rastreável.

**Status:** em andamento.

- [x] Revisar os dados de regiões, CG e quest protótipo contra a Bíblia e o runtime.
- [x] Registrar combate por turnos como direção vigente, sete regiões canônicas e Eye shrine como local especial.
- [x] Atualizar a lista de regiões e corrigir os documentos de início, status, release e roster de CG.
- [ ] Receber decisão final sobre o corte do M30.
- [ ] Decompor e estimar o escopo completo; calcular se o corte escolhido corresponde a 30%.
- [ ] Aprovar os critérios de aceite do backlog e congelar a linha de base.

**Gate:** todo conteúdo M30 tem ID, pré-requisito, estado final, consequências, recursos associados e critério de aceite. O denominador do projeto está estimado e o corte escolhido corresponde a 30% do esforço planejado. Até fechar os itens pendentes, não declarar a Fase 0 concluída nem progresso de 30%.

### Fase 1 — Estabilizar a fundação jogável

**Entrega:** uma build de Echo Isles confiável para continuar a campanha.

- Importar e abrir o projeto na versão Godot acordada; corrigir erros de parser, recursos ausentes e warnings que afetem a execução.
- Fechar `KI-001`: calibrar escala, colisores, áreas transitáveis e blockers contra a arte atual; validar costa, água, cliffs, rochas, vegetação, escadas, ponte e rotas. F10 é somente ferramenta de QA.
- Validar menu, direções e pivôs, câmera, Y-sort, diálogo, retrato, opções, tutorial, minimapa, pause, áudio, save/load e os caminhos de CG.
- Separar o estado da quest e os dados PT-BR do grande script de demo antes de aumentar o conteúdo; manter a build jogável durante a mudança.
- Corrigir o roteamento de encontros e limitar cada tipo à sua região/regra; garantir que só `monster_ambush` abra combate.

**Gate:** iniciar do menu e completar o fluxo atual sem erro; screenshots atuais, não reaproveitados; testes de fronteira da walkability passam na geometria corrente. Nenhum P0 visual permanece aberto.

### Fase 2 — Entregar o arco de Echo Isles

**Entrega:** campanha de Echo Isles do despertar à partida, com estado e ramificações persistentes.

- Implementar `QST_ECHO_001`–`QST_ECHO_008` como quests separadas, com objetivos e soluções alternativas onde a Bíblia pede; incluir interações e fail-forward, sem criar quests novas apenas para inflar contagem.
- Integrar os NPCs nomeados e genéricos realmente necessários, rotas e POIs; criar os objetos de quest que hoje não existem como arquivos modulares.
- Implementar pelo menos uma batalha comum, o boss de Makrura e a resolução pós-combate; atributos e escolhas devem afetar checks, consequências ou estado, não apenas conceder +2 sem uso posterior.
- Integrar as CGs do recorte em sequências de quatro imagens, com continuidade validada, captions/localização e retorno correto ao jogo.
- Salvar progresso, posição segura, objetivos, flags, atributos, relações, tutorial e capítulo; testar retomada em cada transição importante.

**Gate:** começo, quests, boss, escolhas, conclusão e saída da região podem ser jogados em uma campanha nova e após carregar save; nenhum texto final chama o protótipo de demo completa.

### Fase 3 — Entregar Sen’jin e o primeiro encerramento de campanha

**Entrega:** primeira versão demonstrável termina `QST_SEN_009` em Sen’jin Village.

- Transformar o background conceitual de Sen’jin em mapa jogável com colisões, foreground, rotas, marcadores e spawn points próprios.
- Implementar a chegada, os NPCs necessários (incluindo Taz’Rima e Ruk’ka), investigação e resolução de `QST_SEN_009`.
- Implementar a transição Echo Isles → Sen’jin sem resetar estado, interface ou save.
- Incluir NPCs/recursos aleatórios com resultados próprios e limites de frequência; eventos não devem interromper diálogo, CG ou boss.
- Fazer um passe de balanceamento e duração com jogadores que não participaram do desenvolvimento; ajustar instruções e dificuldade a partir das observações.

**Gate M30:** campanha contínua do despertar à resolução em Sen’jin; menus e configurações persistem; save/load atravessa a mudança de zona; todos os caminhos críticos funcionam; sem crashes, referências ausentes ou bloqueador P0; build exportada e reproduzida em instalação limpa.

### Fase 4 — Qualidade de lançamento e manutenção

- Fechar opções, tipografia, retratos e rotas de NPC com QA real; limpar strings provisórias e divergências PT-BR.
- Substituir a faixa com watermark por áudio autorizado e adicionar SFX autorizados antes de distribuição pública; documentar licenças.
- Atualizar `CHANGELOG.md`, `QA_REPORT.md`, `KNOWN_ISSUES.md`, `ASSET_REQUIREMENTS.md` e notas de release com fatos da build M30.
- Executar regressão de menu, movimento, colisão, quests, escolhas, atributos, CG, combate, eventos, minimapa, tutorial, pause, save/load e instalação/export.

**Gate:** a classificação pública só pode ser dada após os P0 fechados e evidência atual. Se áudio ou outro requisito de distribuição continuar sem direitos confirmados, o resultado é build interna, não release pública.

## Como medir os 30 por cento

Na Fase 0, criar uma estrutura de trabalho que cubra **todo o jogo previsto**, e estimar cada item com a mesma unidade (por exemplo, pontos de esforço). A métrica será:

`progresso aceito = esforço dos itens concluídos e aceitos ÷ esforço estimado do escopo total`

Um item só conta como concluído quando está integrado, tem critério de aceite satisfeito e possui QA correspondente. Arte criada, JSON de catálogo, screenshot antigo, script de captura ou teste não executado não pontuam como funcionalidade pronta. O M30 precisa simultaneamente atingir pelo menos 30% nessa métrica e cumprir todos os gates de conteúdo e qualidade descritos acima.

Até a Fase 0 ser aprovada, o percentual atual é **não calculado**. A classificação mais precisa é: **protótipo jogável em evolução; build atual para revisão interna; M30 ainda não atingido**.

## QA e regra de evidência

Esta revisão foi estática: examinei o inventário completo do repositório, os scripts de runtime relevantes, dados de produção, documentação de status e screenshots existentes, além de inspecionar visualmente o background de Echo Isles e um overlay histórico. **Não iniciei o Godot nem executei parser, smoke tests, QA automatizado ou uma sessão de jogo.** Os resultados `PASS` de `QA_REPORT.md` são históricos e não aprovam as mudanças do commit revisado.

Para cada gate futuro, guardar screenshots/capturas da build correspondente e registrar engine/commit. Um `PASS` só vale para a versão efetivamente testada; screenshots antigos e resultados de outra geometria não são evidência da build corrente.

## Fontes de referência revisadas

- `00_DOCS/source_lore/Lust_Shamans_Journey_Complete_Game_Narrative_Bible_V2.0.docx`
- `project.godot`, `03_GODOT/scenes/main.tscn` e `03_GODOT/scripts/`
- `03_GODOT/PRODUCTION_STATUS_V001.md`, `DEMO_README.md`, `MAP_PRODUCTION_SPEC_V001.md` e `NPC_MONSTER_STATIC_SCOPE_V001.md`
- `03_GODOT/QA_REPORT.md`, `KNOWN_ISSUES.md`, `CHANGELOG.md` e `RELEASE_NOTES.md`
- `03_GODOT/data/` e `ASSET_REQUIREMENTS.md`
- `docs/decisions/M30_CANONICAL_BASELINE.md`
- `01_ASSETS/kataklysma/maps/README.md`, catálogo de assets, `99_AUDIT/CG_VARIANT_ROSTER.md` e `VISUAL_IDENTITY_QA_V002.md`
