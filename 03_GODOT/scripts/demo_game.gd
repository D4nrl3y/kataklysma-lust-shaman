extends Node2D

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
    encounter_panel.position = Vector2(235.0, 150.0)
    encounter_panel.size = Vector2(810.0, 390.0)
    encounter_panel.color = Color(0.08, 0.025, 0.07, 0.97)
    encounter_panel.visible = false
    hud.add_child(encounter_panel)

    var encounter_title := Label.new()
    encounter_title.position = Vector2(28.0, 22.0)
    encounter_title.text = "ENCONTRO ALEATÓRIO  //  DEMO DE COMBATE"
    encounter_title.add_theme_font_size_override("font_size", 22)
    encounter_title.add_theme_color_override("font_color", Color("#ffb4c4"))
    encounter_panel.add_child(encounter_title)

    encounter_body = Label.new()
    encounter_body.position = Vector2(28.0, 82.0)
    encounter_body.size = Vector2(750.0, 210.0)
    encounter_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    encounter_body.add_theme_font_size_override("font_size", 20)
    encounter_panel.add_child(encounter_body)

    encounter_hint = Label.new()
    encounter_hint.position = Vector2(28.0, 320.0)
    encounter_hint.add_theme_font_size_override("font_size", 15)
    encounter_hint.add_theme_color_override("font_color", Color("#91d7ff"))
    encounter_panel.add_child(encounter_hint)

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
    var event_type := str(encounter.get("type", "monster_ambush")).replace("_", " ").capitalize()
    var actors: Array = encounter.get("actors", ["makrura_corrupted"])
    encounter_body.text = "Um evento surgiu durante a exploração.\n\nTipo: %s\nAmeaça / atores: %s\n\nEsta é a interface-base do combate por turnos. A implementação completa de habilidades e turnos entra no próximo marco." % [event_type, ", ".join(actors)]
    encounter_hint.text = "1  Ataque físico     2  Canalizar espírito     3  Recuar     •     E / Espaço depois da escolha"
    encounter_panel.visible = true

func _handle_encounter_input(keycode: Key) -> void:
    if keycode in [KEY_1, KEY_2, KEY_3]:
        encounter_choice_made = true
        var choice: String = str({KEY_1: "Ataque físico", KEY_2: "Canalizar espírito", KEY_3: "Recuar"}.get(keycode, "Ação"))
        encounter_body.text += "\n\nAção escolhida: %s\nResultado da demo: resolução registrada." % choice
        encounter_hint.text = "E / Espaço  fechar encontro e continuar explorando"
    elif encounter_choice_made and keycode in [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE]:
        encounter_panel.visible = false
        encounter_active = false
        _show_toast("Encontro resolvido. O mundo continua em Echo Isles.", 3.0)
    elif keycode == KEY_ESCAPE:
        encounter_panel.visible = false
        encounter_active = false

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
