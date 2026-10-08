# Estimativa inicial de esforço do M30

**Versão:** 0.2 — estimativa de planejamento revista pelo inventário, 2026-10-07

**Escopo aprovado:** do início em Echo Isles à conclusão de `QST_SEN_009` em Sen'jin Village.

**Unidade:** pontos relativos de esforço; não são horas, prazo ou percentual já concluído.

## Base de estimativa

O escopo total conhecido combina a Bíblia narrativa (15 quests principais e sete regiões), as mecânicas descritas e os pacotes de arte/áudio/catalogação presentes no repositório. As estimativas são por pacote integrado e aceito, não por quantidade de arquivos. A distribuição é uma primeira estimativa de produto, com baixa confiança; revisar após estabilizar a base Godot e medir o primeiro mapa completo.

Os pontos nesta versão são pesos relativos de planejamento, distribuídos por julgamento de escopo entre os pacotes listados; ainda não vêm de horas registradas, histórico de velocidade ou decomposição de tarefas executáveis. O backlog narrativo está em `M30_QUEST_ACCEPTANCE.md`, e a disponibilidade/falta de recursos por quest em `M30_ASSET_COVERAGE.md`. O inventário ampliou a faixa de incerteza, mas não fornece dados de produtividade para alterar o ponto central: 35/100 segue uma hipótese para ordenar o trabalho, não prova de que a campanha consome exatamente 35% do jogo.

| Pacote do jogo completo | Total | M30 | Incluído no M30 |
|---|---:|---:|---|
| Runtime compartilhado e fundação de produção | 22 | 9 | Movimento e colisão, interação, estados de quest, diálogo/escolhas, atributos e flags, save/load, menu e fluxo base |
| Narrativa e quests principais | 24 | 10 | `QST_ECHO_001`–`QST_ECHO_008` e `QST_SEN_009`; as seis quests seguintes e seus ramos ficam fora |
| Regiões, mapas, viagem e pontos de interesse | 18 | 5 | Echo Isles e Sen'jin, incluindo transição, walkability, POIs e spawn/event regions necessários |
| NPCs, inimigos, objetos e integração de arte | 14 | 4 | Elenco, inimigos, objetos e CGs requeridos pelas duas regiões; restante do roster fica fora |
| Combate por turnos e progressão | 10 | 3 | Loop de batalha, ações e inimigos do arco inicial, incluindo o boss Makrura; formações e balanceamento do jogo completo ficam fora |
| Interface, áudio e localização | 7 | 2 | UI PT-BR e configuração necessária à build; áudio distribuível precisa de direitos claros |
| QA, exportação e documentação de entrega | 5 | 2 | QA do caminho M30, build exportada, relatório e evidências atuais |
| **Total** | **100** | **35** | **M30 preliminar: aproximadamente 35% do esforço planejado** |

## Interpretação

A estimativa pontual situa o corte escolhido em aproximadamente **35%**. A faixa atual de incerteza é **30%–45%**; o inventário encontrou lacunas relevantes de props, atores genéricos, retratos, inimigos e mapa Sen’jin, por isso a faixa foi ampliada. Isso continua sendo julgamento de planejamento, não medida empírica de esforço. As nove quests não recebem peso igual: quests posteriores incluem regiões adicionais, relações de longo prazo, eventos condicionais e múltiplas resoluções; por isso a contagem 9/15 não é usada diretamente como percentual de esforço.

Esta estimativa não declara que 35% já foi produzido. O progresso concluído permanece **não calculado** até cada item ter critério de aceite, integração e QA no commit correspondente. Assets pré-produzidos só entram no progresso quando a parte definida do backlog estiver integrada e aprovada.

## Itens deliberadamente adiados

- `QST_DUR_010`–`QST_END_015`, regiões após Sen'jin, ramificações finais e epílogos.
- Sistemas gerais de inventário/equipamento/crafting, formações avançadas, reputação ampla e rotinas completas de NPCs.
- Arte e integração dos NPCs, monstros, objetos e CGs fora das duas regiões M30.
- Distribuição pública enquanto qualquer P0 estiver aberto ou direitos de áudio não estiverem liberados.

## Reestimativa

Reestimar os pacotes após fechar a fundação técnica da Fase 1, construir o mapa de Sen’jin e medir uma quest canônica de ponta a ponta. Se o intervalo mudar, registrar uma nova versão; não alterar pontos retroativamente para manter o rótulo M30.
