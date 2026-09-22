extends Node2D

const CombatSystem = preload("res://03_GODOT/scripts/combat_system.gd")

## First playable vertical slice for Kataklysma: Lust: Shaman's Journey.
## This scene intentionally keeps the combat layer lightweight while exercising
## the real project data, map art, identity-locked sprites and quest markers.

const VIEW_SIZE := Vector2(1280.0, 720.0)
const ZONE_ID := "echo_isles"
const MAP_TEXTURE := "res://01_ASSETS/kataklysma/maps/echo_isles/backgrounds/echo_isles_background_concept_v001.png"
const PLAYER_IDLE_DIR := "res://01_ASSETS/kataklysma/sprites/idle"
const PLAYER_WALK_DIR := "res://01_ASSETS/kataklysma/sprites/walk"
const NPC_ID := "zekranu"
const NPC_IDLE_DIR := "res://01_ASSETS/kataklysma/sprites/npcs/zekranu/IDLE"
const NPC_WALK_DIR := "res://01_ASSETS/kataklysma/sprites/npcs/zekranu/WALK"
const ENTITY_IDLE_DIR := "res://01_ASSETS/kataklysma/character/entities/sprites/corrupted_makrura/IDLE"
const ENTITY_COMBAT_DIR := "res://01_ASSETS/kataklysma/character/entities/sprites/corrupted_makrura/COMBAT"
const QUEST_MARKERS := {
    "available": "res://01_ASSETS/kataklysma/ui/markers/quest_available.svg",
    "in_progress": "res://01_ASSETS/kataklysma/ui/markers/quest_in_progress.svg",
    "complete": "res://01_ASSETS/kataklysma/ui/markers/quest_complete.svg",
}

var player: AnimatedSprite2D
var npc: AnimatedSprite2D
var quest_marker: Sprite2D
var objective_marker: Label
var player_name: Label
var npc_name: Label
var quest_state_label: Label
var toast_label: Label
var dialogue_panel: ColorRect
var dialogue_title: Label
var dialogue_body: Label
var dialogue_hint: Label
var encounter_panel: ColorRect
var encounter_body: Label
var encounter_hint: Label
var encounter_manager: Node
var combat_system: RefCounted
var combat_player_sprite: AnimatedSprite2D
var combat_enemy_sprite: AnimatedSprite2D
var combat_player_bar: ProgressBar
var combat_enemy_bar: ProgressBar
var combat_player_spirit_bar: ProgressBar
var combat_turn_label: Label
var combat_log_label: Label
var combat_action_label: Label

var quest_state := "available"
var objective_complete := false
var quest_turned_in := false
var dialogue_action := ""
var encounter_active := false
var encounter_choice_made := false
var last_position := Vector2.ZERO
var step_distance := 0.0
var toast_time := 0.0
var marker_time := 0.0

const PLAYER_START := Vector2(410.0, 450.0)
const NPC_POSITION := Vector2(830.0, 365.0)
const OBJECTIVE_POSITION := Vector2(1030.0, 505.0)
const MOVE_SPEED := 190.0

func _ready() -> void:
    _build_world()
    _build_hud()
    _build_encounter_manager()
    _set_quest_state("available")
    _show_toast("Echo Isles • Vertical Slice carregada", 4.0)

