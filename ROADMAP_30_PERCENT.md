# Roadmap para uma build jogável de 30 por cento

**Revisão do projeto:** 7 de outubro de 2026

**Base revisada:** `39576a1` (`feat: implement Echo Isles blocker foundations`)

**Estado do repositório na revisão:** `main` sincronizada com `origin/main`, sem alterações locais antes deste documento.

## Decisão executiva

O projeto já tem um protótipo funcional de Echo Isles e um acervo de arte amplo, mas ainda não tem uma build que possa ser chamada honestamente de 30% do jogo. Hoje, conteúdo produzido, conteúdo integrado e conteúdo validado são coisas diferentes: somente Echo Isles está ligada ao fluxo principal; várias regiões, quests, personagens e CGs existem como arte ou dados de referência, sem cenas jogáveis correspondentes. A atualização técnica mais recente também ainda não recebeu QA em runtime.

Recomendo que o marco **M30** seja uma primeira campanha curta, coesa e canônica: do despertar em Echo Isles até a conclusão de `QST_SEN_009` em Sen’jin Village, com as quests `QST_ECHO_001`–`QST_ECHO_008` e `QST_SEN_009`. A Bíblia chama o encerramento em Sen’jin de primeira versão comercialmente demonstrável. Esse recorte cobre 9 das 15 quests principais listadas, mas isso **não significa 60% do jogo**: contagem de quests não mede o trabalho de mapas, sistemas, ramificações, arte integrada, áudio e QA.

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
2. **Conteúdo ainda não canônico:** o fluxo ativo usa `echo_isles_quest_01` e a quest “Purificar a Maré Corrompida”; ela não está rastreada como uma das `QST_ECHO_001`–`QST_SEN_009` da Bíblia. Antes de criar mais quests, é preciso mapear o que se preserva e o que será substituído.
3. **Combate em conflito documental:** o usuário definiu combate por turnos, enquanto a seção de controle da Bíblia descreve combate em tempo real. Este roadmap mantém turnos como direção de produção vigente; a Bíblia e os documentos derivados precisam ser reconciliados.
4. **Mapa do escopo divergente:** `zones.json` lista sete zonas, mas não Orgrimmar; a Bíblia lista Orgrimmar e também descreve o Eye of the Storm como local de clímax. A Fase 0 deve decidir se “Eye” é uma zona separada e qual é a lista canônica total.
5. **Documentação contraditória:** `CG_VARIANT_ROSTER.md` ainda diz que as sequências além da primeira estão pendentes, enquanto `cg_variants.json` e `PRODUCTION_STATUS_V001.md` declaram 12 sequências aprovadas. `RELEASE_NOTES.md` também chama opções e fontes de pendentes, embora as mudanças mais recentes as tenham integrado com QA pendente. `README_START_HERE.md` ainda descreve o kit de assets antigo, não o projeto Godot aberto pela raiz.
6. **Percentual não calculável:** ainda não há backlog completo estimado em unidades consistentes. Os QA `PASS` anteriores não devem ser copiados para a nova build; `QA_REPORT.md` já delimita que são resultados históricos.

## Definição proposta do M30

Uma pessoa deve conseguir instalar/abrir a build, iniciar uma campanha, jogar uma sequência contínua em PT-BR, concluir o arco inicial em Sen’jin, salvar, fechar o jogo, continuar o save e chegar a um encerramento de capítulo compreensível. Um conjunto de imagens ou uma cena de teste isolada não conta como conteúdo jogável.

### Conteúdo incluído

- Echo Isles como zona tutorial e de exploração, com as quests `QST_ECHO_001`–`QST_ECHO_008` implementadas conforme a Bíblia ou com desvios aprovados e documentados.
- Sen’jin Village como segunda zona jogável, incluindo `QST_SEN_009` e uma transição persistente a partir de Echo Isles.
- Personagens, inimigos, objetos, diálogos, escolhas e CGs necessários a essas quests. Os 4 quadros serão integrados para cada CG que entrar no recorte; arte fora do recorte permanece conteúdo de produção, não progresso jogável.
- Combate por turnos para encontros do recorte, com pelo menos inimigos comuns e o confronto de Makrura. Cada evento aleatório deve ser tipado e roteado: aparição de NPC, descoberta de recurso, presságio e emboscada não podem ser tratados como a mesma batalha.
- Estados consistentes de quest: disponível, em progresso, pronta para entrega e entregue; flags, atributos, relações e objetivos sobrevivem a save/load.

### Fora do M30

Durotar, Razor Hill, Orgrimmar, Ratchet, Northern Barrens e o clímax do Eye; quests `QST_DUR_010` em diante; finais e epílogos; inventário/equipamento/crafting gerais; suporte a todas as animações de combate dos 13 NPCs; polimento de todos os 48 quadros de CG; publicação comercial. Esses itens podem ter arte ou dados já preparados, mas não entram na build M30 sem integração e QA.

## Roadmap de entregas

### Fase 0 — Fechar a linha de base e o cânone

**Entrega:** backlog M30 aprovado, fonte de verdade alinhada e estimativa total rastreável.

- Revisar a Bíblia contra `zones.json`, `quest_states.json`, `encounter_tables.json`, `cg_variants.json` e o fluxo ativo.
- Associar a quest atual a um ID canônico ou substituí-la; preservar somente as mecânicas/assets que servirem ao arco aprovado.
- Registrar a decisão de combate por turnos e definir a lista oficial de regiões/zonas.
- Decompor o jogo completo em entregas estimáveis; contar progresso apenas quando código, conteúdo e integração forem aceitos.
- Corrigir os documentos de entrada e marcar cada status como `produzido`, `integrado`, `QA pendente` ou `aprovado`.

**Gate:** todo conteúdo M30 tem ID, pré-requisito, estado final, consequências, recursos associados e critério de aceite. O denominador do projeto foi estimado; ainda não declarar progresso de 30% antes desse gate.

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
- `01_ASSETS/kataklysma/maps/README.md`, catálogo de assets, `99_AUDIT/CG_VARIANT_ROSTER.md` e `VISUAL_IDENTITY_QA_V002.md`
