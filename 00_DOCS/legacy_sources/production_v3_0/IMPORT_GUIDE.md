# Godot 4 — Importação dos Sprites

1. Copie a pasta `Kataklysma_Production_Asset_Pack_FINAL_v3.0` para dentro do projeto Godot.
2. Crie um `AnimatedSprite2D`.
3. Use o helper `kataklysma_spriteframes_setup.gd` ou crie um `SpriteFrames` manualmente.
4. Mantenha todos os frames com o canvas original de 543×362 px para preservar alinhamento.
5. Para pivô de personagem, use referência de **bottom-center**.

Animações sugeridas:
- `idle`: 4 FPS, loop
- `walk`: 8 FPS, loop
- `cast`: 6 FPS, sem loop
- `combat`: 10 FPS, sem loop