func _build_world() -> void:
    var background := Sprite2D.new()
    background.name = "EchoIslesBackground"
    background.texture = load(MAP_TEXTURE)
    background.position = VIEW_SIZE * 0.5
    if background.texture:
        background.scale = Vector2(VIEW_SIZE.x / background.texture.get_width(), VIEW_SIZE.y / background.texture.get_height())
    background.z_index = -20
    add_child(background)

    var tint := ColorRect.new()
    tint.name = "WorldReadabilityTint"
    tint.color = Color(0.04, 0.02, 0.08, 0.22)
    tint.position = Vector2.ZERO
    tint.size = VIEW_SIZE
    tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    tint.z_index = -19
    add_child(tint)

    player = _make_actor("Kataklysma", PLAYER_IDLE_DIR, PLAYER_WALK_DIR, "kataklysma")
    player.position = PLAYER_START
    player.scale = Vector2(0.52, 0.52)
    player.z_index = 5
    add_child(player)
    player.play("idle")
    last_position = player.position

    npc = _make_actor("Zekranu", NPC_IDLE_DIR, NPC_WALK_DIR, "npc_%s" % NPC_ID)
    npc.position = NPC_POSITION
    npc.scale = Vector2(0.52, 0.52)
    npc.z_index = 5
    add_child(npc)
    npc.play("idle")

    quest_marker = Sprite2D.new()
    quest_marker.name = "QuestMarker_Zekranu"
    quest_marker.position = NPC_POSITION + Vector2(0.0, -142.0)
    quest_marker.scale = Vector2(0.62, 0.62)
    quest_marker.z_index = 12
    add_child(quest_marker)

    npc_name = _make_world_label("ZEKRANU", NPC_POSITION + Vector2(-70.0, 112.0), 16, Color("#ffe7a6"))
    add_child(npc_name)
    player_name = _make_world_label("KATAKLYSMA", PLAYER_START + Vector2(-82.0, 112.0), 14, Color("#d9f1ff"))
    add_child(player_name)

    objective_marker = _make_world_label("◈  MARÉ CORROMPIDA\n    objetivo da quest", OBJECTIVE_POSITION + Vector2(-90.0, -18.0), 14, Color("#91d7ff"))
    objective_marker.visible = false
    add_child(objective_marker)

    var camp_label := _make_world_label("△  TOTEM DE TREINO", Vector2(485.0, 285.0), 13, Color(1.0, 0.91, 0.60, 0.82))
    add_child(camp_label)

func _make_actor(actor_name: String, idle_dir: String, walk_dir: String, file_prefix: String) -> AnimatedSprite2D:
    var actor := AnimatedSprite2D.new()
    actor.name = actor_name
    var frames := SpriteFrames.new()
    if frames.has_animation("default"):
        frames.remove_animation("default")
    _add_frames(frames, "idle", idle_dir, "%s_idle" % file_prefix, 4, 4.0, true)
    _add_frames(frames, "walk", walk_dir, "%s_walk" % file_prefix, 4, 8.0, true)
    actor.sprite_frames = frames
    actor.animation = &"idle"
    actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    return actor

func _add_frames(frames: SpriteFrames, animation_name: String, directory: String, prefix: String, count: int, fps: float, looped: bool) -> void:
    frames.add_animation(animation_name)
    frames.set_animation_speed(animation_name, fps)
    frames.set_animation_loop(animation_name, looped)
    for index in range(1, count + 1):
        var texture: Texture2D = load("%s/%s_%03d.png" % [directory, prefix, index])
        if texture:
            frames.add_frame(animation_name, texture)

