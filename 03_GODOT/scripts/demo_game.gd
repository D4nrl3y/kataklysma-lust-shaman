extends Node2D

const CombatSystem = preload("res://03_GODOT/scripts/combat_system.gd")
const AudioManagerScript = preload("res://03_GODOT/scripts/audio_manager.gd")
const WalkabilityDebugScript = preload("res://03_GODOT/scripts/walkability_debug.gd")

## First playable vertical slice for Kataklysma: Lust Shaman's Journey.
## Echo Isles is presented as a real navigable world: camera, scale, collisions,
## depth sorting, interaction, dialogue choices, CG, save/load and combat.

const VIEW_SIZE := Vector2(1280.0, 720.0)
const MAP_SIZE := Vector2(1672.0, 941.0)
const DEMO_VERSION := "0.1.0-demo"
const ZONE_ID := "echo_isles"
const MAP_TEXTURE := "res://01_ASSETS/kataklysma/maps/echo_isles/backgrounds/echo_isles_background_concept_v001.png"
const PLAYER_IDLE_DIR := "res://01_ASSETS/kataklysma/sprites/idle"
const PLAYER_WALK_DIR := "res://01_ASSETS/kataklysma/sprites/walk"
const NPC_ID := "zekranu"
const NPC_IDLE_DIR := "res://01_ASSETS/kataklysma/sprites/npcs/zekranu/IDLE"
const NPC_WALK_DIR := "res://01_ASSETS/kataklysma/sprites/npcs/zekranu/WALK"
const ENTITY_IDLE_DIR := "res://01_ASSETS/kataklysma/character/entities/sprites/corrupted_makrura/IDLE"
const ENTITY_COMBAT_DIR := "res://01_ASSETS/kataklysma/character/entities/sprites/corrupted_makrura/COMBAT"
const PLAYER_PORTRAIT := "res://01_ASSETS/kataklysma/ui/portraits/neutral/kataklysma_portrait_neutral.png"
const NPC_PORTRAIT := "res://01_ASSETS/kataklysma/ui/portraits/neutral/zekranu_portrait_neutral_v001.png"
const DIRECTIONAL_DIR := "res://01_ASSETS/kataklysma/sprites/directional"
const QUEST_MARKERS := {
    "available": "res://01_ASSETS/kataklysma/ui/markers/quest_available.svg",
    "in_progress": "res://01_ASSETS/kataklysma/ui/markers/quest_in_progress.svg",
    "complete": "res://01_ASSETS/kataklysma/ui/markers/quest_complete.svg",
}

var player: AnimatedSprite2D
var npc: AnimatedSprite2D
var player_collision_body: CharacterBody2D
var camera: Camera2D
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
var dialogue_portrait: TextureRect
var dialogue_portrait_placeholder: Label
var encounter_panel: ColorRect
var encounter_body: Label
var encounter_hint: Label
var encounter_manager: Node
var combat_system: RefCounted
var audio_manager: Node
var combat_player_sprite: AnimatedSprite2D
var combat_enemy_sprite: AnimatedSprite2D
var combat_player_bar: ProgressBar
var combat_enemy_bar: ProgressBar
var combat_player_spirit_bar: ProgressBar
var combat_turn_label: Label
var combat_log_label: Label
var combat_action_label: Label
var gameplay_hud: CanvasLayer
var interaction_prompt: Label
var tutorial_label: Label
var dialogue_choices: Label
var menu_layer: CanvasLayer
var pause_layer: CanvasLayer
var pause_info: Label
var minimap_player_dot: Label
var minimap_quest_dot: Label
var minimap_objective_dot: Label
var minimap_panel: ColorRect
var walkability_debug: Node2D
var cg_layer: CanvasLayer
var cg_image: TextureRect
var cg_caption: Label
var cg_frames: Array[String] = []
var cg_active := false
var cg_index := 0
var cg_time := 0.0
var world_started := false
var paused := false
var dialogue_choice_selected := false
var attributes := {
    "agility": 61,
    "stamina": 54,
    "intellect": 82,
    "spirit": 73,
    "corruption": 21,
    "lust": 43,
}
var npc_affinity := {"zekranu": 0}
var story_flags := {}
var discovered_pois := {"awakening_cabin": true, "training_clearing": true}

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
var tutorial_distance := 0.0
var tutorial_time := 0.0
var last_direction := "front"
var debug_walkability_visible := false

