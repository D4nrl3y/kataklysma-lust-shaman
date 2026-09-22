# Godot 4 — Kataklysma

1. Copie `01_ASSETS/` e `03_GODOT/` para o projeto Godot.
2. Confirme que os sprites estão em `res://01_ASSETS/kataklysma/`.
3. Para a protagonista, use `KataklysmaSpriteLibrary.build()`.
4. Para NPCs nomeados, use `KataklysmaSpriteLibrary.build_npc("zekranu")` ou o ID correspondente.
5. Para entidades, use `KataklysmaSpriteLibrary.build_entity("corrupted_makrura", "COMBAT")`.
6. Crie mapas usando as camadas descritas em `MAP_PRODUCTION_SPEC_V001.md`.
7. Use `KataklysmaQuestMarker` para os três estados visuais de quest e `KataklysmaInteractionMarker` para pontos interativos.
8. Instancie `KataklysmaRandomEncounterManager` em cada mapa que possuir encontros aleatórios.
9. Mantenha o canvas de 543×362 px e o pivô em bottom-center para preservar o alinhamento.

Os frames da pasta principal vêm da versão `v3.2 SPRITEFIX`, que corrige os recortes da versão anterior.

Os dados de zonas, quests, encontros e variações de CG ficam em `03_GODOT/data/`.
