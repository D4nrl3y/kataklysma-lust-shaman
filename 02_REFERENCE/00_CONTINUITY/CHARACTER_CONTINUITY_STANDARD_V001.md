# Character Continuity Standard — v001

Este documento é o contrato visual do projeto. Ele vale para renders, retratos,
CGs, sprites, cut-ins, mapas com NPCs e materiais promocionais.

## Regra de aprovação

Uma arte só entra em `01_ASSETS` como produção quando preserva a ficha visual
canônica do personagem, a silhueta, a paleta, os acessórios-chave e a anatomia.
Imagens antigas que não passam nessa checagem continuam versionadas, mas são
tratadas como `legacy` ou `reference_seed`, nunca como fonte de continuidade.

## Kataklysma — lock obrigatório

- Pele azul-lavanda; olhos âmbar/dourados.
- Cabelo loiro/platinado em rabo de cavalo alto.
- Orelhas longas e pontudas com argolas; pequenas presas inferiores.
- Anatomia troll: uma mão com polegar e dois dedos; pés com dois dedos.
- Silhueta atlética, musculosa e curvilínea.
- Roupa-base de couro, penas, contas e elementos ósseos; cajado xamânico.
- Paleta-base: lavanda, marrom couro, vermelho queimado, dourado, turquesa.
- Corrupção pode alterar olhos, veias, aura e tatuagem, mas não pode trocar o
  rosto, penteado, proporções ou silhueta sem uma decisão narrativa registrada.

Referências canônicas:

- `02_REFERENCE/01_CANON/kataklysma_character_bible.png`
- `02_REFERENCE/02_TURNAROUND/kataklysma_turnaround_full.png`
- `02_REFERENCE/03_FACE/kataklysma_face_closeup.png`
- `02_REFERENCE/07_PALETTE/kataklysma_palette.png`
- `02_REFERENCE/08_SPRITE_REFERENCE/kataklysma_sprites_sheet.png`

## NPCs e entidades

Cada personagem deve possuir uma referência bloqueada antes de entrar em uma
CG continuada. O render neutro atual é apenas a semente visual inicial; ainda
é necessário completar turnaround, expressões, proporções de sprite e ficha
de acessórios antes de considerar o NPC “production locked”.

O inventário e o estado de cada personagem estão em
`character_continuity_manifest.json`.

## Regras de produção de CG

1. Cada cena narrativa possui quatro quadros obrigatórios: `start`,
   `development`, `climax` e `resolution`.
2. Os quatro quadros usam os mesmos locks de personagem, lente/composição,
   cenário e direção de arte. A iluminação e a ação podem evoluir.
3. Não é permitido completar uma sequência copiando ou renomeando o mesmo
   PNG. Cada arquivo deve ser uma imagem distinta e revisada.
4. O espaço inferior deve permanecer utilizável para a caixa de diálogo do
   jogo.
5. O arquivo original de uma CG antiga não é automaticamente uma continuação;
   ele fica em `legacy_keyframes` até ser substituído por uma sequência aprovada.

## Portão de qualidade

Antes de integrar no Godot, verificar:

- identidade facial e cabelo;
- cor de pele e silhueta;
- mãos, pés, orelhas e presas quando visíveis;
- acessórios e arma corretos;
- escala e posição coerentes entre quadros;
- ausência de texto, marca-d'água, membros duplicados ou anatomia quebrada;
- existência dos quatro arquivos no manifesto da cena.

