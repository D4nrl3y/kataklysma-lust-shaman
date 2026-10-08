# Cobertura de assets da campanha M30

**Escopo:** Echo Isles `QST_ECHO_001`–`QST_ECHO_008`, transição e Sen’jin `QST_SEN_009`.

**Revisão:** inventário estático do repositório em 2026-10-07.

**Status:** arquivos inventariados; associação não significa integração nem aprovação visual.

## Legenda e conclusão

- **Integrado:** o runtime atual carrega o recurso no fluxo indicado.
- **Existe / candidato:** arquivo presente; precisa de inspeção, aprovação e ligação ao beat canônico.
- **Falta:** não foi encontrado asset dedicado no repositório.
- Arquivos `.import` do Godot são metadados de importação, não quadros de arte adicionais.

Echo Isles tem um background conceitual carregado pela cena principal e uma implementação de walkability em `demo_game.gd`; a geometria ainda não passou por QA visual. Sen’jin tem somente um background conceitual e ainda não tem cena jogável. Não existe pasta com assets de objetos estáticos; as mecânicas de captura, caça, ritual, depósito e embarque precisam de props independentes. As quests canônicas e diálogos ainda não são consumidos pelo runtime.

## Mapas e camadas

| Zona | Recurso existente | Runtime | Faltas para M30 |
|---|---|---|---|
| Echo Isles | `01_ASSETS/kataklysma/maps/echo_isles/backgrounds/echo_isles_background_concept_v001.png` | Background e lógica de movimento carregados por `03_GODOT/scripts/demo_game.gd`; não é uma cena modular de mapa | Aprovação final de walkability; camadas separadas, props/foreground, POIs e rotas/encounters ligados ao estado canônico das quests |
| Sen’jin Village | `01_ASSETS/kataklysma/maps/senjin_village/backgrounds/senjin_village_background_concept_v001.png` | Não integrado; `main.tscn` e demo continuam em Echo Isles | Cena jogável, colisões, foreground, POIs, spawn points, posicionamento/rotas de NPC e região/eventos |

Os outros backgrounds conceituais encontrados são Durotar, Razor Hill, Northern Barrens, Ratchet e o local especial Eye of the Storm Shrine. Orgrimmar não tem background. Esses locais estão fora do corte M30.

## Personagens e retratos

Os 13 NPCs nomeados têm pasta com quatro imagens `IDLE` e quatro `WALK`, além de render de referência. Nenhum dos 13 tem sequência `CAST` ou `COMBAT`. Para o corte, os personagens nomeados que aparecem no escopo incluem Zek’Ranu, Mok’Jala, Zal’Kiri, Mak’Jala, Rak’jin, Taz’Rima e Ruk’ka; os arquivos existem em `01_ASSETS/kataklysma/sprites/npcs/<id>/` e os renders em `01_ASSETS/kataklysma/character/npcs/renders/`. Exceto Zek’Ranu na demo atual, esses pacotes não são população integrada das quests canônicas.

Retratos busto encontrados: Kataklysma e Zek’Ranu. Os renders dos outros NPCs não contam como portraits finais para diálogo. Não foram encontrados sprites genéricos dedicados para crianças, aprendiz de Taz’Rima, responsável pelo depósito ou membros do conselho/vila. Para `QST_ECHO_008`, o usuário fixou Mak’Jala + Rak’jin como os dois NPCs prioritários da despedida.

## Entidades e combate

| Entidade | Arquivos encontrados | Adequação ao corte |
|---|---|---|
| `weakened_water_spirit` | render, identity lock, quatro `IDLE` e quatro `WALK` | Candidato para `QST_ECHO_005`; sem animação `COMBAT` |
| `corrupted_makrura` | render, identity lock, quatro `IDLE` e quatro `COMBAT` | Candidato direto ao boss de `QST_ECHO_006`; sem animação `WALK` |
| `eye_of_storm_avatar` | quatro `IDLE` e quatro `CAST` | Fora do corte M30; sem integração de campanha |
| Javali/boar de caça | Nenhum sprite de entidade correspondente | Falta para o ramo de caça/combate de `QST_ECHO_003` |
| Inimigo comum reutilizável | Nenhum conjunto `melee_chaser` encontrado | Falta para encontros comuns do corte; não substituir silenciosamente por Makrura ou espírito |

`spirit_elemental` aparece como necessidade no catálogo de zonas, mas não existe pasta de entidade com esse ID. O sistema de combate pode ser reutilizado, porém os atores e encontros devem respeitar os ramos e espécies definidos pela narrativa.

## Objetos e interação

`01_ASSETS/kataklysma/static_objects/` não contém arquivos. A necessidade mínima identificada pelos cartões M30 inclui:

- Cabana de Awakening: colar, tigela ritual, janela/reflexo e bolsa de moedas (quatro objetos opcionais examináveis).
- Ritual de `QST_ECHO_002`: quatro totens e elementos visuais de canalização/recusa.
- Caça de `QST_ECHO_003`: rastros, carne/loot, isca ou armadilha e evidência de excedente do outro caçador.
- `QST_ECHO_004`: sapos vivos/coletáveis, reagentes/cesto e estação/lab do antídoto.
- `QST_ECHO_005`–`006`: peixes mortos, amostra/resíduo da contaminação, poças condutivas, ovos e pedra ritual.
- `QST_ECHO_007`: totem comunitário quebrado/reparável e pistas em areia/cabanas.
- `QST_ECHO_008`: bagagem/cartas e embarcação/cais.
- `QST_SEN_009`: caixas de suprimentos/comida, depósito e props de investigação/conselho.