const PLAYER_START := Vector2(410.0, 390.0)
const NPC_POSITION := Vector2(830.0, 365.0)
const OBJECTIVE_POSITION := Vector2(1030.0, 505.0)
const MOVE_SPEED := 190.0
const SAVE_PATH := "user://kataklysma_echo_isles_demo.json"
var WALKABLE_POLYGONS: Array[PackedVector2Array] = [
    PackedVector2Array([Vector2(260, 230), Vector2(500, 230), Vector2(580, 290), Vector2(580, 385), Vector2(520, 450), Vector2(300, 450), Vector2(250, 380)]),
    PackedVector2Array([Vector2(120, 120), Vector2(500, 105), Vector2(570, 155), Vector2(500, 205), Vector2(280, 230), Vector2(150, 205)]),
    PackedVector2Array([Vector2(500, 350), Vector2(650, 290), Vector2(840, 310), Vector2(910, 360), Vector2(840, 445), Vector2(700, 455), Vector2(620, 460), Vector2(530, 420)]),
    PackedVector2Array([Vector2(1000, 230), Vector2(1210, 220), Vector2(1450, 250), Vector2(1550, 320), Vector2(1490, 350), Vector2(1280, 315), Vector2(1100, 330)]),
    PackedVector2Array([Vector2(930, 100), Vector2(1100, 95), Vector2(1180, 130), Vector2(1400, 120), Vector2(1490, 170), Vector2(1450, 220), Vector2(1200, 210), Vector2(1100, 190), Vector2(980, 210)]),
    PackedVector2Array([Vector2(1330, 330), Vector2(1410, 335), Vector2(1515, 410), Vector2(1535, 460), Vector2(1470, 430), Vector2(1390, 385), Vector2(1330, 360)]),
    PackedVector2Array([Vector2(500, 460), Vector2(650, 450), Vector2(800, 475), Vector2(850, 520), Vector2(760, 550), Vector2(630, 520), Vector2(520, 510)]),
    PackedVector2Array([Vector2(850, 480), Vector2(1080, 455), Vector2(1300, 470), Vector2(1470, 530), Vector2(1450, 580), Vector2(1300, 540), Vector2(1100, 525), Vector2(930, 555), Vector2(875, 530)]),
    PackedVector2Array([Vector2(960, 500), Vector2(1080, 500), Vector2(1110, 560), Vector2(1000, 580), Vector2(940, 550)]),
    PackedVector2Array([Vector2(1300, 500), Vector2(1450, 520), Vector2(1470, 580), Vector2(1360, 590)]),
]
var WALKABLE_REGIONS: Array[PackedVector2Array] = WALKABLE_POLYGONS
var WALKABILITY_BLOCK_POLYGONS: Array[PackedVector2Array] = [
    PackedVector2Array([Vector2(490, 330), Vector2(650, 330), Vector2(675, 420), Vector2(625, 455), Vector2(500, 445), Vector2(470, 390)]),
]
const COLLISION_RECT_DATA := [
    {"position": Vector2(MAP_SIZE.x * 0.5, 48.0), "size": Vector2(MAP_SIZE.x, 96.0)},
    {"position": Vector2(MAP_SIZE.x * 0.5, MAP_SIZE.y - 38.0), "size": Vector2(MAP_SIZE.x, 76.0)},
    {"position": Vector2(38.0, MAP_SIZE.y * 0.5), "size": Vector2(76.0, MAP_SIZE.y)},
    {"position": Vector2(MAP_SIZE.x - 38.0, MAP_SIZE.y * 0.5), "size": Vector2(76.0, MAP_SIZE.y)},
    {"position": Vector2(575.0, 380.0), "size": Vector2(170.0, 110.0)},
    {"position": Vector2(1240.0, 285.0), "size": Vector2(260.0, 74.0)},
    {"position": Vector2(1330.0, 610.0), "size": Vector2(250.0, 96.0)},
    {"position": NPC_POSITION + Vector2(0.0, 30.0), "size": Vector2(46.0, 24.0)},
]
const CG_VARIANTS := [
    "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_002_zekranu_totem_choice__01_start_v002.png",
    "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_002_zekranu_totem_choice__02_development_v002.png",
    "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_002_zekranu_totem_choice__03_climax_v002.png",
    "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_002_zekranu_totem_choice__04_resolution_v002.png",
]

func _ready() -> void:
    _build_world()
    _build_hud()
    _build_encounter_manager()
    audio_manager = AudioManagerScript.new()
    audio_manager.name = "AudioManager"
    add_child(audio_manager)
    _build_cg_layer()
    _build_pause_menu()
    _build_main_menu()
    _set_quest_state("available")
    _set_gameplay_visible(false)

func _build_world() -> void:
    var entities_root := Node2D.new()
    entities_root.name = "Entities"
    entities_root.y_sort_enabled = true
    add_child(entities_root)

    var background := Sprite2D.new()
    background.name = "EchoIslesBackground"
    background.texture = load(MAP_TEXTURE)
    background.position = MAP_SIZE * 0.5
    background.z_index = -20
    add_child(background)

    var tint := ColorRect.new()
    tint.name = "WorldReadabilityTint"
    tint.color = Color(0.04, 0.02, 0.08, 0.22)
    tint.position = Vector2.ZERO
    tint.size = MAP_SIZE
    tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    tint.z_index = -19
    add_child(tint)

    player = _make_actor("Kataklysma", PLAYER_IDLE_DIR, PLAYER_WALK_DIR, "kataklysma")
    player.position = PLAYER_START
    player.scale = Vector2(0.26, 0.26)
    player.z_index = 5
    entities_root.add_child(player)
    player.play("idle")
    last_position = player.position

    camera = Camera2D.new()
    camera.name = "Camera2D"
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 7.0
    camera.zoom = Vector2(1.18, 1.18)
    camera.limit_left = 0
    camera.limit_top = 0
    camera.limit_right = int(MAP_SIZE.x)
    camera.limit_bottom = int(MAP_SIZE.y)
    camera.enabled = true
    player.add_child(camera)

    player_collision_body = CharacterBody2D.new()
    player_collision_body.name = "PlayerCollision"
    player_collision_body.position = PLAYER_START
    player_collision_body.collision_layer = 1
    player_collision_body.collision_mask = 1
    var player_collision_shape := CollisionShape2D.new()
    var player_shape := RectangleShape2D.new()
    player_shape.size = Vector2(20.0, 12.0)
    player_collision_shape.position = Vector2(0.0, 48.0)
    player_collision_shape.shape = player_shape
    player_collision_body.add_child(player_collision_shape)
    add_child(player_collision_body)
    _build_collision_world()

    walkability_debug = WalkabilityDebugScript.new()
    walkability_debug.name = "WalkabilityDebugOverlay"
    walkability_debug.z_index = 40
    walkability_debug.configure(WALKABLE_POLYGONS, _collision_rects_for_debug(), WALKABILITY_BLOCK_POLYGONS)
    walkability_debug.visible = false
    add_child(walkability_debug)

    npc = _make_actor("Zekranu", NPC_IDLE_DIR, NPC_WALK_DIR, "npc_%s" % NPC_ID)
    npc.position = NPC_POSITION
    npc.scale = Vector2(0.26, 0.26)
    npc.z_index = 5
    entities_root.add_child(npc)
    npc.play("idle")

    var npc_interaction_area := Area2D.new()
    npc_interaction_area.name = "InteractionArea_Zekranu"
    npc_interaction_area.position = NPC_POSITION
    npc_interaction_area.collision_layer = 0
    npc_interaction_area.collision_mask = 0
    var npc_area_shape := CollisionShape2D.new()
    var npc_circle := CircleShape2D.new()
    npc_circle.radius = 125.0
    npc_area_shape.shape = npc_circle
    npc_interaction_area.add_child(npc_area_shape)
    add_child(npc_interaction_area)

    quest_marker = Sprite2D.new()
    quest_marker.name = "QuestMarker_Zekranu"
    quest_marker.position = NPC_POSITION + Vector2(0.0, -116.0)
    quest_marker.scale = Vector2(0.62, 0.62)
    quest_marker.z_index = 12
    entities_root.add_child(quest_marker)

    npc_name = _make_world_label("Zek'Ranu\nMentor Xamã", NPC_POSITION + Vector2(-52.0, 64.0), 13, Color("#ffe7a6"))
    npc_name.visible = false
    entities_root.add_child(npc_name)
    player_name = _make_world_label("", PLAYER_START, 1, Color.TRANSPARENT)
    player_name.visible = false
    entities_root.add_child(player_name)

    objective_marker = _make_world_label("◈  MARÉ CORROMPIDA\n    objetivo da quest", OBJECTIVE_POSITION + Vector2(-90.0, -18.0), 14, Color("#91d7ff"))
    objective_marker.visible = false
    entities_root.add_child(objective_marker)

    var camp_label := _make_world_label("", Vector2.ZERO, 1, Color.TRANSPARENT)
    camp_label.visible = false
    entities_root.add_child(camp_label)

