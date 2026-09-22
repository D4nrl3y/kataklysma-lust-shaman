# Kataklysma Production Asset Pack — FINAL v3.0

Pacote de produção organizado para o projeto **Lust Shaman's Journey**.

## Objetivo
Esta versão separa cada frame de animação em um arquivo PNG RGBA individual, mantendo o mesmo canvas por frame para evitar *jitter* de pivô durante animação no Godot.

## Estrutura principal
- `01_CHARACTER/` — renders, portraits e anatomia
- `02_SPRITES/` — Idle, Walk, Cast e Combat, **um PNG por frame**
- `03_EQUIPMENT/` — armas/equipamentos isolados
- `04_CG/` — key art, promo e material de narrativa
- `05_REFERENCE/` — referências originais
- `06_GODOT/` — helper e instruções de integração

## Sprites
Cada animação possui 4 frames individuais:
- Idle: `chr_kataklysma_spr_idle_f001_v001.png` ... `f004`
- Walk: `chr_kataklysma_spr_walk_f001_v001.png` ... `f004`
- Cast: `chr_kataklysma_spr_cast_f001_v001.png` ... `f004`
- Combat: `chr_kataklysma_spr_combat_f001_v001.png` ... `f004`

Todos preservam canvas de **543 × 362 px** e transparência alfa.

## Recomendação de animação
- Idle: 4 FPS / loop
- Walk: 8 FPS / loop
- Cast: 6 FPS / não-loop
- Combat: 10 FPS / não-loop

## Importante
Os arquivos em `01_CHARACTER/RENDERS` são renders 2D de referência/produção. O pacote **não contém malha 3D nativa, rig, FBX, OBJ ou arquivo .blend**.
