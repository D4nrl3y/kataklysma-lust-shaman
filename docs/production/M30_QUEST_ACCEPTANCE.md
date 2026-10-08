# Critérios de aceite das quests M30

**Escopo:** `QST_ECHO_001`–`QST_ECHO_008`, transição Echo Isles → Sen’jin e `QST_SEN_009`.

**Estado:** especificação de produção derivada da Bíblia; ainda não implementada nem aprovada por QA.

Este documento transforma os cartões e as branch matrices da Bíblia em critérios verificáveis para a campanha M30. Os nomes de cena e flags abaixo são canônicos; a presença de um arquivo de arte com nome parecido não prova que ele seja o recurso correto ou esteja integrado.

## Regras comuns de aceite

- A campanha segue a ordem do spine narrativo. Os cartões usam o pré-requisito genérico “Spine da campanha + flags contextuais”; dependências entre quest IDs devem ser confirmadas no grafo de quests durante a implementação. Nenhum check social pode encerrar a campanha: todas as quests têm fail-forward.
- O estado e o objetivo visível devem distinguir disponível, em progresso, pronta para entrega e entregue. Aceitar, avançar, resolver e entregar atualizam tracker e marcador imediatamente; entregar duas vezes não reaplica recompensas.
- Cada escolha grava sua flag antes da troca de cena. O delta aparece depois da ação/fala; relações de NPCs presentes mudam na mesma resolução narrativa. Flags, atributos, relações, reputações, itens e seed de eventos relevantes sobrevivem a save/load.
- Texto e interface desta entrega ficam em PT-BR. Toda cena retorna ao spine e ao controle do jogador sem perder o ramo escolhido.
- Cada linha de cena abaixo precisa de diálogo e lógica integrados, POIs/props e personagens necessários, estados de quest, recursos visuais adequados e tratamento de save/load. O inventário e o vínculo de arquivos concretos serão feitos na produção; os nomes de CG do catálogo não são associados automaticamente pelo número.
- QA por quest: save novo; caminho com atributos extremos; cada opção e resultado; atualização de flag/delta/relação; saída e retomada por save; retorno ao spine; ausência de bloqueio por check social. Escolhas irreversíveis devem salvar antes de devolver controle.

## Matriz de conteúdo e aceite

### `QST_ECHO_001` — Awakening

- **Pré-condição / resolução:** início de campanha nova; concluir ao sair da cabana e encontrar Zek’Ranu no círculo ritual. A escolha contextual ocorre antes da saída.
- **Cenas:** `SCN_ECHO_001_DREAM`, `SCN_ECHO_001_HUT` (quatro objetos opcionais), `SCN_ECHO_001_EXIT` (bark varia pela escolha).
- **Ramos exigidos:** colar e reverência → Espírito +1, `FLG_ECHO_001_REVERENCE`; estudar inscrições → Intelecto +1, entrada de lore, `FLG_ECHO_001_STUDIED`; guardar para vender → Corrupção +1, `FLG_ECHO_001_PRAGMATIC`; usar como espelho → Luxúria +1, variante de charme em Sen’jin, `FLG_ECHO_001_CONFIDENT`.
- **Aceite específico:** os quatro objetos são examináveis; a decisão e o delta são persistidos antes da saída; o bark de saída reflete o ramo; a variante de charme de `QST_SEN_009` consulta `FLG_ECHO_001_CONFIDENT`.

### `QST_ECHO_002` — The Voice of the Elements

- **Pré-condição / resolução:** spine de campanha; concluir o ritual de quatro totens e responder à pergunta de Zek’Ranu sobre como agir quando o elemento diz não.
- **Cenas:** `SCN_ECHO_002_CIRCLE`, `SCN_ECHO_002_REFUSAL`, `SCN_ECHO_002_DEBRIEF`.
- **Ramos exigidos:** esperar e escutar → Espírito +2, confiança elemental +5, confiança de Zek +8, `FLG_ZEK_APPROVES_PATIENCE`; corrigir o gesto → Intelecto +2, comentário técnico futuro, `FLG_ZEK_APPROVES_METHOD`; impor obediência → Corrupção +2, confiança elemental −5 e seed Dark Shaman, `FLG_FIRST_DOMINION`; responder com charme → Luxúria +1 / Espírito +1, afinidade +2 sem mudança de confiança, `FLG_ZEK_TEASED`.
- **Aceite específico:** cada totem tem sua microinteração; a recusa deliberada do totem do ar ocorre; o debrief e as relações correspondem à resposta escolhida.

### `QST_ECHO_003` — Fresh Meat