func _build_collision_world() -> void:
    for obstacle in COLLISION_RECT_DATA:
        var body := StaticBody2D.new()
        body.name = "WalkableBoundary"
        body.collision_layer = 1
        body.collision_mask = 1
        body.position = obstacle["position"]
        var shape_node := CollisionShape2D.new()
        var shape := RectangleShape2D.new()
        shape.size = obstacle["size"]
        shape_node.shape = shape
        body.add_child(shape_node)
        add_child(body)

func _collision_rects_for_debug() -> Array[Rect2]:
    var rects: Array[Rect2] = []
    for obstacle in COLLISION_RECT_DATA:
        var size: Vector2 = obstacle["size"]
        var position: Vector2 = obstacle["position"]
        rects.append(Rect2(position - size * 0.5, size))
    return rects

func _make_actor(actor_name: String, idle_dir: String, walk_dir: String, file_prefix: String) -> AnimatedSprite2D:
    var actor := AnimatedSprite2D.new()
    actor.name = actor_name
    var frames := SpriteFrames.new()
    if frames.has_animation("default"):
        frames.remove_animation("default")
    _add_frames(frames, "idle", idle_dir, "%s_idle" % file_prefix, 4, 4.0, true)
    _add_frames(frames, "walk", walk_dir, "%s_walk" % file_prefix, 4, 8.0, true)
    _copy_animation(frames, "idle", "idle_front")
    _copy_animation(frames, "walk", "walk_front")
    if file_prefix == "kataklysma":
        _add_exact_frames(frames, "idle_back", "%s/idle_back" % DIRECTIONAL_DIR, "chr_kataklysma_idle_back_f", 2, 3.0, true)
        _add_exact_frames(frames, "idle_left", "%s/idle_left" % DIRECTIONAL_DIR, "chr_kataklysma_idle_left_f", 2, 3.0, true)
        _add_exact_frames(frames, "idle_right", "%s/idle_right" % DIRECTIONAL_DIR, "chr_kataklysma_idle_right_f", 2, 3.0, true)
        _add_exact_frames(frames, "walk_back", "%s/walk_back" % DIRECTIONAL_DIR, "chr_kataklysma_walk_back_f", 8, 8.0, true)
        _add_exact_frames(frames, "walk_left", "%s/walk_left" % DIRECTIONAL_DIR, "chr_kataklysma_walk_left_f", 8, 8.0, true)
        _add_exact_frames(frames, "walk_right", "%s/walk_right" % DIRECTIONAL_DIR, "chr_kataklysma_walk_right_f", 8, 8.0, true)
    else:
        _copy_animation(frames, "idle", "idle_back")
        _copy_animation(frames, "idle", "idle_left")
        _copy_animation(frames, "idle", "idle_right")
        _copy_animation(frames, "walk", "walk_back")
        _copy_animation(frames, "walk", "walk_left")
        _copy_animation(frames, "walk", "walk_right")
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

func _add_exact_frames(frames: SpriteFrames, animation_name: String, directory: String, stem: String, count: int, fps: float, looped: bool) -> void:
    frames.add_animation(animation_name)
    frames.set_animation_speed(animation_name, fps)
    frames.set_animation_loop(animation_name, looped)
    for index in range(1, count + 1):
        var texture: Texture2D = load("%s/%s%03d_v001.png" % [directory, stem, index])
        if texture:
            frames.add_frame(animation_name, texture)

func _copy_animation(frames: SpriteFrames, source_name: String, target_name: String) -> void:
    frames.add_animation(target_name)
    frames.set_animation_speed(target_name, frames.get_animation_speed(source_name))
    frames.set_animation_loop(target_name, frames.get_animation_loop(source_name))
    for frame_index in range(frames.get_frame_count(source_name)):
        frames.add_frame(target_name, frames.get_frame_texture(source_name, frame_index))