func _build_hud() -> void:
    var hud := CanvasLayer.new()
    hud.name = "DemoHUD"
    add_child(hud)

    var top_bar := ColorRect.new()
    top_bar.color = Color(0.035, 0.02, 0.08, 0.86)
    top_bar.position = Vector2(20.0, 18.0)
    top_bar.size = Vector2(580.0, 92.0)
    top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(top_bar)

    var title := Label.new()
    title.position = Vector2(22.0, 12.0)
    title.text = "KATAKLYSMA  //  ECHO ISLES"
    title.add_theme_font_size_override("font_size", 22)
    title.add_theme_color_override("font_color", Color("#ffe7a6"))
    top_bar.add_child(title)

    quest_state_label = Label.new()
    quest_state_label.position = Vector2(22.0, 50.0)
    quest_state_label.add_theme_font_size_override("font_size", 16)
    top_bar.add_child(quest_state_label)

    var controls := Label.new()
    controls.position = Vector2(20.0, 650.0)
    controls.text = "WASD / setas: mover   •   E / Espaço: interagir   •   F: encontro   •   R: reiniciar"
    controls.add_theme_font_size_override("font_size", 15)
    controls.add_theme_color_override("font_color", Color(1.0, 0.96, 0.86, 0.92))
    hud.add_child(controls)

    toast_label = Label.new()
    toast_label.position = Vector2(20.0, 610.0)
    toast_label.size = Vector2(800.0, 32.0)
    toast_label.add_theme_font_size_override("font_size", 17)
    toast_label.add_theme_color_override("font_color", Color("#d5f4ff"))
    hud.add_child(toast_label)

    dialogue_panel = ColorRect.new()
    dialogue_panel.position = Vector2(170.0, 500.0)
    dialogue_panel.size = Vector2(940.0, 130.0)
    dialogue_panel.color = Color(0.035, 0.025, 0.08, 0.94)
    dialogue_panel.visible = false
    hud.add_child(dialogue_panel)

    dialogue_title = Label.new()
    dialogue_title.position = Vector2(24.0, 16.0)
    dialogue_title.add_theme_font_size_override("font_size", 21)
    dialogue_title.add_theme_color_override("font_color", Color("#ffe7a6"))
    dialogue_panel.add_child(dialogue_title)

    dialogue_body = Label.new()
    dialogue_body.position = Vector2(24.0, 49.0)
    dialogue_body.size = Vector2(880.0, 44.0)
    dialogue_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_body.add_theme_font_size_override("font_size", 17)
    dialogue_panel.add_child(dialogue_body)

    dialogue_hint = Label.new()
    dialogue_hint.position = Vector2(24.0, 100.0)
    dialogue_hint.text = "E / Espaço  confirmar"
    dialogue_hint.add_theme_font_size_override("font_size", 14)
    dialogue_hint.add_theme_color_override("font_color", Color("#91d7ff"))
    dialogue_panel.add_child(dialogue_hint)

    encounter_panel = ColorRect.new()
    encounter_panel.position = Vector2(145.0, 90.0)
    encounter_panel.size = Vector2(990.0, 560.0)
    encounter_panel.color = Color(0.08, 0.025, 0.07, 0.97)
    encounter_panel.visible = false
    hud.add_child(encounter_panel)

    var encounter_title := Label.new()
    encounter_title.position = Vector2(30.0, 18.0)
    encounter_title.text = "ENCONTRO ALEATÓRIO  //  COMBATE POR TURNOS"
    encounter_title.add_theme_font_size_override("font_size", 22)
    encounter_title.add_theme_color_override("font_color", Color("#ffb4c4"))
    encounter_panel.add_child(encounter_title)

    combat_turn_label = Label.new()
    combat_turn_label.position = Vector2(690.0, 20.0)
    combat_turn_label.size = Vector2(260.0, 30.0)
    combat_turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    combat_turn_label.add_theme_font_size_override("font_size", 18)
    combat_turn_label.add_theme_color_override("font_color", Color("#a9f4b0"))
    encounter_panel.add_child(combat_turn_label)

    encounter_body = Label.new()
    encounter_body.position = Vector2(30.0, 58.0)
    encounter_body.size = Vector2(930.0, 65.0)
    encounter_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    encounter_body.add_theme_font_size_override("font_size", 17)
    encounter_panel.add_child(encounter_body)

    combat_player_sprite = AnimatedSprite2D.new()
    combat_player_sprite.name = "CombatPlayerSprite"
    combat_player_sprite.sprite_frames = player.sprite_frames
    combat_player_sprite.animation = &"idle"
    combat_player_sprite.position = Vector2(190.0, 205.0)
    combat_player_sprite.scale = Vector2(0.42, 0.42)
    combat_player_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    encounter_panel.add_child(combat_player_sprite)

    combat_enemy_sprite = _make_entity_actor()
    combat_enemy_sprite.name = "CombatEnemySprite"
    combat_enemy_sprite.position = Vector2(780.0, 205.0)
    combat_enemy_sprite.scale = Vector2(0.42, 0.42)
    combat_enemy_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    encounter_panel.add_child(combat_enemy_sprite)

    var player_label := Label.new()
    player_label.position = Vector2(30.0, 235.0)
    player_label.text = "KATAKLYSMA"
    player_label.add_theme_font_size_override("font_size", 16)
    player_label.add_theme_color_override("font_color", Color("#d9f1ff"))
    encounter_panel.add_child(player_label)

    var enemy_label := Label.new()
    enemy_label.position = Vector2(590.0, 235.0)
    enemy_label.text = "MAKRURA CORROMPIDA"
    enemy_label.add_theme_font_size_override("font_size", 16)
    enemy_label.add_theme_color_override("font_color", Color("#ffb4c4"))
    encounter_panel.add_child(enemy_label)

    combat_player_bar = _make_combat_bar(Vector2(30.0, 265.0), Color("#54c7a2"))
    encounter_panel.add_child(combat_player_bar)
    combat_player_spirit_bar = _make_combat_bar(Vector2(30.0, 293.0), Color("#6fa9ff"))
    encounter_panel.add_child(combat_player_spirit_bar)
    combat_enemy_bar = _make_combat_bar(Vector2(590.0, 265.0), Color("#e26b77"))
    encounter_panel.add_child(combat_enemy_bar)

    combat_action_label = Label.new()
    combat_action_label.position = Vector2(30.0, 325.0)
    combat_action_label.size = Vector2(930.0, 30.0)
    combat_action_label.add_theme_font_size_override("font_size", 16)
    combat_action_label.add_theme_color_override("font_color", Color("#ffe7a6"))
    encounter_panel.add_child(combat_action_label)

    combat_log_label = Label.new()
    combat_log_label.position = Vector2(30.0, 360.0)
    combat_log_label.size = Vector2(930.0, 78.0)
    combat_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    combat_log_label.add_theme_font_size_override("font_size", 15)
    combat_log_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.86, 0.9))
    encounter_panel.add_child(combat_log_label)

    encounter_hint = Label.new()
    encounter_hint.position = Vector2(30.0, 485.0)
    encounter_hint.size = Vector2(930.0, 48.0)
    encounter_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    encounter_hint.add_theme_font_size_override("font_size", 15)
    encounter_hint.add_theme_color_override("font_color", Color("#91d7ff"))
    encounter_panel.add_child(encounter_hint)

