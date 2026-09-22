# Sprites in-game por atributo

Conjuntos completos da Kataklysma com cada atributo no máximo:

- `agility_max`
- `stamina_max`
- `intellect_max`
- `spirit_max`
- `lust_max`
- `corruption_max`

Cada conjunto contém:

- `IDLE`: 4 frames
- `WALK`: 4 frames
- `CAST`: 4 frames
- `COMBAT`: 4 frames de combate físico
- `SHEETS`: `idle_walk`, `cast_combat` e `all`

Os frames individuais usam canvas transparente de `543x362`, com o personagem alinhado pelo centro inferior. As sheets combinadas usam `2172x724`; a sheet completa usa `2172x1448`.

Na sheet `all`, as linhas seguem esta ordem: `IDLE`, `WALK`, `CAST`, `COMBAT`. As variações de energia e efeitos visuais representam o atributo no máximo sem alterar a identidade visual da personagem.