func _build_hud() -> void:
    var hud := CanvasLayer.new()
    hud.name = "DemoHUD"
    gameplay_hud = hud
    add_child(hud)

    var top_bar := ColorRect.new()
    top_bar.color = Color(0.035, 0.02, 0.08, 0.86)
    top_bar.position = Vector2(24.0, 24.0)
    top_bar.size = Vector2(390.0, 70.0)
    top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(top_bar)

    var title := Label.new()
    title.position = Vector2(20.0, 9.0)
    title.text = "ECHO ISLES"
    title.add_theme_font_size_override("font_size", 18)
    title.add_theme_color_override("font_color", Color("#ffe7a6"))
    top_bar.add_child(title)

    quest_state_label = Label.new()
    quest_state_label.position = Vector2(20.0, 39.0)
    quest_state_label.size = Vector2(350.0, 25.0)
    quest_state_label.add_theme_font_size_override("font_size", 14)
    top_bar.add_child(quest_state_label)

    var controls := Label.new()
    controls.position = Vector2(20.0, 650.0)
    controls.text = "WASD / setas: mover   •   E / Espaço: interagir   •   F: encontro   •   R: reiniciar"
    controls.add_theme_font_size_override("font_size", 15)
    controls.add_theme_color_override("font_color", Color(1.0, 0.96, 0.86, 0.92))
    controls.visible = false
    hud.add_child(controls)

    toast_label = Label.new()
    toast_label.position = Vector2(24.0, 650.0)
    toast_label.size = Vector2(800.0, 32.0)
    toast_label.add_theme_font_size_override("font_size", 17)
    toast_label.add_theme_color_override("font_color", Color("#d5f4ff"))
    hud.add_child(toast_label)

    interaction_prompt = Label.new()
    interaction_prompt.position = Vector2(350.0, 585.0)
    interaction_prompt.size = Vector2(580.0, 34.0)
    interaction_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    interaction_prompt.add_theme_font_size_override("font_size", 18)
    interaction_prompt.add_theme_color_override("font_color", Color("#ffe7a6"))
    interaction_prompt.visible = false
    hud.add_child(interaction_prompt)

    tutorial_label = Label.new()
    tutorial_label.position = Vector2(470.0, 590.0)
    tutorial_label.size = Vector2(340.0, 60.0)
    tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    tutorial_label.text = "WASD / SETAS\nMover Kataklysma"
    tutorial_label.add_theme_font_size_override("font_size", 17)
    tutorial_label.add_theme_color_override("font_color", Color("#d5f4ff"))
    hud.add_child(tutorial_label)

    minimap_panel = ColorRect.new()
    minimap_panel.position = Vector2(1040.0, 24.0)
    minimap_panel.size = Vector2(210.0, 180.0)
    minimap_panel.color = Color(0.025, 0.035, 0.08, 0.86)
    hud.add_child(minimap_panel)
    var minimap_title := Label.new()
    minimap_title.position = Vector2(12.0, 8.0)
    minimap_title.text = "ECHO ISLES  •  MAPA"
    minimap_title.add_theme_font_size_override("font_size", 12)
    minimap_title.add_theme_color_override("font_color", Color("#d5f4ff"))
    minimap_panel.add_child(minimap_title)
    minimap_player_dot = _make_minimap_dot("●", Color("#d9f1ff"))
    minimap_quest_dot = _make_minimap_dot("!", Color("#f6d365"))
    minimap_objective_dot = _make_minimap_dot("◇", Color("#91d7ff"))
    minimap_panel.add_child(minimap_player_dot)
    minimap_panel.add_child(minimap_quest_dot)
    minimap_panel.add_child(minimap_objective_dot)

    dialogue_panel = ColorRect.new()
    dialogue_panel.position = Vector2(120.0, 435.0)
    dialogue_panel.size = Vector2(1040.0, 235.0)
    dialogue_panel.color = Color(0.035, 0.025, 0.08, 0.94)
    dialogue_panel.visible = false
    hud.add_child(dialogue_panel)

    dialogue_title = Label.new()
    dialogue_title.position = Vector2(180.0, 16.0)
    dialogue_title.add_theme_font_size_override("font_size", 21)
    dialogue_title.add_theme_color_override("font_color", Color("#ffe7a6"))
    dialogue_panel.add_child(dialogue_title)

    var portrait_back := ColorRect.new()
    portrait_back.position = Vector2(22.0, 34.0)
    portrait_back.size = Vector2(135.0, 145.0)
    portrait_back.color = Color(0.02, 0.015, 0.04, 0.95)
    dialogue_panel.add_child(portrait_back)
    dialogue_portrait = TextureRect.new()
    dialogue_portrait.position = Vector2(27.0, 39.0)
    dialogue_portrait.size = Vector2(125.0, 135.0)
    dialogue_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    dialogue_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    dialogue_panel.add_child(dialogue_portrait)
    dialogue_portrait_placeholder = Label.new()
    dialogue_portrait_placeholder.position = Vector2(27.0, 94.0)
    dialogue_portrait_placeholder.size = Vector2(125.0, 25.0)
    dialogue_portrait_placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    dialogue_portrait_placeholder.text = "PORTRAIT"
    dialogue_portrait_placeholder.add_theme_font_size_override("font_size", 11)
    dialogue_portrait_placeholder.add_theme_color_override("font_color", Color("#91d7ff"))
    dialogue_portrait_placeholder.visible = false
    dialogue_panel.add_child(dialogue_portrait_placeholder)

    dialogue_body = Label.new()
    dialogue_body.position = Vector2(180.0, 49.0)
    dialogue_body.size = Vector2(830.0, 48.0)
    dialogue_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_body.add_theme_font_size_override("font_size", 17)
    dialogue_panel.add_child(dialogue_body)

    dialogue_choices = Label.new()
    dialogue_choices.position = Vector2(180.0, 98.0)
    dialogue_choices.size = Vector2(830.0, 88.0)
    dialogue_choices.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_choices.add_theme_font_size_override("font_size", 13)
    dialogue_choices.add_theme_color_override("font_color", Color("#ffe7a6"))
    dialogue_panel.add_child(dialogue_choices)

    dialogue_hint = Label.new()
    dialogue_hint.position = Vector2(180.0, 204.0)
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

func _make_minimap_dot(dot_text: String, dot_color: Color) -> Label:
    var dot := Label.new()
    dot.text = dot_text
    dot.add_theme_font_size_override("font_size", 16)
    dot.add_theme_color_override("font_color", dot_color)
    dot.position = Vector2(20.0, 70.0)
    return dot

func _build_main_menu() -> void:
    menu_layer = CanvasLayer.new()
    menu_layer.name = "MainMenu"
    menu_layer.layer = 30
    add_child(menu_layer)

    var background := TextureRect.new()
    background.position = Vector2.ZERO
    background.size = VIEW_SIZE
    background.texture = load("res://01_ASSETS/kataklysma/promotional/menu/cg_main_menu_hero_v001.png")
    background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    menu_layer.add_child(background)
    var shade := ColorRect.new()
    shade.position = Vector2.ZERO
    shade.size = VIEW_SIZE
    shade.color = Color(0.025, 0.01, 0.06, 0.34)
    menu_layer.add_child(shade)

    var title := Label.new()
    title.position = Vector2(78.0, 92.0)
    title.text = "KATAKLYSMA\nLUST SHAMAN'S JOURNEY"
    title.add_theme_font_size_override("font_size", 32)
    title.add_theme_color_override("font_color", Color("#ffe7a6"))
    menu_layer.add_child(title)

    var subtitle := Label.new()
    subtitle.position = Vector2(82.0, 182.0)
    subtitle.text = "A first playable journey through Echo Isles"
    subtitle.add_theme_font_size_override("font_size", 15)
    subtitle.add_theme_color_override("font_color", Color("#d5f4ff"))
    menu_layer.add_child(subtitle)

    _add_menu_button("NOVO JOGO", Vector2(82.0, 288.0), Callable(self, "_start_new_game"))
    var continue_button: Button = _add_menu_button("CONTINUAR", Vector2(82.0, 340.0), Callable(self, "_continue_game"))
    continue_button.disabled = not FileAccess.file_exists(SAVE_PATH)
    _add_menu_button("OPÇÕES", Vector2(82.0, 392.0), Callable(self, "_show_menu_options"))
    _add_menu_button("CRÉDITOS", Vector2(82.0, 444.0), Callable(self, "_show_menu_credits"))
    _add_menu_button("SAIR", Vector2(82.0, 496.0), Callable(self, "_quit_game"))

    var footer := Label.new()
    footer.position = Vector2(82.0, 630.0)
    footer.text = "Echo Isles vertical slice  •  %s" % DEMO_VERSION
    footer.add_theme_font_size_override("font_size", 13)
    footer.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85, 0.82))
    menu_layer.add_child(footer)