func _make_combat_bar(bar_position: Vector2, fill_color: Color) -> ProgressBar:
    var bar := ProgressBar.new()
    bar.position = bar_position
    bar.size = Vector2(350.0, 18.0)
    bar.min_value = 0.0
    bar.max_value = 100.0
    bar.value = 100.0
    bar.show_percentage = false
    var background := StyleBoxFlat.new()
    background.bg_color = Color(0.02, 0.015, 0.04, 0.9)
    background.corner_radius_top_left = 4
    background.corner_radius_top_right = 4
    background.corner_radius_bottom_left = 4
    background.corner_radius_bottom_right = 4
    var fill := StyleBoxFlat.new()
    fill.bg_color = fill_color
    fill.corner_radius_top_left = 4
    fill.corner_radius_top_right = 4
    fill.corner_radius_bottom_left = 4
    fill.corner_radius_bottom_right = 4
    bar.add_theme_stylebox_override("background", background)
    bar.add_theme_stylebox_override("fill", fill)
    return bar

func _make_entity_actor() -> AnimatedSprite2D:
    var actor := AnimatedSprite2D.new()
    var frames := SpriteFrames.new()
    if frames.has_animation("default"):
        frames.remove_animation("default")
    _add_frames(frames, "idle", ENTITY_IDLE_DIR, "entity_corrupted_makrura_idle", 4, 4.0, true)
    _add_frames(frames, "combat", ENTITY_COMBAT_DIR, "entity_corrupted_makrura_combat", 4, 8.0, true)
    actor.sprite_frames = frames
    actor.animation = &"idle"
    return actor