- **Pré-condição / resolução:** spine de campanha; entregar quatro porções de carne de javali ou concluir uma solução alternativa reconhecida por Mok’Jala.
- **Cenas:** `SCN_ECHO_003_TRACK`, `SCN_ECHO_003_ALTERNATIVE`, `SCN_ECHO_003_RETURN`.
- **Ramos exigidos:** caçar → Agilidade +1 / Estamina +1, afinidade de Mok +5, `FLG_ECHO_003_HUNTED`; estudar hábitos e preparar emboscada → Intelecto +2, componente extra e armadilhas contextuais, `FLG_ECHO_003_TRAPPED`; agradecimento ritual → Espírito +2, confiança elemental +3, evento animal futuro, `FLG_ECHO_003_RITE`; roubar excedente → Corrupção +2, preserva ouro e pode reduzir confiança de Zal’Kiri em 5, `FLG_ECHO_003_STOLE`.
- **Aceite específico:** caça, armadilha e alternativa de excedente completam a necessidade sem exigir combate em todos os ramos; Mok avalia método, não apenas inventário. O roubo não inicia combate.

### `QST_ECHO_004` — Frogs, Frogs Everywhere

- **Pré-condição / resolução:** spine de campanha; obter seis sapos vivos sem danificar o reagente e entregar/validar o resultado com Taz’Rima.
- **Cenas:** `SCN_ECHO_004_BEACH`, `SCN_ECHO_004_APPRENTICE`, `SCN_ECHO_004_LAB`.
- **Ramos exigidos:** captura pessoal → Agilidade +2, antídoto padrão e item extra, `FLG_ECHO_004_CAUGHT`; troca justa → Intelecto +1, reputação local +2, `FLG_ECHO_004_BARTER`; mentir que Taz’Rima pagou → Corrupção +2, dívida pública se não resolvida, `FLG_ECHO_004_LIED`; tentar charme → check Luxúria 15, receptividade baixa, sucesso parcial dá desconto mas nunca entrega tudo grátis, `FLG_ECHO_004_CHARM_ATTEMPT`.
- **Aceite específico:** minigame só registra sapos vivos; a qualidade/resultado do antídoto reflete o ramo; o check de charme não ignora o contexto nem bloqueia a conclusão.

### `QST_ECHO_005` — Something in the Water

- **Pré-condição / resolução:** spine de campanha; investigar peixes mortos e brilho anormal, identificar a origem e decidir como tratar o espírito enfraquecido.
- **Cenas:** `SCN_ECHO_005_SHORE`, `SCN_ECHO_005_SPIRIT`, `SCN_ECHO_005_TRACE`.
- **Ramos exigidos:** curar e pedir ajuda → Espírito +2, confiança elemental +8, Makrura começa com debuff, `FLG_WATER_SPIRIT_HELPED`; analisar energia → Intelecto +2, pista no journal e opção para desativar mecânica do boss, `FLG_CONTAMINATION_ANALYZED`; ordenar que revele a origem → Corrupção +2, confiança elemental −8 e seed Dark Shaman, `FLG_WATER_SPIRIT_FORCED`; prometer favor → Espírito +1 / Corrupção +1, dívida/evento futuro obrigatório, `FLG_SPIRIT_BARGAIN`.
- **Aceite específico:** evidências apontam para o covil; cada flag altera o encontro/estado previsto em `QST_ECHO_006`; o espírito mantém reação e relação coerentes com a escolha.

### `QST_ECHO_006` — Corrupted Makrura

- **Pré-condição / resolução:** chegar à arena após a investigação; derrotar ou neutralizar o Makrura e decidir o destino do fragmento do Eye.
- **Cenas:** `SCN_ECHO_006_ENTRY`, `SCN_ECHO_006_BOSS` (três fases), `SCN_ECHO_006_FRAGMENT`.
- **Ramos exigidos:** destruir → Espírito +3, confiança elemental +10, perde fragmento e ganha bênção, `FLG_FRAGMENT_DESTROYED`; estudar e selar → Intelecto +3, opção futura de Vexa, `FLG_FRAGMENT_STUDIED`; esconder → Corrupção +3, `FLG_FRAGMENT_HIDDEN`; entregar a Zek → Espírito +1 / confiança +8, cena de mentor e redução de World Tension, `FLG_FRAGMENT_GIVEN_ZEK`.
- **Aceite específico:** poças condutivas, ovos e pedra ritual participam das três fases tutoriais; ajuda/análise de `QST_ECHO_005` afeta o boss; vitória e neutralização chegam à mesma decisão pós-batalha sem apagar diferenças de estado; resultado persiste.

### `QST_ECHO_007` — The Stolen Totem