func _add_menu_button(button_text: String, button_position: Vector2, callback: Callable) -> Button:
    var button := Button.new()
    button.position = button_position
    button.size = Vector2(270.0, 40.0)
    button.text = button_text
    button.add_theme_font_size_override("font_size", 17)
    button.add_theme_color_override("font_color", Color("#ffe7a6"))
    button.add_theme_color_override("font_hover_color", Color("#ffffff"))
    button.add_theme_color_override("font_pressed_color", Color("#91d7ff"))
    button.add_theme_color_override("font_disabled_color", Color(1.0, 0.9, 0.7, 0.35))
    button.add_theme_stylebox_override("normal", _make_button_style(Color(0.04, 0.03, 0.10, 0.82), Color(0.55, 0.42, 0.24, 0.65)))
    button.add_theme_stylebox_override("hover", _make_button_style(Color(0.16, 0.10, 0.16, 0.94), Color("#ffe7a6")))
    button.add_theme_stylebox_override("focus", _make_button_style(Color(0.12, 0.08, 0.16, 0.96), Color("#91d7ff")))
    button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.02, 0.08, 0.13, 0.98), Color("#91d7ff")))
    button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.04, 0.03, 0.10, 0.50), Color(0.55, 0.42, 0.24, 0.25)))
    button.pressed.connect(callback)
    menu_layer.add_child(button)
    return button