Esses itens exigem arte em arquivos separados quando forem interativos, bloqueáveis ou tiverem estados; o background conceitual não conta como substituto final desses recursos.

## CGs do catálogo

`03_GODOT/data/cg_variants.json` declara 12 sequências; a pasta `VARIANTS/` contém 48 PNGs, quatro por sequência. Elas são assets produzidos, não 48 cenas integradas. O runtime atual referencia uma sequência de quatro quadros (`echo_002_zekranu_totem_choice`) e a dispara no evento errado do protótipo de maré.

| Sequência | Quest M30 | Classificação de inventário |
|---|---|---|
| `echo_002_zekranu_totem_choice` | `QST_ECHO_002` | Candidata forte: cena de ritual/totem combina com o cartão; trigger atual incorreto |
| `echo_003_zalkiri_mokjala_hunt` | `QST_ECHO_003` | Candidata forte: personagens e caça combinam; falta confirmar beat e integrar |
| `echo_004_rakjin_rivalry` | Nenhuma associação canônica aprovada | Não usar em `QST_ECHO_004`: a quest canônica é sobre sapos/antídoto, não rivalidade com Rak’jin |
| `echo_005_water_spirit_choice` | `QST_ECHO_005` | Candidata forte: espírito/decisão de água combinam; falta confirmar beat e integrar |
| `echo_006_corrupted_makrura_boss` | `QST_ECHO_006` | Candidata forte: boss corresponde; falta confirmar continuidade/beat e integrar |
| `echo_008_makjala_vision` | Possível `QST_ECHO_008` | Incerta: o cartão atual descreve despedida/embarque, não identifica uma visão como beat |
| `senjin_007_tazrima_rukka_herbs` | Possível `QST_SEN_009` | Não associar ainda: título “herbs” não corresponde ao roubo de suprimentos; o catálogo usa índice que não é o ID canônico da quest |
| `echo_009_azkarra_storm_ritual` e sequências de Razor Hill, Barrens, Ratchet e End | Fora do corte | Assets preservados para quests/localizações posteriores |

“Candidata forte” significa somente que os personagens/tema se alinham ao cartão. A aprovação depende da inspeção dos quatro quadros contra a cena, do vínculo de trigger correto e do retorno de estado; nenhum candidato conta como CG integrada agora.

## Conteúdo narrativo e outros recursos

- O único JSON PT-BR de diálogo é `03_GODOT/data/dialogue/pt_BR/quest_01.json`, rotulado como protótipo e não consumido pelo runtime. Os diálogos completos e branch matrices das nove quests ainda precisam de dados/scripts canônicos em PT-BR.
- A música de campo de Echo Isles é um candidato com watermark e direitos não liberados. SFX finais de UI, quest e combate não foram encontrados.
- Fonte Inter/Cinzel, portrait atual de Zek’Ranu, portrait de Kataklysma, menu e sistemas gerais existentes são infraestrutura reutilizável, mas continuam sujeitos à QA do runtime indicada nos issues.

## Lacunas por quest

| Quest | Aproveitável do acervo | Lacunas principais / decisão pendente |
|---|---|---|
| `QST_ECHO_001` | Echo Isles runtime, Kataklysma e Zek’Ranu (sprites/retrato) | Quatro props examináveis; diálogo/flags canônicos |
| `QST_ECHO_002` | Zek’Ranu, CG ritual candidata | Totens/props; diálogo/ritual canônico; corrigir trigger da CG |
| `QST_ECHO_003` | Mok’Jala, Zal’Kiri, CG de caça candidata | Boar, armadilha/loot; retratos; combate alternativo; diálogo canônico |
| `QST_ECHO_004` | Taz’Rima | Aprendiz, sapos, reagentes/lab/minigame; retrato; CG adequada não identificada |
| `QST_ECHO_005` | Espírito da água, CG candidata | Props de investigação; retrato; integrar influência no boss e diálogo |
| `QST_ECHO_006` | Makrura e CG candidata | Props de arena/estados do boss; integrar combate por turnos e flags |
| `QST_ECHO_007` | Mak’Jala e Zal’Kiri | Sprites infantis, totem quebrado/pistas; retratos; diálogo canônico |
| `QST_ECHO_008` | Background Echo, sprites de Mak’Jala e Rak’jin, CG de visão incerta | Boat/cais e transição; mapa Sen’jin; CG não confirmada |
| `QST_SEN_009` | Background conceitual Sen’jin, Taz’Rima, Ruk’ka e CG de ervas incerta | Cena de mapa jogável; responsável pelo depósito/conselho/irmãos; caixas de comida; retratos; diálogo e resolução canônica |

## Fontes e regra de progresso

Inventário verificado contra `zones.json`, `cg_variants.json`, `M30_QUEST_ACCEPTANCE.md`, `ASSET_REQUIREMENTS.md`, especificação de mapas, pastas de NPCs/entidades/CGs e referências do `demo_game.gd`. Arquivo presente conta como produzido; só conta como integrado quando o runtime o usa no beat correto; só conta como aprovado após QA da build corrente.