- **Pré-condição / resolução:** spine após o conflito do fragmento; descobrir o que houve com o totem comunitário e recuperar, reparar ou substituir a peça, decidindo como lidar com as crianças.
- **Cenas:** `SCN_ECHO_007_SEARCH`, `SCN_ECHO_007_CHILDREN`, `SCN_ECHO_007_REPAIR`.
- **Ramos exigidos:** proteger crianças e reparar → Espírito +2 / Intelecto +1, afinidade comunitária +5 sem Corrupção pela mentira protetiva, `FLG_CHILDREN_PROTECTED`; levá-las a confessar → Espírito +1 / Estamina +1, confiança de Mak’jala +5, `FLG_CHILDREN_CONFESSED`; chantagear → Corrupção +3, seed Underworld +1 e consequência de culpa/denúncia, `FLG_CHILDREN_BLACKMAILED`; inventar culpado externo → Corrupção +2, reputação preservada e confiança de Zal’Kiri −12, `FLG_FALSE_BLAME`.
- **Aceite específico:** investigação encontra pistas em areia/cabanas; confronto é não violento; resolução pública ou secreta restaura/substitui o totem e atualiza as relações observadoras.

### `QST_ECHO_008` — Beyond the Isles

- **Pré-condição / resolução:** concluir os incidentes prioritários de Echo Isles; escolher a despedida, falar com dois NPCs prioritários e embarcar para Sen’jin.
- **Cenas:** `SCN_ECHO_008_PACK`, `SCN_ECHO_008_FAREWELL`, `SCN_ECHO_008_BOAT`.
- **Ramos exigidos:** prometer voltar com honra → Espírito +2, reputação Darkspear +4 e sonho futuro de Mak’jala, `FLG_DEPARTURE_HONOR`; dizer que voltará mais poderosa → Estamina +1 / Agilidade +1, afinidade de Rak’jin +3, `FLG_DEPARTURE_AMBITION`; esconder medo com humor → Luxúria +1, afinidade geral +2, `FLG_DEPARTURE_CHARM`; partir sem revelar fragmento oculto → Corrupção +2, World Tension +3, `FLG_DEPARTURE_SECRET`.
- **Aceite específico:** inventário/cartas e despedidas não apagam flags anteriores; a embarcação persiste estado e posição segura; exibe transição de capítulo e carrega Sen’jin com as relações e o ramo de fragmento.

### `QST_SEN_009` — Missing Supplies

- **Pré-condição / resolução:** chegar a Sen’jin após `QST_ECHO_008`; investigar os roubos no depósito, descobrir que Ruk’ka leva comida aos irmãos menores e resolver o abastecimento da vila.
- **Cenas:** `SCN_SEN_009_DEPOT`, `SCN_SEN_009_RUKKA`, `SCN_SEN_009_COUNCIL`.
- **Ramos exigidos:** pagar a falta e proteger Ruk’ka → Espírito +2, confiança de Ruk’ka +20, ouro −20% e reputação +4, `FLG_RUKKA_PROTECTED`; criar trabalho pago → Intelecto +2, solução estável e Ruk’ka como NPC útil, `FLG_RUKKA_WORK`; torná-lo informante → Corrupção +2, Underworld Heat +2, informação futura, `FLG_RUKKA_INFORMANT`; usar charme no conselho → check Luxúria 30, desejo de NPC receptivo +5 e reputação social +3; em falha, o conselho nota a manipulação, `FLG_RUKKA_SOCIAL_SAVE`.
- **Aceite específico:** investigação revela motivo e consequências humanas; conselho respeita o resultado das opções; a decisão garante abastecimento; o arco pode ser salvo/carregado e termina com estado M30 concluído, sem exigir conteúdo de quests posteriores.

## Dependências de CG e recursos

O catálogo contém sequências com quatro quadros, mas a associação ao cartão narrativo precisa ser aprovada pelo evento de história, não inferida pelo nome. Exemplos de risco: `echo_004_rakjin_rivalry` não corresponde pelo título à quest de sapos `QST_ECHO_004`; `senjin_007_tazrima_rukka_herbs` não pode ser declarado automaticamente como a CG de `QST_SEN_009`. `echo_002_zekranu_totem_choice` é candidata ao ritual de `QST_ECHO_002`, mas a integração atual dispara a sequência após o protótipo de maré e está incorreta.

Para cada CG aprovada no corte, exigir quatro imagens na ordem início → desenvolvimento → clímax → resolução, continuidade de identidade, trigger ligado ao beat certo e retorno ao estado/quest correto. Sequências sem beat canônico dentro destas nove quests ficam fora do M30, mesmo que os arquivos já existam.

## Gate documental

Esta matriz fecha a definição inicial de conteúdo e de critérios por quest para planejamento. Ela não afirma implementação, cobertura total de assets, QA realizado nem 30% concluído. A estimativa de esforço permanece preliminar e deve ser calibrada na Fase 1; cada item de aceite só conta no progresso quando integrado e aprovado com evidência atual.