func _make_button_style(background_color: Color, border_color: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = background_color
    style.border_color = border_color
    style.set_border_width_all(1)
    style.corner_radius_top_left = 5
    style.corner_radius_top_right = 5
    style.corner_radius_bottom_left = 5
    style.corner_radius_bottom_right = 5
    style.content_margin_left = 16.0
    style.content_margin_right = 16.0
    return style

func _build_pause_menu() -> void:
    pause_layer = CanvasLayer.new()
    pause_layer.name = "PauseMenu"
    pause_layer.layer = 25
    add_child(pause_layer)
    var shade := ColorRect.new()
    shade.position = Vector2.ZERO
    shade.size = VIEW_SIZE
    shade.color = Color(0.01, 0.01, 0.04, 0.64)
    pause_layer.add_child(shade)
    var panel := ColorRect.new()
    panel.position = Vector2(370.0, 90.0)
    panel.size = Vector2(540.0, 540.0)
    panel.color = Color(0.035, 0.025, 0.08, 0.96)
    pause_layer.add_child(panel)
    var title := Label.new()
    title.position = Vector2(34.0, 26.0)
    title.text = "PAUSA"
    title.add_theme_font_size_override("font_size", 28)
    title.add_theme_color_override("font_color", Color("#ffe7a6"))
    panel.add_child(title)
    pause_info = Label.new()
    pause_info.position = Vector2(34.0, 90.0)
    pause_info.size = Vector2(470.0, 380.0)
    pause_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    pause_info.add_theme_font_size_override("font_size", 18)
    pause_info.text = "1  ATRIBUTOS\n2  QUESTS\n3  MAPA\n4  OPÇÕES\nS  SALVAR\nM  MENU PRINCIPAL\n\nESC  CONTINUAR"
    pause_info.add_theme_color_override("font_color", Color("#d5f4ff"))
    panel.add_child(pause_info)
    pause_layer.visible = false

func _build_cg_layer() -> void:
    cg_layer = CanvasLayer.new()
    cg_layer.name = "CGSequence"
    cg_layer.layer = 40
    add_child(cg_layer)
    var background := ColorRect.new()
    background.position = Vector2.ZERO
    background.size = VIEW_SIZE
    background.color = Color(0.01, 0.008, 0.025, 0.98)
    cg_layer.add_child(background)
    cg_image = TextureRect.new()
    cg_image.position = Vector2(70.0, 55.0)
    cg_image.size = Vector2(1140.0, 570.0)
    cg_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    cg_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    cg_layer.add_child(cg_image)
    cg_caption = Label.new()
    cg_caption.position = Vector2(70.0, 635.0)
    cg_caption.size = Vector2(1140.0, 30.0)
    cg_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    cg_caption.add_theme_font_size_override("font_size", 15)
    cg_caption.add_theme_color_override("font_color", Color("#ffe7a6"))
    cg_layer.add_child(cg_caption)
    cg_layer.visible = false

func _set_gameplay_visible(visible: bool) -> void:
    if gameplay_hud:
        gameplay_hud.visible = visible
    if not visible and pause_layer:
        pause_layer.visible = false
    world_started = visible

func _start_new_game() -> void:
    _reset_demo()
    _set_gameplay_visible(true)
    menu_layer.visible = false
    tutorial_label.modulate.a = 1.0
    tutorial_label.visible = not story_flags.get("tutorial_movement_seen", false)
    tutorial_time = 0.0
    audio_manager.play_ui("menu_select")
    _show_toast("Echo Isles • explore uma maré corrompida", 3.0)

func _continue_game() -> void:
    _start_new_game()
    _load_game()

func _show_menu_options() -> void:
    _show_toast("Opções: áudio, vídeo, minimapa e velocidade de texto serão persistidos no próximo marco.", 4.0)

func _show_menu_credits() -> void:
    _show_toast("Kataklysma — Lust Shaman's Journey • Echo Isles %s" % DEMO_VERSION, 4.0)

func _quit_game() -> void:
    get_tree().quit()

func _toggle_pause() -> void:
    if not world_started or encounter_active or dialogue_panel.visible or cg_active:
        return
    paused = not paused
    pause_layer.visible = paused
    if paused:
        _refresh_pause_info()

func _refresh_pause_info() -> void:
    pause_info.text = "1  ATRIBUTOS\n2  QUESTS\n3  MAPA\n4  OPÇÕES\nS  SALVAR\nM  MENU PRINCIPAL\n\n" + _attributes_text() + "\nESC  CONTINUAR"

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
    _update_minimap()
    _update_interaction_feedback()
    if cg_active:
        _process_cg(delta)
        return
    if quest_marker and quest_marker.visible:
        quest_marker.position.y = NPC_POSITION.y - 116.0 + sin(marker_time * 3.0) * 5.0
    if toast_time > 0.0:
        toast_time -= delta
        if toast_time <= 0.0:
            toast_label.text = ""
    if world_started and not dialogue_panel.visible and not story_flags.get("tutorial_movement_seen", false):
        tutorial_time += delta
        if tutorial_time >= 3.0:
            _hide_tutorial()
    if not world_started or paused or dialogue_panel.visible or encounter_active:
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
        player.play("idle_%s" % last_direction)
        return
    direction = direction.normalized()
    var motion: Vector2 = direction * MOVE_SPEED * delta
    tutorial_distance += motion.length()
    if tutorial_distance >= 380.0:
        _hide_tutorial()
    var candidate_position: Vector2 = player.position + motion
    if not _is_walkable_position(candidate_position):
        player.play("idle_%s" % last_direction)
        return
    player_collision_body.position = player.position
    player_collision_body.move_and_collide(motion)
    player.position = player_collision_body.position
    player.position.x = clampf(player.position.x, 90.0, MAP_SIZE.x - 90.0)
    player.position.y = clampf(player.position.y, 165.0, MAP_SIZE.y - 115.0)
    player_collision_body.position = player.position
    if absf(direction.x) > absf(direction.y):
        last_direction = "left" if direction.x < 0.0 else "right"
        player.flip_h = false
    elif direction.y < 0.0:
        last_direction = "back"
        player.flip_h = false
    else:
        last_direction = "front"
        player.flip_h = false
    player.play("walk_%s" % last_direction)
    step_distance += player.position.distance_to(last_position)
    last_position = player.position
    if step_distance >= 52.0:
        step_distance = 0.0
        encounter_manager.register_step()
        encounter_manager.try_roll(ZONE_ID, false)

func _is_walkable_position(world_position: Vector2) -> bool:
    var feet_position := world_position + Vector2(0.0, 48.0)
    for blocked_region in WALKABILITY_BLOCK_POLYGONS:
        if Geometry2D.is_point_in_polygon(feet_position, blocked_region):
            return false
    for region in WALKABLE_POLYGONS:
        if Geometry2D.is_point_in_polygon(feet_position, region):
            return true
    return false

func collision_probe_for_test(start_position: Vector2, target_position: Vector2) -> bool:
    if not _is_walkable_position(target_position):
        return true
    var previous_position: Vector2 = player_collision_body.position
    player_collision_body.position = start_position
    var blocked: bool = player_collision_body.test_move(player_collision_body.global_transform, target_position - start_position)
    player_collision_body.position = previous_position
    return blocked

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    var key_event := event as InputEventKey
    if cg_active:
        if key_event.keycode in [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE]:
            _advance_cg()
        return
    if paused:
        _handle_pause_input(key_event.keycode)
        return
    if encounter_active:
        _handle_encounter_input(key_event.keycode)
        return
    if dialogue_panel.visible:
        _handle_dialogue_input(key_event.keycode)
        return
    if key_event.keycode == KEY_ESCAPE:
        _toggle_pause()
    elif key_event.keycode == KEY_R:
        _reset_demo()
    elif key_event.keycode == KEY_F10:
        _toggle_walkability_debug()
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

func _hide_tutorial() -> void:
    if not tutorial_label.visible:
        return
    story_flags["tutorial_movement_seen"] = true
    var tween := create_tween()
    tween.tween_property(tutorial_label, "modulate:a", 0.0, 0.35)
    tween.tween_callback(func() -> void: tutorial_label.visible = false)

func _toggle_walkability_debug() -> void:
    debug_walkability_visible = not debug_walkability_visible
    if walkability_debug:
        walkability_debug.visible = debug_walkability_visible
    _show_toast("Debug de walkability: %s" % ("ON" if debug_walkability_visible else "OFF"), 1.5)

func _interact_with_npc() -> void:
    if quest_state == "available":
        _show_dialogue("Zek'Ranu  •  Mentor Xamã", "A maré não está certa, criança. Até os espíritos estão evitando a costa. Como você pretende agir?", "npc_intro")
        dialogue_choices.text = "[1] ESPÍRITO — Ouvir os espíritos antes de agir.\n[2] INTELECTO — Examinar a água.\n[3] AGILIDADE — Ir direto à origem.\n[4] CORRUPÇÃO — Fazer o responsável falar.\n[5] LUXÚRIA — Responder com confiança e provocação."
        dialogue_hint.text = "1–5 escolher resposta   •   E confirmar"
    elif quest_state == "in_progress":
        _show_dialogue("Zek'Ranu", "A poça fica ao leste, perto das pedras. Procure o marcador ◈ e não toque na água escura.", "close")
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
    dialogue_choice_selected = false
    dialogue_title.text = title_text
    dialogue_body.text = body_text
    dialogue_choices.text = ""
    dialogue_hint.text = "E / Espaço  confirmar"
    _set_dialogue_portrait(NPC_PORTRAIT if title_text.begins_with("Zek") else PLAYER_PORTRAIT)
    interaction_prompt.visible = false
    npc_name.visible = false
    tutorial_label.visible = false
    minimap_panel.modulate.a = 0.42
    dialogue_panel.visible = true

func _set_dialogue_portrait(portrait_path: String) -> void:
    var texture: Texture2D = load(portrait_path)
    if texture:
        dialogue_portrait.texture = texture
        dialogue_portrait_placeholder.visible = false
    else:
        dialogue_portrait.texture = load(PLAYER_PORTRAIT)
        dialogue_portrait_placeholder.visible = dialogue_portrait.texture == null

func _handle_dialogue_input(keycode: Key) -> void:
    if dialogue_action == "npc_intro" and keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]:
        _apply_dialogue_choice(int(keycode) - int(KEY_1) + 1)
    elif keycode in [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
        _confirm_dialogue()

func _apply_dialogue_choice(choice_index: int) -> void:
    var consequence: String = ""
    match choice_index:
        1:
            attributes["spirit"] = int(attributes["spirit"]) + 2
            npc_affinity["zekranu"] = int(npc_affinity["zekranu"]) + 2
            consequence = "Zek'Ranu aprova sua escuta. Ele demonstra um ritual de proteção espiritual."
        2:
            attributes["intellect"] = int(attributes["intellect"]) + 2
            consequence = "Zek'Ranu entrega uma amostra da água para sua investigação."
        3:
            attributes["agility"] = int(attributes["agility"]) + 2
            story_flags["direct_path"] = true
            consequence = "Sua decisão é direta. Zek'Ranu marca a praia norte imediatamente."
        4:
            attributes["corruption"] = int(attributes["corruption"]) + 2
            story_flags["zekranu_warning_01"] = true
            consequence = "Zek'Ranu reage negativamente e alerta: controle também é uma forma de poder."
        5:
            attributes["lust"] = int(attributes["lust"]) + 2
            npc_affinity["zekranu"] = int(npc_affinity["zekranu"]) + 1
            consequence = "Sua confiança surpreende Zek'Ranu. O respeito dele aumenta."
        _:
            consequence = "Você decide observar a maré antes de agir."
    dialogue_choice_selected = true
    audio_manager.play_ui("menu_select")
    dialogue_action = "accept_quest"
    dialogue_title.text = "Kataklysma  •  resposta"
    _set_dialogue_portrait(PLAYER_PORTRAIT)
    dialogue_body.text = consequence + "\n\nA missão é purificar a Maré Corrompida."
    dialogue_choices.text = ""
    dialogue_hint.text = "E / Espaço  aceitar quest"

func _confirm_dialogue() -> void:
    if dialogue_action == "npc_intro":
        _apply_dialogue_choice(1)
        return
    dialogue_panel.visible = false
    dialogue_choices.text = ""
    match dialogue_action:
        "accept_quest":
            _set_quest_state("in_progress")
            audio_manager.play_ui("quest_accept")
            _show_toast("Quest aceita: Purificar a Maré Corrompida", 3.0)
        "complete_quest":
            objective_complete = true
            _set_quest_state("complete")
            _start_cg_sequence()
            audio_manager.play_ui("quest_complete")
            _show_toast("Objetivo completo. A maré revela uma visão.", 3.0)
        "turn_in_quest":
            quest_turned_in = true
            _set_quest_state("turned_in")
            audio_manager.play_ui("quest_complete")
            _show_toast("Quest entregue. Demo principal concluída!", 5.0)
        _:
            pass
    minimap_panel.modulate.a = 1.0
    tutorial_label.visible = not story_flags.get("tutorial_movement_seen", false)
    dialogue_action = ""

func _set_quest_state(new_state: String) -> void:
    quest_state = new_state
    objective_marker.visible = quest_state == "in_progress"
    quest_marker.visible = quest_state != "turned_in"
    if quest_state == "turned_in":
        quest_state_label.text = "PURIFICAR A MARÉ  ✓  concluída"
        quest_state_label.add_theme_color_override("font_color", Color("#a9f4b0"))
        return
    var marker_texture_path: String = QUEST_MARKERS.get(quest_state, QUEST_MARKERS["available"])
    quest_marker.texture = load(marker_texture_path)
    match quest_state:
        "available":
            quest_state_label.text = "PURIFICAR A MARÉ  ◈  Fale com Zek'Ranu"
            quest_state_label.add_theme_color_override("font_color", Color("#f6d365"))
        "in_progress":
            quest_state_label.text = "PURIFICAR A MARÉ  ◈  Investigue a praia norte"
            quest_state_label.add_theme_color_override("font_color", Color("#72b7ff"))
        "complete":
            quest_state_label.text = "PURIFICAR A MARÉ  ✓  Volte ao Zek'Ranu"
            quest_state_label.add_theme_color_override("font_color", Color("#8be28b"))
    minimap_quest_dot.visible = quest_state != "turned_in"
    minimap_objective_dot.visible = quest_state == "in_progress"

func _update_interaction_feedback() -> void:
    if not world_started or paused or cg_active or encounter_active or dialogue_panel.visible:
        interaction_prompt.visible = false
        if npc_name:
            npc_name.visible = false
        return
    var npc_distance: float = player.position.distance_to(NPC_POSITION)
    var objective_distance: float = player.position.distance_to(OBJECTIVE_POSITION)
    npc_name.visible = npc_distance < 190.0
    if npc_distance < 150.0:
        interaction_prompt.text = "[E]  Falar com Zek'Ranu"
        interaction_prompt.visible = true
    elif quest_state == "in_progress" and objective_distance < 150.0:
        interaction_prompt.text = "[E]  Investigar a Maré Corrompida"
        interaction_prompt.visible = true
    else:
        interaction_prompt.visible = false

func _update_minimap() -> void:
    if not minimap_panel or not player:
        return
    var map_origin := Vector2(10.0, 30.0)
    var map_extent := Vector2(190.0, 135.0)
    var player_map: Vector2 = map_origin + Vector2(player.position.x / MAP_SIZE.x * map_extent.x, player.position.y / MAP_SIZE.y * map_extent.y)
    var npc_map: Vector2 = map_origin + Vector2(NPC_POSITION.x / MAP_SIZE.x * map_extent.x, NPC_POSITION.y / MAP_SIZE.y * map_extent.y)
    var objective_map: Vector2 = map_origin + Vector2(OBJECTIVE_POSITION.x / MAP_SIZE.x * map_extent.x, OBJECTIVE_POSITION.y / MAP_SIZE.y * map_extent.y)
    minimap_player_dot.position = player_map
    minimap_quest_dot.position = npc_map
    minimap_objective_dot.position = objective_map

func _attributes_text() -> String:
    return "AGILIDADE  %d\nESTAMINA   %d\nINTELECTO  %d\nESPÍRITO   %d\nCORRUPÇÃO  %d\nLUXÚRIA    %d" % [
        int(attributes["agility"]), int(attributes["stamina"]), int(attributes["intellect"]),
        int(attributes["spirit"]), int(attributes["corruption"]), int(attributes["lust"]),
    ]

func _handle_pause_input(keycode: Key) -> void:
    if keycode == KEY_ESCAPE:
        _toggle_pause()
    elif keycode == KEY_1:
        pause_info.text = "ATRIBUTOS\n\n" + _attributes_text() + "\n\nESC voltar"
    elif keycode == KEY_2:
        pause_info.text = "QUESTS\n\nPURIFICAR A MARÉ\nEstado: %s\nAfinidade Zek'Ranu: %d\n\nESC voltar" % [quest_state, int(npc_affinity["zekranu"])]
    elif keycode == KEY_3:
        pause_info.text = "MAPA\n\nEcho Isles\nPOIs descobertos: %d\nMinimapa ativo no canto superior direito.\n\nESC voltar" % discovered_pois.size()
    elif keycode == KEY_4:
        pause_info.text = "OPÇÕES\n\nÁudio: ativo\nMinimapa: ativo\nCâmera: suavizada\nResolução lógica: 1280 × 720\n\nESC voltar"
    elif keycode == KEY_S:
        _save_game()
        pause_info.text = "JOGO SALVO\n\nPosição, atributos, quest, afinidade, flags e POIs foram salvos.\n\nESC voltar"
    elif keycode == KEY_M:
        _return_to_menu()

func _save_game() -> void:
    var save_data: Dictionary = {
        "version": "demo_v2",
        "player_position": [player.position.x, player.position.y],
        "quest_state": quest_state,
        "objective_complete": objective_complete,
        "quest_turned_in": quest_turned_in,
        "attributes": attributes.duplicate(true),
        "npc_affinity": npc_affinity.duplicate(true),
        "story_flags": story_flags.duplicate(true),
        "discovered_pois": discovered_pois.duplicate(true),
        "tutorial_movement_seen": bool(story_flags.get("tutorial_movement_seen", false)),
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()

func _load_game() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        _show_toast("Nenhum save encontrado. Uma nova jornada foi iniciada.", 3.0)
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    var parsed: Variant = JSON.parse_string(file.get_as_text()) if file else null
    if parsed is Dictionary:
        var data: Dictionary = parsed
        var position_data: Array = data.get("player_position", [PLAYER_START.x, PLAYER_START.y])
        player.position = Vector2(float(position_data[0]), float(position_data[1]))
        player_collision_body.position = player.position
        quest_state = str(data.get("quest_state", "available"))
        objective_complete = bool(data.get("objective_complete", false))
        quest_turned_in = bool(data.get("quest_turned_in", false))
        attributes = data.get("attributes", attributes)
        npc_affinity = data.get("npc_affinity", npc_affinity)
        story_flags = data.get("story_flags", story_flags)
        if bool(data.get("tutorial_movement_seen", false)):
            story_flags["tutorial_movement_seen"] = true
        discovered_pois = data.get("discovered_pois", discovered_pois)
        _set_quest_state(quest_state)
        tutorial_label.modulate.a = 1.0 if not story_flags.get("tutorial_movement_seen", false) else 0.0
        tutorial_label.visible = not story_flags.get("tutorial_movement_seen", false)
        _show_toast("Save carregado.", 3.0)

func _start_cg_sequence() -> void:
    cg_frames.clear()
    for frame_path in CG_VARIANTS:
        cg_frames.append(str(frame_path))
    cg_index = 0
    cg_time = 0.0
    cg_active = true
    cg_layer.visible = true
    _show_cg_frame()

func _show_cg_frame() -> void:
    if cg_frames.is_empty():
        return
    cg_image.texture = load(cg_frames[cg_index])
    cg_caption.text = "ECHO ISLES  •  visão da maré  •  %d / %d" % [cg_index + 1, cg_frames.size()]

func _process_cg(delta: float) -> void:
    cg_time += delta
    if cg_time >= 2.5:
        _advance_cg()

func _advance_cg() -> void:
    cg_time = 0.0
    if cg_index >= cg_frames.size() - 1:
        cg_active = false
        cg_layer.visible = false
        _show_toast("QUEST COMPLETA  •  Purificar a Maré Corrompida", 4.0)
    else:
        cg_index += 1
        _show_cg_frame()

func _return_to_menu() -> void:
    paused = false
    pause_layer.visible = false
    _set_gameplay_visible(false)
    menu_layer.visible = true

func _on_encounter_triggered(_zone_id: String, encounter: Dictionary) -> void:
    _start_encounter(encounter)

func _start_encounter(encounter: Dictionary) -> void:
    encounter_active = true
    encounter_choice_made = false
    var event_type: String = str(encounter.get("type", "monster_ambush")).replace("_", " ").capitalize()
    var actors: Array = encounter.get("actors", ["makrura_corrupted"])
    var enemy_id: String = "water_spirit_weakened" if actors.has("water_spirit_weakened") else "corrupted_makrura"
    combat_system = CombatSystem.new()
    audio_manager.play_ui("combat")
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
    attributes = {"agility": 61, "stamina": 54, "intellect": 82, "spirit": 73, "corruption": 21, "lust": 43}
    npc_affinity = {"zekranu": 0}
    story_flags.clear()
    discovered_pois = {"awakening_cabin": true, "training_clearing": true}
    tutorial_distance = 0.0
    tutorial_time = 0.0
    player.position = PLAYER_START
    player.flip_h = false
    last_direction = "front"
    last_position = PLAYER_START
    step_distance = 0.0
    encounter_active = false
    encounter_panel.visible = false
    combat_player_sprite.visible = false
    combat_enemy_sprite.visible = false
    dialogue_panel.visible = false
    dialogue_choices.text = ""
    minimap_panel.modulate.a = 1.0
    tutorial_label.modulate.a = 1.0
    player_collision_body.position = PLAYER_START
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