func _build_encounter_manager() -> void:
    encounter_manager = KataklysmaRandomEncounterManager.new()
    encounter_manager.name = "RandomEncounterManager"
    encounter_manager.cooldown_seconds = 4.0
    encounter_manager.minimum_steps_between_events = 8
    add_child(encounter_manager)
    encounter_manager.encounter_triggered.connect(_on_encounter_triggered)

func _process(delta: float) -> void:
    marker_time += delta
    if quest_marker and quest_marker.visible:
        quest_marker.position.y = NPC_POSITION.y - 142.0 + sin(marker_time * 3.0) * 5.0
    if toast_time > 0.0:
        toast_time -= delta
        if toast_time <= 0.0:
            toast_label.text = ""
    if dialogue_panel.visible or encounter_active:
        if player:
            player.play("idle")
        return
    _move_player(delta)

func _move_player(delta: float) -> void:
    var direction := Vector2.ZERO
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        direction.x -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        direction.x += 1.0
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        direction.y -= 1.0
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        direction.y += 1.0
    if direction == Vector2.ZERO:
        player.play("idle")
        return
    direction = direction.normalized()
    player.position += direction * MOVE_SPEED * delta
    player.position.x = clampf(player.position.x, 90.0, VIEW_SIZE.x - 90.0)
    player.position.y = clampf(player.position.y, 165.0, VIEW_SIZE.y - 115.0)
    player.flip_h = direction.x < 0.0
    player.play("walk")
    step_distance += player.position.distance_to(last_position)
    last_position = player.position
    if step_distance >= 52.0:
        step_distance = 0.0
        encounter_manager.register_step()
        encounter_manager.try_roll(ZONE_ID, false)

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    var key_event := event as InputEventKey
    if encounter_active:
        _handle_encounter_input(key_event.keycode)
        return
    if dialogue_panel.visible:
        if key_event.keycode in [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
            _confirm_dialogue()
        return
    if key_event.keycode == KEY_R:
        _reset_demo()
    elif key_event.keycode == KEY_F:
        _start_encounter({"type": "monster_ambush", "actors": ["makrura_corrupted"], "manual": true})
    elif key_event.keycode in [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
        _try_interact()

func _try_interact() -> void:
    if player.position.distance_to(NPC_POSITION) < 145.0:
        _interact_with_npc()
    elif quest_state == "in_progress" and player.position.distance_to(OBJECTIVE_POSITION) < 145.0:
        _interact_with_objective()
    else:
        _show_toast("Nenhum ponto de interação próximo.", 2.0)

func _interact_with_npc() -> void:
    if quest_state == "available":
        _show_dialogue("Zekranu", "A maré trouxe uma corrupção até a poça ancestral. Investigue o brilho azul e volte para mim.", "accept_quest")
    elif quest_state == "in_progress":
        _show_dialogue("Zekranu", "A poça fica ao leste, perto das pedras. Procure o marcador ◈ e não toque na água escura.", "close")
    elif quest_state == "complete":
        _show_dialogue("Zekranu", "Você estabilizou a maré. O espírito agora pode respirar novamente. A missão está completa.", "turn_in_quest")
    else:
        _show_dialogue("Zekranu", "O caminho foi aberto. Esta vertical slice termina aqui — o próximo passo é conectar a próxima zona.", "close")

func _interact_with_objective() -> void:
    if quest_state != "in_progress":
        return
    _show_dialogue("Maré corrompida", "O símbolo reage à sua presença. Você canaliza o fluxo e purifica a água.", "complete_quest")

func _show_dialogue(title_text: String, body_text: String, action: String) -> void:
    dialogue_action = action
    dialogue_title.text = title_text
    dialogue_body.text = body_text
    dialogue_panel.visible = true

func _confirm_dialogue() -> void:
    dialogue_panel.visible = false
    match dialogue_action:
        "accept_quest":
            _set_quest_state("in_progress")
            _show_toast("Quest aceita: Purificar a Maré Corrompida", 3.0)
        "complete_quest":
            objective_complete = true
            _set_quest_state("complete")
            _show_toast("Objetivo completo. Volte ao Zekranu para entregar.", 3.0)
        "turn_in_quest":
            quest_turned_in = true
            _set_quest_state("turned_in")
            _show_toast("Quest entregue. Demo principal concluída!", 5.0)
        _:
            pass
    dialogue_action = ""

func _set_quest_state(new_state: String) -> void:
    quest_state = new_state
    objective_marker.visible = quest_state == "in_progress"
    quest_marker.visible = quest_state != "turned_in"
    if quest_state == "turned_in":
        quest_state_label.text = "QUEST  ✓  entregue • exploração liberada"
        quest_state_label.add_theme_color_override("font_color", Color("#a9f4b0"))
        return
    var marker_texture_path: String = QUEST_MARKERS.get(quest_state, QUEST_MARKERS["available"])
    quest_marker.texture = load(marker_texture_path)
    match quest_state:
        "available":
            quest_state_label.text = "QUEST  !  Purificar a Maré Corrompida • disponível"
            quest_state_label.add_theme_color_override("font_color", Color("#f6d365"))
        "in_progress":
            quest_state_label.text = "QUEST  ◌  Purificar a Maré Corrompida • em progresso"
            quest_state_label.add_theme_color_override("font_color", Color("#72b7ff"))
        "complete":
            quest_state_label.text = "QUEST  ✓  Purificar a Maré Corrompida • pronta para entrega"
            quest_state_label.add_theme_color_override("font_color", Color("#8be28b"))

func _on_encounter_triggered(_zone_id: String, encounter: Dictionary) -> void:
    _start_encounter(encounter)

func _start_encounter(encounter: Dictionary) -> void:
    encounter_active = true
    encounter_choice_made = false
    var event_type: String = str(encounter.get("type", "monster_ambush")).replace("_", " ").capitalize()
    var actors: Array = encounter.get("actors", ["makrura_corrupted"])
    var enemy_id: String = "water_spirit_weakened" if actors.has("water_spirit_weakened") else "corrupted_makrura"
    combat_system = CombatSystem.new()
    var snapshot: Dictionary = combat_system.start_battle(enemy_id)
    encounter_body.text = "Um evento surgiu durante a exploração.  Tipo: %s\nAmeaça: %s" % [event_type, str(snapshot["enemy"]["display_name"])]
    encounter_hint.text = "1 Ataque físico   2 Canalizar espírito   3 Guarda   4 Purificar   5 Fugir"
    combat_player_sprite.visible = true
    combat_enemy_sprite.visible = true
    combat_player_sprite.play("idle")
    combat_enemy_sprite.play("idle")
    _refresh_combat_ui(snapshot)
    encounter_panel.visible = true

func _handle_encounter_input(keycode: Key) -> void:
    if encounter_choice_made and keycode in [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE]:
        var result: String = combat_system.battle_result if combat_system else ""
        encounter_panel.visible = false
        encounter_active = false
        combat_player_sprite.visible = false
        combat_enemy_sprite.visible = false
        if result == "victory":
            _show_toast("Vitória! A ameaça foi derrotada.", 3.0)
        elif result == "defeat":
            _show_toast("Derrota. Pressione R para reiniciar a demo.", 4.0)
        else:
            _show_toast("Encontro encerrado. A exploração continua.", 3.0)
        return

    var action: String = ""
    match keycode:
        KEY_1:
            action = "strike"
        KEY_2:
            action = "channel"
        KEY_3:
            action = "guard"
        KEY_4:
            action = "purify"
        KEY_5, KEY_ESCAPE:
            action = "flee"
        _:
            return
    var snapshot: Dictionary = combat_system.perform_action(action)
    _refresh_combat_ui(snapshot)
    var phase: String = str(snapshot.get("phase", "player_turn"))
    if phase in ["victory", "defeat", "fled"]:
        encounter_choice_made = true
        encounter_hint.text = "Combate encerrado — E / Espaço para voltar ao mapa"

func _refresh_combat_ui(snapshot: Dictionary) -> void:
    var player_stats: Dictionary = snapshot.get("player", {})
    var enemy_stats: Dictionary = snapshot.get("enemy", {})
    combat_player_bar.max_value = float(player_stats.get("max_hp", 1))
    combat_player_bar.value = float(player_stats.get("hp", 0))
    combat_player_spirit_bar.max_value = float(player_stats.get("max_spirit", 1))
    combat_player_spirit_bar.value = float(player_stats.get("spirit", 0))
    combat_enemy_bar.max_value = float(enemy_stats.get("max_hp", 1))
    combat_enemy_bar.value = float(enemy_stats.get("hp", 0))
    var event_lines: Array = snapshot.get("events", [])
    combat_log_label.text = "\n".join(event_lines)
    var phase: String = str(snapshot.get("phase", "player_turn"))
    if phase == "player_turn":
        combat_turn_label.text = "SUA VEZ  •  Round %d" % int(snapshot.get("round", 1))
        combat_action_label.text = "[1] Ataque  [2] Canalizar  [3] Guarda  [4] Purificar  [5] Fugir"
    elif phase == "enemy_turn":
        combat_turn_label.text = "TURNO INIMIGO"
        combat_action_label.text = "A criatura está agindo..."
    else:
        combat_turn_label.text = str(phase).to_upper()
        combat_action_label.text = "Resultado: %s" % str(snapshot.get("result", ""))
    encounter_body.text = "%s\nHP %d/%d   •   Espírito %d/%d   •   Corrupção %d\nInimigo: HP %d/%d   •   Corrupção %d" % [
        str(enemy_stats.get("display_name", "Ameaça")),
        int(player_stats.get("hp", 0)), int(player_stats.get("max_hp", 1)),
        int(player_stats.get("spirit", 0)), int(player_stats.get("max_spirit", 1)), int(player_stats.get("corruption", 0)),
        int(enemy_stats.get("hp", 0)), int(enemy_stats.get("max_hp", 1)), int(enemy_stats.get("corruption", 0)),
    ]

func _reset_demo() -> void:
    quest_state = "available"
    objective_complete = false
    quest_turned_in = false
    player.position = PLAYER_START
    player.flip_h = false
    last_position = PLAYER_START
    step_distance = 0.0
    encounter_active = false
    encounter_panel.visible = false
    combat_player_sprite.visible = false
    combat_enemy_sprite.visible = false
    dialogue_panel.visible = false
    _set_quest_state("available")
    _show_toast("Demo reiniciada.", 2.0)

func _show_toast(message: String, duration: float) -> void:
    toast_label.text = message
    toast_time = duration

func _make_world_label(text_value: String, label_position: Vector2, font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.position = label_position
    label.text = text_value
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.02, 0.01, 0.04, 0.9))
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    return label

## Used by the headless smoke test to verify the playable slice assembled.
func demo_smoke_test() -> Dictionary:
    return {
        "player_loaded": player != null and player.sprite_frames != null,
        "player_idle_frames": player != null and player.sprite_frames.get_frame_count("idle") == 4,
        "npc_loaded": npc != null and npc.sprite_frames != null,
        "npc_idle_frames": npc != null and npc.sprite_frames.get_frame_count("idle") == 4,
        "quest_marker_loaded": quest_marker != null and quest_marker.texture != null,
        "objective_marker_loaded": objective_marker != null,
        "encounter_manager_loaded": encounter_manager != null,
        "quest_state": quest_state,
    }
