extends Node2D

const CombatSystem = preload("res://03_GODOT/scripts/combat_system.gd")
const AudioManagerScript = preload("res://03_GODOT/scripts/audio_manager.gd")
const WalkabilityDebugScript = preload("res://03_GODOT/scripts/walkability_debug.gd")
const OptionsMenuScript = preload("res://03_GODOT/scripts/options_menu.gd")
const ZoneMapScript = preload("res://03_GODOT/scripts/zone_map.gd")
const QuestStateRuntimeScript = preload("res://03_GODOT/scripts/quest_state_runtime.gd")
const CampaignQuestRuntimeScript = preload("res://03_GODOT/scripts/campaign_quest_runtime.gd")
const CampaignWorldRuntimeScript = preload("res://03_GODOT/scripts/campaign_world_runtime.gd")
const CAMPAIGN_DEFINITION_PATH := "res://03_GODOT/data/campaign/echo_isles.json"
const CAMPAIGN_INTERACTIONS_PATH := "res://03_GODOT/data/campaign/echo_isles_interactions.json"
const CAMPAIGN_DIALOGUE_PATH := "res://03_GODOT/data/dialogue/pt_BR/campaign_echo_isles.json"
const SENJIN_INTERACTIONS_PATH := "res://03_GODOT/data/campaign/senjin_village_interactions.json"
const SENJIN_DIALOGUE_PATH := "res://03_GODOT/data/dialogue/pt_BR/campaign_senjin_village.json"
const DISPLAY_FONT_PATH := "res://01_ASSETS/kataklysma/ui/fonts/cinzel/cinzel_variable.ttf"

## First playable vertical slice for Kataklysma: Lust Shaman's Journey.
## Echo Isles is presented as a real navigable world: camera, scale, collisions,
## depth sorting, interaction, dialogue choices, CG, save/load and combat.

const VIEW_SIZE := Vector2(1280.0, 720.0)
const MAP_SIZE := Vector2(1672.0, 941.0)
const DEMO_VERSION := "0.1.0-demo"
const ZONE_ID := "echo_isles"
const ENCOUNTER_TABLE_ID := "echo_isles_day"
const MAP_TEXTURE := "res://01_ASSETS/kataklysma/maps/echo_isles/backgrounds/echo_isles_background_concept_v001.png"
const CABIN_TEXTURE_CANDIDATE := "res://01_ASSETS/kataklysma/maps/echo_isles/interiors/CANDIDATE/echo_isles_cabin_interior_candidate_v001.png"
const SENJIN_FOREGROUND_CANDIDATE := "res://01_ASSETS/kataklysma/maps/senjin_village/foregrounds/senjin_foreground_vegetation_candidate_v001.png"
const PLAYER_IDLE_DIR := "res://01_ASSETS/kataklysma/sprites/idle"
const PLAYER_WALK_DIR := "res://01_ASSETS/kataklysma/sprites/walk"
const NPC_ID := "zekranu"
const NPC_IDLE_DIR := "res://01_ASSETS/kataklysma/sprites/npcs/zekranu/IDLE"
const NPC_WALK_DIR := "res://01_ASSETS/kataklysma/sprites/npcs/zekranu/WALK"
const ENTITY_IDLE_DIR := "res://01_ASSETS/kataklysma/character/entities/sprites/corrupted_makrura/IDLE"
const ENTITY_COMBAT_DIR := "res://01_ASSETS/kataklysma/character/entities/sprites/corrupted_makrura/COMBAT"
const WATER_SPIRIT_IDLE_DIR := "res://01_ASSETS/kataklysma/character/entities/sprites/weakened_water_spirit/IDLE"
const WILD_BOAR_CANDIDATE := "res://01_ASSETS/kataklysma/character/entities/sprites/wild_boar/CANDIDATE/entity_wild_boar_candidate_v002.png"
const PLAYER_PORTRAIT := "res://01_ASSETS/kataklysma/ui/portraits/neutral/kataklysma_portrait_neutral.png"
const NPC_PORTRAIT := "res://01_ASSETS/kataklysma/ui/portraits/neutral/zekranu_portrait_dedicated_v002.png"
const DIRECTIONAL_DIR := "res://01_ASSETS/kataklysma/sprites/directional"
const NPC_SPRITE_ROOT := "res://01_ASSETS/kataklysma/sprites/npcs"
const CHILDREN_SPRITE_CANDIDATE := "res://01_ASSETS/kataklysma/sprites/npcs/children/CANDIDATE/npc_echo_children_candidate_sheet_v001.png"
const APPRENTICE_SPRITE_CANDIDATE := "res://01_ASSETS/kataklysma/sprites/npcs/apprentice/CANDIDATE/npc_apprentice_candidate_v001.png"
const CAMPAIGN_PROP_SHEET_CANDIDATE := "res://01_ASSETS/kataklysma/static_objects/CANDIDATE/echo_isles_quest_props_candidate_sheet_v001.png"
const CAMPAIGN_PROP_CELL_SIZE := Vector2(280.4, 280.5)
const CAMPAIGN_PROP_INDEX := {
    "heirloom_necklace":0, "ritual_bowl":1, "coin_pouch":2, "earth_totem":3, "fire_totem":4,
    "water_totem":5, "air_totem":6, "boar_tracks":7, "rope_snare":8, "boar_meat":9,
    "live_frog":10, "reagent_basket":11, "dead_fish":12, "contamination_vial":13,
    "conductive_pool":14, "makrura_eggs":15, "ritual_stone":16, "broken_totem":17,
    "travel_pack":18, "outrigger_boat":19,
}
const QUEST_MARKERS := {
    "available": "res://01_ASSETS/kataklysma/ui/markers/quest_available.svg",
    "in_progress": "res://01_ASSETS/kataklysma/ui/markers/quest_in_progress.svg",
    "complete": "res://01_ASSETS/kataklysma/ui/markers/quest_complete.svg",
}
const RANDOM_NPC_DATA := {
    "zalkiri": {"name":"Zalkiri", "path":"res://01_ASSETS/kataklysma/sprites/npcs/zalkiri"},
    "rakjin": {"name":"Rak'jin", "path":"res://01_ASSETS/kataklysma/sprites/npcs/rakjin"},
    "makjala": {"name":"Mak'Jala", "path":"res://01_ASSETS/kataklysma/sprites/npcs/makjala"},
}
const CAMPAIGN_NPC_SPRITE_DATA := {
    "mokjala": {"name":"Mok’Jala", "folder":"mokjala"},
    "zalkiri": {"name":"Zal’Kiri", "folder":"zalkiri"},
    "tazrima": {"name":"Taz’Rima", "folder":"tazrima"},
    "rukka": {"name":"Ruk’ka", "folder":"rukka"},
    "makjala": {"name":"Mak’Jala", "folder":"makjala"},
    "rakjin": {"name":"Rak’jin", "folder":"rakjin"},
}

var player: AnimatedSprite2D
var npc: AnimatedSprite2D
var player_collision_body: CharacterBody2D
var world_entities: Node2D
var world_background: Sprite2D
var senjin_foreground: Sprite2D
var world_tint: ColorRect
var collision_world_bodies: Array[PhysicsBody2D] = []
var zone_map: Variant
var npc_collision_body: StaticBody2D
var npc_interaction_area: Area2D
var camera: Camera2D
var quest_marker: Sprite2D
var random_resource_marker: Label
var objective_marker: Label
var player_name: Label
var npc_name: Label
var quest_state_label: Label
var region_title_label: Label
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
var encounter_rng := RandomNumberGenerator.new()
var combat_system: RefCounted
var audio_manager: Node
var combat_player_sprite: AnimatedSprite2D
var combat_enemy_sprite: AnimatedSprite2D
var combat_player_bar: ProgressBar
var combat_enemy_bar: ProgressBar
var combat_enemy_name_label: Label
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
var options_menu: Variant
var continue_button: Button
var minimap_player_dot: Label
var minimap_quest_dot: Label
var minimap_objective_dot: Label
var minimap_resource_dot: Label
var minimap_panel: ColorRect
var minimap_texture: TextureRect
var minimap_title_label: Label
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
var npc_routine_index := 0
var npc_routine_wait := 2.0

var quest_runtime: Variant
var campaign_runtime: Variant
var campaign_world_runtime: Variant
var campaign_definition: Dictionary = {}
var campaign_interaction_data: Dictionary = {}
var campaign_dialogue_data: Dictionary = {}
var campaign_point_nodes: Dictionary = {}
var campaign_prop_nodes: Dictionary = {}
var campaign_actor_nodes: Dictionary = {}
var campaign_actor_name_nodes: Dictionary = {}
var campaign_dialogue_context: Dictionary = {}
var campaign_pending_encounter: Dictionary = {}
var campaign_mode := false
var campaign_scene_id := "echo_isles"
var player_base_scale := 0.22
var player_frame_geometry: Dictionary = {}
var player_side_reference_height := 0.0
var player_reference_floor_offset := 0.0
var active_zone_id := "echo_isles"
var active_map_texture_path := MAP_TEXTURE
var active_encounter_table_id := ENCOUNTER_TABLE_ID
var active_zone_display_name := "Echo Isles"
var campaign_branch_input_active := false
var campaign_capture_index := 0
var campaign_cg_followup_quest := ""
var quest_states_data: Dictionary = {}
var quest_dialogue_data: Dictionary = {}
var event_dialogue_data: Dictionary = {}
var walkability_data: Dictionary = {}
var CALIBRATION: Dictionary = {}
var save_path := SAVE_PATH
var save_path_override := ""
var options_settings_path_override := ""
var random_event_npc: AnimatedSprite2D
var random_event_npc_direction := Vector2.ZERO
var random_event_npc_time := 0.0
var random_resource_data: Dictionary = {}
var resources_collected := 0

var quest_state: String:
    get:
        return quest_runtime.get_state() if quest_runtime else "available"
    set(value):
        if quest_runtime:
            quest_runtime.restore(value)
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
const CABIN_EXIT_SPAWN := Vector2(784.0, 336.0)
const OBJECTIVE_POSITION := Vector2(600.0, 535.0)
const MOVE_SPEED := 190.0
const NPC_MOVE_SPEED := 34.0
const NPC_ROUTE := [
    Vector2(806.0, 362.0),
    Vector2(820.0, 344.0),
    Vector2(844.0, 345.0),
    Vector2(858.0, 366.0),
    Vector2(842.0, 382.0),
    Vector2(816.0, 382.0),
]
const WALKABILITY_FOOT_PROBES := [Vector2.ZERO, Vector2(-10.0, -5.0), Vector2(10.0, -5.0), Vector2(-10.0, 5.0), Vector2(10.0, 5.0)]
const SAVE_PATH := "user://kataklysma_echo_isles_demo.json"
var WALKABLE_POLYGONS: Array[PackedVector2Array] = []
var WALKABLE_REGIONS: Array[PackedVector2Array] = WALKABLE_POLYGONS
var WALKABILITY_BLOCK_POLYGONS: Array[PackedVector2Array] = []
var WALKABILITY_BLOCK_IDS: Array[String] = []
const COLLISION_RECT_DATA := [
    {"position": Vector2(MAP_SIZE.x * 0.5, 48.0), "size": Vector2(MAP_SIZE.x, 96.0)},
    {"position": Vector2(MAP_SIZE.x * 0.5, MAP_SIZE.y - 38.0), "size": Vector2(MAP_SIZE.x, 76.0)},
    {"position": Vector2(38.0, MAP_SIZE.y * 0.5), "size": Vector2(76.0, MAP_SIZE.y)},
    {"position": Vector2(MAP_SIZE.x - 38.0, MAP_SIZE.y * 0.5), "size": Vector2(76.0, MAP_SIZE.y)},
    {"position": NPC_POSITION + Vector2(0.0, 30.0), "size": Vector2(46.0, 24.0)},
]
const CG_VARIANTS := [
    "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_002_zekranu_totem_choice__01_start_v002.png",
    "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_002_zekranu_totem_choice__02_development_v002.png",
    "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_002_zekranu_totem_choice__03_climax_v002.png",
    "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_002_zekranu_totem_choice__04_resolution_v002.png",
]
const CAMPAIGN_CG_VARIANTS := {
    "QST_ECHO_002": [
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_002_zekranu_totem_choice__01_start_v002.png",
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_002_zekranu_totem_choice__02_development_v002.png",
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_002_zekranu_totem_choice__03_climax_v002.png",
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_002_zekranu_totem_choice__04_resolution_v002.png",
    ],
    "QST_ECHO_003": [
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_003_zalkiri_mokjala_hunt__01_start_v002.png",
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_003_zalkiri_mokjala_hunt__02_development_v002.png",
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_003_zalkiri_mokjala_hunt__03_climax_v002.png",
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_003_zalkiri_mokjala_hunt__04_resolution_v002.png",
    ],
    "QST_ECHO_005": [
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_005_water_spirit_choice__01_start_v002.png",
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_005_water_spirit_choice__02_development_v002.png",
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_005_water_spirit_choice__03_climax_v002.png",
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_005_water_spirit_choice__04_resolution_v002.png",
    ],
    "QST_ECHO_006": [
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_006_corrupted_makrura_boss__01_start_v002.png",
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_006_corrupted_makrura_boss__02_development_v002.png",
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_006_corrupted_makrura_boss__03_climax_v002.png",
        "res://01_ASSETS/kataklysma/cg/scenes/VARIANTS/echo_006_corrupted_makrura_boss__04_resolution_v002.png",
    ],
}

func _ready() -> void:
    encounter_rng.randomize()
    if save_path_override != "":
        save_path = save_path_override
    quest_runtime = QuestStateRuntimeScript.new()
    campaign_runtime = CampaignQuestRuntimeScript.new()
    _load_phase_one_data()
    zone_map = ZoneMapScript.new()
    zone_map.zone_id = ZONE_ID
    add_child(zone_map)
    _load_walkability_geometry()
    _build_world()
    _build_hud()
    _build_encounter_manager()
    audio_manager = AudioManagerScript.new()
    audio_manager.name = "AudioManager"
    add_child(audio_manager)
    _build_cg_layer()
    _build_pause_menu()
    _build_main_menu()
    _build_options_menu()
    _set_quest_state("available")
    _set_gameplay_visible(false)

func _build_world() -> void:
    world_entities = Node2D.new()
    var entities_root := world_entities
    entities_root.name = "Entities"
    entities_root.y_sort_enabled = true
    add_child(entities_root)

    senjin_foreground = Sprite2D.new()
    senjin_foreground.name = "SenjinForegroundVegetationCandidate"
    senjin_foreground.texture = load(SENJIN_FOREGROUND_CANDIDATE)
    senjin_foreground.position = Vector2(120.0, 570.0)
    senjin_foreground.offset = Vector2(0.0, -25.0)
    senjin_foreground.scale = Vector2.ONE * 0.08
    senjin_foreground.z_index = 5
    senjin_foreground.visible = false
    entities_root.add_child(senjin_foreground)

    world_background = Sprite2D.new()
    world_background.name = "EchoIslesBackground"
    world_background.texture = load(MAP_TEXTURE)
    world_background.position = MAP_SIZE * 0.5
    world_background.z_index = -20
    add_child(world_background)

    world_tint = ColorRect.new()
    world_tint.name = "WorldReadabilityTint"
    world_tint.color = Color(0.04, 0.02, 0.08, 0.22)
    world_tint.position = Vector2.ZERO
    world_tint.size = MAP_SIZE
    world_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    world_tint.z_index = -19
    add_child(world_tint)

    player = _make_actor("Kataklysma", PLAYER_IDLE_DIR, PLAYER_WALK_DIR, "kataklysma")
    player.position = PLAYER_START
    var actor_scale := float(CALIBRATION.get("player_scale", 0.22))
    player_base_scale = actor_scale
    player.scale = Vector2.ONE * actor_scale
    player.z_index = 5
    entities_root.add_child(player)
    _cache_player_frame_geometry()
    player.animation_changed.connect(_apply_player_frame_calibration)
    player.frame_changed.connect(_apply_player_frame_calibration)
    player.play("idle")
    _apply_player_frame_calibration()
    last_position = player.position

    camera = Camera2D.new()
    camera.name = "Camera2D"
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 7.0
    var camera_zoom: Array = CALIBRATION.get("camera_zoom", [1.18, 1.18])
    camera.zoom = Vector2(float(camera_zoom[0]), float(camera_zoom[1]))
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
    var foot_shape: Array = CALIBRATION.get("player_foot_shape", [20.0, 12.0])
    player_shape.size = Vector2(float(foot_shape[0]), float(foot_shape[1]))
    var foot_offset: Array = CALIBRATION.get("player_foot_offset", [0.0, 48.0])
    player_collision_shape.position = Vector2(float(foot_offset[0]), float(foot_offset[1]))
    player_collision_shape.shape = player_shape
    player_collision_shape.name = "PlayerFootCollider"
    player_collision_body.add_child(player_collision_shape)
    add_child(player_collision_body)
    _build_collision_world()

    walkability_debug = WalkabilityDebugScript.new()
    walkability_debug.name = "WalkabilityDebugOverlay"
    walkability_debug.z_index = 40
    walkability_debug.configure(WALKABLE_POLYGONS, _collision_rects_for_debug(), WALKABILITY_BLOCK_POLYGONS, WALKABILITY_BLOCK_IDS, MAP_SIZE)
    walkability_debug.visible = false
    add_child(walkability_debug)

    npc = _make_actor("Zekranu", NPC_IDLE_DIR, NPC_WALK_DIR, "npc_%s" % NPC_ID)
    npc.position = NPC_POSITION
    npc.scale = Vector2.ONE * float(CALIBRATION.get("npc_scale", actor_scale))
    npc.z_index = 5
    entities_root.add_child(npc)
    npc.play("idle")

    npc_interaction_area = Area2D.new()
    npc_interaction_area.name = "InteractionArea_Zekranu"
    npc_interaction_area.position = NPC_POSITION
    npc_interaction_area.collision_layer = 0
    npc_interaction_area.collision_mask = 0
    var npc_area_shape := CollisionShape2D.new()
    var npc_circle := CircleShape2D.new()
    npc_circle.radius = float(CALIBRATION.get("interaction_radius", 125.0))
    npc_area_shape.shape = npc_circle
    npc_interaction_area.add_child(npc_area_shape)
    add_child(npc_interaction_area)

    quest_marker = Sprite2D.new()
    quest_marker.name = "QuestMarker_Zekranu"
    quest_marker.position = NPC_POSITION + Vector2(0.0, float(CALIBRATION.get("quest_marker_offset_y", -116.0)))
    quest_marker.scale = Vector2(0.62, 0.62)
    quest_marker.z_index = 12
    entities_root.add_child(quest_marker)

    npc_name = _make_world_label("Zek'Ranu\nMentor Xamã", NPC_POSITION + Vector2(-52.0, 64.0), 13, Color("#ffe7a6"))
    npc_name.visible = false
    entities_root.add_child(npc_name)
    player_name = _make_world_label("", PLAYER_START, 1, Color.TRANSPARENT)
    player_name.visible = false
    entities_root.add_child(player_name)

    objective_marker = _make_world_label("◈  MARÉ CORROMPIDA\n    objetivo da quest", OBJECTIVE_POSITION + Vector2(-120.0, -92.0), 14, Color("#91d7ff"))
    objective_marker.visible = false
    entities_root.add_child(objective_marker)
    random_resource_marker = _make_world_label("✧  RECURSO", Vector2.ZERO, 13, Color("#b7f5c8"))
    random_resource_marker.name = "RandomResourceMarker"
    random_resource_marker.visible = false
    entities_root.add_child(random_resource_marker)

    var camp_label := _make_world_label("", Vector2.ZERO, 1, Color.TRANSPARENT)
    camp_label.visible = false
    entities_root.add_child(camp_label)
    _build_campaign_interaction_nodes(entities_root)

func _build_campaign_interaction_nodes(entities_root: Node2D) -> void:
    campaign_point_nodes.clear()
    campaign_prop_nodes.clear()
    campaign_actor_nodes.clear()
    campaign_actor_name_nodes.clear()
    if campaign_interaction_data.is_empty():
        return
    var dialogue_entries: Dictionary = campaign_dialogue_data.get("interactions", {})
    var speakers: Dictionary = {}
    for point_value in campaign_interaction_data.get("points", []):
        var point: Dictionary = point_value
        var point_id := str(point.get("id", ""))
        var position_data: Array = point.get("position", [0.0, 0.0])
        var point_position := Vector2(float(position_data[0]), float(position_data[1]))
        var marker_position := _campaign_marker_position(point, point_position)
        var dialogue: Dictionary = dialogue_entries.get(str(point.get("dialogue_key", "")), {})
        var marker_text := "◇  %s" % str(dialogue.get("label", point_id))
        var marker := _make_world_label(marker_text, _campaign_label_position(marker_position), 13, Color("#ffe7a6"))
        marker.size = Vector2(300.0, 28.0)
        marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        marker.name = "CampaignPoint_%s" % point_id
        marker.visible = false
        entities_root.add_child(marker)
        campaign_point_nodes[point_id] = marker
        var prop_nodes: Array[Node2D] = []
        for prop_id_value in point.get("prop_ids", []):
            var prop_id := str(prop_id_value)
            if not CAMPAIGN_PROP_INDEX.has(prop_id):
                push_warning("Campaign point %s references unknown prop %s." % [point_id, prop_id])
                continue
            var prop_sheet: Texture2D = load(CAMPAIGN_PROP_SHEET_CANDIDATE)
            if prop_sheet == null:
                push_warning("Campaign prop candidate sheet is missing: %s" % CAMPAIGN_PROP_SHEET_CANDIDATE)
                continue
            var cell_index := int(CAMPAIGN_PROP_INDEX[prop_id])
            var prop_atlas := AtlasTexture.new()
            prop_atlas.atlas = prop_sheet
            prop_atlas.region = Rect2((cell_index % 5) * CAMPAIGN_PROP_CELL_SIZE.x, floori(float(cell_index) / 5.0) * CAMPAIGN_PROP_CELL_SIZE.y, CAMPAIGN_PROP_CELL_SIZE.x, CAMPAIGN_PROP_CELL_SIZE.y)
            prop_atlas.filter_clip = true
            var prop_root := Node2D.new()
            prop_root.name = "CampaignProp_%s_%s" % [point_id, prop_id]
            prop_root.z_index = 5
            prop_root.visible = false
            var prop_sprite := Sprite2D.new()
            prop_sprite.texture = prop_atlas
            prop_sprite.scale = Vector2.ONE * 0.22
            prop_sprite.position = Vector2(0.0, -CAMPAIGN_PROP_CELL_SIZE.y * 0.22 * 0.42)
            prop_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
            prop_root.add_child(prop_sprite)
            entities_root.add_child(prop_root)
            prop_nodes.append(prop_root)
        campaign_prop_nodes[point_id] = prop_nodes
        var speaker_id := str(point.get("speaker", ""))
        if not speaker_id.is_empty():
            speakers[speaker_id] = true
    for speaker_id in speakers:
        _ensure_campaign_actor(str(speaker_id), entities_root)

func _ensure_campaign_actor(speaker_id: String, entities_root: Node2D) -> void:
    if campaign_actor_nodes.has(speaker_id):
        return
    if speaker_id == "zekranu":
        campaign_actor_nodes[speaker_id] = [npc]
        campaign_actor_name_nodes[speaker_id] = [npc_name]
        npc_name.text = "Zek’Ranu\nMentor Xamã"
        return
    var actors: Array[AnimatedSprite2D] = []
    var labels: Array[Label] = []
    if CAMPAIGN_NPC_SPRITE_DATA.has(speaker_id):
        var info: Dictionary = CAMPAIGN_NPC_SPRITE_DATA[speaker_id]
        var folder := str(info.get("folder", speaker_id))
        var root := "%s/%s" % [NPC_SPRITE_ROOT, folder]
        var actor := _make_actor(str(info.get("name", speaker_id)), "%s/IDLE" % root, "%s/WALK" % root, "npc_%s" % folder)
        actor.name = "CampaignNPC_%s" % speaker_id
        actor.scale = Vector2.ONE * float(CALIBRATION.get("npc_scale", 0.26))
        actor.z_index = 5
        entities_root.add_child(actor)
        actors.append(actor)
        var actor_label := _make_world_label(str(info.get("name", speaker_id)), Vector2.ZERO, 13, Color("#ffe7a6"))
        actor_label.visible = false
        entities_root.add_child(actor_label)
        labels.append(actor_label)
    elif speaker_id == "water_spirit":
        var spirit := _make_entity_actor("water_spirit_weakened")
        spirit.name = "CampaignNPC_WaterSpirit"
        spirit.scale = Vector2.ONE * 0.28
        spirit.z_index = 5
        entities_root.add_child(spirit)
        actors.append(spirit)
        var spirit_label := _make_world_label("Espírito da Água", Vector2.ZERO, 13, Color("#91d7ff"))
        spirit_label.visible = false
        entities_root.add_child(spirit_label)
        labels.append(spirit_label)
    elif speaker_id == "apprentice":
        var apprentice_texture: Texture2D = load(APPRENTICE_SPRITE_CANDIDATE)
        var apprentice := _make_static_campaign_actor("CampaignNPC_Apprentice", apprentice_texture, Rect2(540.0, 10.0, 500.0, 1000.0), 0.10)
        if apprentice:
            entities_root.add_child(apprentice)
            actors.append(apprentice)
            var apprentice_label := _make_world_label("Aprendiz de Taz’Rima • candidato", Vector2.ZERO, 11, Color("#ffe7a6"))
            apprentice_label.visible = false
            entities_root.add_child(apprentice_label)
            labels.append(apprentice_label)
    elif speaker_id == "children":
        var children_texture: Texture2D = load(CHILDREN_SPRITE_CANDIDATE)
        var boy := _make_static_campaign_actor("CampaignNPC_ChildBoy", children_texture, Rect2(270.0, 5.0, 500.0, 1010.0), 0.10)
        var girl := _make_static_campaign_actor("CampaignNPC_ChildGirl", children_texture, Rect2(870.0, 35.0, 470.0, 970.0), 0.10)
        for child_actor in [boy, girl]:
            if child_actor:
                entities_root.add_child(child_actor)
                actors.append(child_actor)
                var child_label := _make_world_label("Criança da ilha A • candidata" if actors.size() == 1 else "Criança da ilha B • candidata", Vector2.ZERO, 11, Color("#ffe7a6"))
                child_label.visible = false
                entities_root.add_child(child_label)
                labels.append(child_label)
    campaign_actor_nodes[speaker_id] = actors
    campaign_actor_name_nodes[speaker_id] = labels

func _make_static_campaign_actor(actor_name: String, source_texture: Texture2D, region: Rect2, actor_scale: float) -> AnimatedSprite2D:
    if source_texture == null:
        push_warning("Campaign character candidate is missing: %s" % actor_name)
        return null
    var atlas := AtlasTexture.new()
    atlas.atlas = source_texture
    atlas.region = region
    atlas.filter_clip = true
    var frames := SpriteFrames.new()
    if frames.has_animation("default"):
        frames.remove_animation("default")
    frames.add_animation("idle")
    frames.set_animation_speed("idle", 2.0)
    frames.set_animation_loop("idle", true)
    frames.add_frame("idle", atlas)
    var actor := AnimatedSprite2D.new()
    actor.name = actor_name
    actor.sprite_frames = frames
    actor.animation = &"idle"
    actor.scale = Vector2.ONE * actor_scale
    actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    actor.visible = false
    return actor

func _build_collision_world() -> void:
    for old_body in collision_world_bodies:
        if is_instance_valid(old_body):
            remove_child(old_body)
            old_body.queue_free()
    collision_world_bodies.clear()
    npc_collision_body = null
    for obstacle_index in range(4):
        var obstacle: Dictionary = COLLISION_RECT_DATA[obstacle_index]
        var body := StaticBody2D.new()
        var obstacle_position: Vector2 = obstacle["position"]
        body.name = "WalkableBoundary_%d" % obstacle_index
        body.collision_layer = 1
        body.collision_mask = 1
        body.position = obstacle_position
        collision_world_bodies.append(body)
        var shape_node := CollisionShape2D.new()
        var shape := RectangleShape2D.new()
        shape.size = obstacle["size"]
        shape_node.shape = shape
        body.add_child(shape_node)
        add_child(body)
    if active_zone_id == "echo_isles":
        var zekranu_blocker := StaticBody2D.new()
        zekranu_blocker.name = "NPCBlocker_Zekranu"
        zekranu_blocker.collision_layer = 1
        zekranu_blocker.collision_mask = 1
        zekranu_blocker.position = NPC_POSITION + Vector2(0.0, 30.0)
        collision_world_bodies.append(zekranu_blocker)
        var zekranu_shape_node := CollisionShape2D.new()
        var zekranu_shape := RectangleShape2D.new()
        zekranu_shape.size = Vector2(46.0, 24.0)
        zekranu_shape_node.shape = zekranu_shape
        zekranu_blocker.add_child(zekranu_shape_node)
        add_child(zekranu_blocker)
        npc_collision_body = zekranu_blocker
    for index in WALKABILITY_BLOCK_POLYGONS.size():
        var blocker := StaticBody2D.new()
        blocker.name = "WalkabilityBlocker_%s" % WALKABILITY_BLOCK_IDS[index]
        blocker.collision_layer = 1
        blocker.collision_mask = 1
        collision_world_bodies.append(blocker)
        var polygon_shape := CollisionPolygon2D.new()
        polygon_shape.name = "Footprint"
        polygon_shape.polygon = WALKABILITY_BLOCK_POLYGONS[index]
        blocker.add_child(polygon_shape)
        add_child(blocker)

func _load_phase_one_data() -> void:
    quest_dialogue_data = _read_json_dictionary("res://03_GODOT/data/dialogue/pt_BR/quest_01.json")
    quest_states_data = _read_json_dictionary("res://03_GODOT/data/quest_states.json")
    event_dialogue_data = _read_json_dictionary("res://03_GODOT/data/dialogue/pt_BR/encounters.json")
    if quest_dialogue_data.is_empty() or quest_states_data.is_empty() or event_dialogue_data.is_empty():
        push_error("Quest/localization runtime data is missing; refusing to silently use hard-coded strings.")
        return
    quest_runtime.configure(
        quest_states_data.get("quest_marker_states", {}),
        quest_states_data.get("state_transition", []),
        str(quest_dialogue_data.get("id", "prototype_echo_isles_tide_v001"))
    )
    campaign_definition = _read_json_dictionary(CAMPAIGN_DEFINITION_PATH)
    if campaign_definition.is_empty() or not campaign_runtime.configure(campaign_definition, attributes):
        push_error("Canonical Echo Isles campaign data failed validation; campaign integration is unavailable.")
        return
    campaign_interaction_data = _read_json_dictionary(CAMPAIGN_INTERACTIONS_PATH)
    campaign_dialogue_data = _read_json_dictionary(CAMPAIGN_DIALOGUE_PATH)
    var senjin_interactions := _read_json_dictionary(SENJIN_INTERACTIONS_PATH)
    var senjin_dialogue := _read_json_dictionary(SENJIN_DIALOGUE_PATH)
    if not senjin_interactions.is_empty() and not senjin_dialogue.is_empty():
        campaign_interaction_data["points"].append_array(senjin_interactions.get("points", []))
        for key in senjin_dialogue.get("interactions", {}):
            campaign_dialogue_data["interactions"][str(key)] = senjin_dialogue["interactions"][key]
        for key in senjin_dialogue.get("interaction_variants", {}):
            campaign_dialogue_data["interaction_variants"][str(key)] = senjin_dialogue["interaction_variants"][key]
        campaign_dialogue_data["senjin"] = senjin_dialogue
    campaign_world_runtime = CampaignWorldRuntimeScript.new()
    if campaign_interaction_data.is_empty() or campaign_dialogue_data.is_empty() or not campaign_world_runtime.configure(campaign_interaction_data, campaign_runtime):
        push_error("Canonical Echo Isles interaction graph failed validation; campaign start is disabled.")

func _reset_campaign_runtime() -> void:
    if campaign_runtime and not campaign_definition.is_empty():
        if not campaign_runtime.configure(campaign_definition, attributes):
            push_error("Canonical Echo Isles campaign state could not be reset.")

func _read_json_dictionary(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Could not open data file: %s" % path)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary:
        push_error("Invalid JSON dictionary: %s" % path)
        return {}
    return parsed

func _load_walkability_geometry() -> void:
    walkability_data = zone_map.get_walkability_data()
    CALIBRATION = walkability_data.get("calibration", {})
    WALKABLE_POLYGONS.clear()
    WALKABILITY_BLOCK_POLYGONS.clear()
    WALKABILITY_BLOCK_IDS.clear()
    for item in walkability_data.get("walkable_regions", []):
        WALKABLE_POLYGONS.append(_polygon_from_data(item.get("points", [])))
    for item in walkability_data.get("blockers", []):
        WALKABILITY_BLOCK_IDS.append(str(item.get("id", "unnamed")))
        WALKABILITY_BLOCK_POLYGONS.append(_polygon_from_data(item.get("points", [])))
    WALKABLE_REGIONS = WALKABLE_POLYGONS
    if WALKABLE_POLYGONS.is_empty():
        push_error("Zone %s has no walkable regions; the player must not move." % active_zone_id)

func _polygon_from_data(points: Array) -> PackedVector2Array:
    var polygon := PackedVector2Array()
    for point in points:
        if point is Array and point.size() >= 2:
            polygon.append(Vector2(float(point[0]), float(point[1])))
    return polygon

func _quest_text(key: String, fallback := "") -> String:
    return str(quest_dialogue_data.get(key, fallback))

func _collision_rects_for_debug() -> Array[Rect2]:
    var rects: Array[Rect2] = []
    for obstacle_index in range(COLLISION_RECT_DATA.size()):
        if obstacle_index == 4 and active_zone_id != "echo_isles":
            continue
        var obstacle: Dictionary = COLLISION_RECT_DATA[obstacle_index]
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

func _cache_player_frame_geometry() -> void:
    player_frame_geometry.clear()
    player_side_reference_height = 0.0
    if not player or not player.sprite_frames:
        return
    for animation_name in player.sprite_frames.get_animation_names():
        var animation_frames: Array[Dictionary] = []
        for frame_index in range(player.sprite_frames.get_frame_count(animation_name)):
            var texture := player.sprite_frames.get_frame_texture(animation_name, frame_index)
            if not texture:
                animation_frames.append({})
                continue
            var image := texture.get_image()
            var used_rect := image.get_used_rect() if image else Rect2i(Vector2i.ZERO, Vector2i(texture.get_size()))
            if used_rect.size == Vector2i.ZERO:
                used_rect = Rect2i(Vector2i.ZERO, Vector2i(texture.get_size()))
            animation_frames.append({"rect":used_rect, "texture_size":texture.get_size()})
            if animation_name in [&"idle_left", &"idle_right", &"walk_left", &"walk_right"]:
                player_side_reference_height = maxf(player_side_reference_height, float(used_rect.size.y))
        player_frame_geometry[str(animation_name)] = animation_frames
    var reference_frames: Array = player_frame_geometry.get("idle_front", [])
    if reference_frames.is_empty():
        reference_frames = player_frame_geometry.get("idle", [])
    if not reference_frames.is_empty() and not reference_frames[0].is_empty():
        var reference_rect: Rect2i = reference_frames[0]["rect"]
        var reference_size: Vector2 = reference_frames[0]["texture_size"]
        player_reference_floor_offset = float(CALIBRATION.get("player_scale", 0.22)) * (float(reference_rect.end.y) - reference_size.y * 0.5)

func _apply_player_frame_calibration() -> void:
    if not is_instance_valid(player) or not player.sprite_frames:
        return
    var animation_name := str(player.animation)
    var animation_frames: Array = player_frame_geometry.get(animation_name, [])
    if player.frame < 0 or player.frame >= animation_frames.size() or animation_frames[player.frame].is_empty():
        player.scale = Vector2.ONE * player_base_scale
        player.offset = Vector2.ZERO
        return
    var frame_geometry: Dictionary = animation_frames[player.frame]
    var used_rect: Rect2i = frame_geometry["rect"]
    var texture_size: Vector2 = frame_geometry["texture_size"]
    var frame_factor := 1.0
    if animation_name in ["idle_left", "idle_right", "walk_left", "walk_right"] and used_rect.size.y > 0:
        frame_factor = player_side_reference_height / float(used_rect.size.y)
    var effective_scale := player_base_scale * frame_factor
    player.scale = Vector2.ONE * effective_scale
    var frame_floor_offset := float(used_rect.end.y) - texture_size.y * 0.5
    player.offset = Vector2(0.0, player_reference_floor_offset / effective_scale - frame_floor_offset)

func _build_hud() -> void:
    var hud := CanvasLayer.new()
    hud.name = "DemoHUD"
    gameplay_hud = hud
    add_child(hud)

    var top_bar := ColorRect.new()
    top_bar.color = Color(0.035, 0.02, 0.08, 0.86)
    top_bar.position = Vector2(24.0, 24.0)
    top_bar.size = Vector2(720.0, 70.0)
    top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(top_bar)

    region_title_label = Label.new()
    region_title_label.position = Vector2(20.0, 9.0)
    region_title_label.text = "ECHO ISLES"
    region_title_label.add_theme_font_size_override("font_size", 18)
    region_title_label.add_theme_color_override("font_color", Color("#ffe7a6"))
    top_bar.add_child(region_title_label)

    quest_state_label = Label.new()
    quest_state_label.position = Vector2(20.0, 39.0)
    quest_state_label.size = Vector2(680.0, 25.0)
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
    interaction_prompt.position = Vector2(350.0, 548.0)
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
    minimap_texture = TextureRect.new()
    minimap_texture.position = Vector2(10.0, 30.0)
    minimap_texture.size = Vector2(190.0, 107.0)
    minimap_texture.texture = load(MAP_TEXTURE)
    minimap_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    minimap_texture.stretch_mode = TextureRect.STRETCH_SCALE
    minimap_texture.modulate = Color(0.78, 0.86, 0.9, 0.9)
    minimap_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
    minimap_panel.add_child(minimap_texture)
    var minimap_tint := ColorRect.new()
    minimap_tint.position = minimap_texture.position
    minimap_tint.size = minimap_texture.size
    minimap_tint.color = Color(0.015, 0.035, 0.055, 0.26)
    minimap_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    minimap_panel.add_child(minimap_tint)
    minimap_title_label = Label.new()
    minimap_title_label.position = Vector2(12.0, 8.0)
    minimap_title_label.text = "ECHO ISLES  •  MAPA"
    minimap_title_label.add_theme_font_size_override("font_size", 12)
    minimap_title_label.add_theme_color_override("font_color", Color("#d5f4ff"))
    minimap_panel.add_child(minimap_title_label)
    minimap_player_dot = _make_minimap_dot("●", Color("#d9f1ff"))
    minimap_quest_dot = _make_minimap_dot("!", Color("#f6d365"))
    minimap_objective_dot = _make_minimap_dot("◇", Color("#91d7ff"))
    minimap_resource_dot = _make_minimap_dot("✧", Color("#b7f5c8"))
    minimap_panel.add_child(minimap_player_dot)
    minimap_panel.add_child(minimap_quest_dot)
    minimap_panel.add_child(minimap_objective_dot)
    minimap_panel.add_child(minimap_resource_dot)
    var minimap_legend := Label.new()
    minimap_legend.position = Vector2(12.0, 143.0)
    minimap_legend.size = Vector2(190.0, 22.0)
    minimap_legend.text = "● você   ! quest   ◇ objetivo   ✧ recurso"
    minimap_legend.add_theme_font_size_override("font_size", 9)
    minimap_legend.add_theme_color_override("font_color", Color("#d5f4ff"))
    minimap_panel.add_child(minimap_legend)

    dialogue_panel = ColorRect.new()
    dialogue_panel.position = Vector2(120.0, 435.0)
    dialogue_panel.size = Vector2(1040.0, 235.0)
    dialogue_panel.color = Color(0.035, 0.025, 0.08, 0.94)
    dialogue_panel.visible = false
    hud.add_child(dialogue_panel)

    dialogue_title = Label.new()
    dialogue_title.position = Vector2(180.0, 16.0)
    dialogue_title.add_theme_font_size_override("font_size", 21)
    dialogue_title.add_theme_font_override("font", load(DISPLAY_FONT_PATH))
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
    dialogue_hint.text = "%s  confirmar" % _interaction_key_label()
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

    combat_enemy_name_label = Label.new()
    combat_enemy_name_label.position = Vector2(590.0, 235.0)
    combat_enemy_name_label.text = "MAKRURA CORROMPIDA"
    combat_enemy_name_label.add_theme_font_size_override("font_size", 16)
    combat_enemy_name_label.add_theme_color_override("font_color", Color("#ffb4c4"))
    encounter_panel.add_child(combat_enemy_name_label)

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
    encounter_hint.visible = false
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
    title.add_theme_font_override("font", load(DISPLAY_FONT_PATH))
    title.add_theme_color_override("font_color", Color("#ffe7a6"))
    menu_layer.add_child(title)

    var subtitle := Label.new()
    subtitle.position = Vector2(82.0, 182.0)
    subtitle.text = "Uma jornada jogável pelas Ilhas do Eco"
    subtitle.add_theme_font_size_override("font_size", 15)
    subtitle.add_theme_color_override("font_color", Color("#d5f4ff"))
    menu_layer.add_child(subtitle)

    _add_menu_button("NOVO JOGO", Vector2(82.0, 288.0), Callable(self, "_start_campaign_game"))
    continue_button = _add_menu_button("CONTINUAR", Vector2(82.0, 340.0), Callable(self, "_continue_game"))
    _refresh_continue_button()
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
    button.focus_mode = Control.FOCUS_ALL
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
    title.add_theme_font_override("font", load(DISPLAY_FONT_PATH))
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

func _build_options_menu() -> void:
    options_menu = OptionsMenuScript.new()
    options_menu.name = "OptionsMenu"
    if options_settings_path_override != "":
        options_menu.settings_path = options_settings_path_override
    options_menu.settings_changed.connect(_on_options_settings_changed)
    options_menu.closed.connect(_on_options_closed)
    add_child(options_menu)
    _on_options_settings_changed(options_menu.settings)

func _on_options_settings_changed(settings: Dictionary) -> void:
    if minimap_panel:
        minimap_panel.visible = bool(settings.get("show_minimap", true))
    if camera:
        camera.position_smoothing_enabled = bool(settings.get("camera_smoothing", true))
    if tutorial_label and options_menu:
        var bindings: Dictionary = options_menu.key_values
        var left := _physical_key_label(int(bindings.get(&"move_left", KEY_A)))
        var right := _physical_key_label(int(bindings.get(&"move_right", KEY_D)))
        var up := _physical_key_label(int(bindings.get(&"move_up", KEY_W)))
        var down := _physical_key_label(int(bindings.get(&"move_down", KEY_S)))
        tutorial_label.text = "%s / %s / %s / %s ou SETAS\nMover Kataklysma" % [left, right, up, down]

func _interaction_key_label() -> String:
    if options_menu and options_menu.key_values is Dictionary:
        return _physical_key_label(int(options_menu.key_values.get(&"interact", KEY_E)))
    return "E"

func _pause_key_label() -> String:
    if options_menu and options_menu.key_values is Dictionary:
        return _physical_key_label(int(options_menu.key_values.get(&"pause", KEY_ESCAPE)))
    return "ESC"

func _physical_key_label(key_code: int) -> String:
    return OS.get_keycode_string(key_code)

func _on_options_closed() -> void:
    if paused:
        _refresh_pause_info()

func _open_options_menu() -> void:
    if options_menu:
        options_menu.open_menu()

func _set_gameplay_visible(visible: bool) -> void:
    if gameplay_hud:
        gameplay_hud.visible = visible
    if not visible and pause_layer:
        pause_layer.visible = false
    world_started = visible

func _start_new_game() -> void:
    # Retained as an isolated regression route for the Phase 1 prototype tests.
    # The public menu starts the canonical Echo Isles campaign below.
    _reset_demo()
    _set_gameplay_visible(true)
    menu_layer.visible = false
    if options_menu:
        options_menu.visible = false
    tutorial_label.modulate.a = 1.0
    tutorial_label.visible = not story_flags.get("tutorial_movement_seen", false)
    tutorial_time = 0.0
    audio_manager.start_ambience()
    audio_manager.play_ui("menu_select")
    _show_toast("Echo Isles • explore uma maré corrompida", 3.0)

func _start_campaign_game() -> void:
    if campaign_world_runtime == null or campaign_definition.is_empty():
        _show_toast("A campanha canônica ainda não está pronta para iniciar.", 4.0)
        return
    _reset_demo()
    campaign_mode = true
    if not campaign_runtime.accept_quest("QST_ECHO_001"):
        _show_toast("Não foi possível iniciar QST_ECHO_001.", 4.0)
        return
    _set_gameplay_visible(true)
    menu_layer.visible = false
    if options_menu:
        options_menu.visible = false
    paused = false
    tutorial_label.modulate.a = 1.0
    tutorial_label.visible = not story_flags.get("tutorial_movement_seen", false)
    tutorial_time = 0.0
    campaign_dialogue_context.clear()
    campaign_scene_id = "cabin"
    _set_campaign_scene("cabin", Vector2(835.0, 555.0))
    _refresh_campaign_world()
    audio_manager.start_ambience()
    audio_manager.play_ui("menu_select")
    _campaign_show_custom_dialogue("Despertar • fragmentos de sonho", "A água sobe por uma escada impossível. Quatro vozes chamam seu nome; uma quinta permanece em silêncio. Kataklysma desperta na cabana antes do amanhecer.", "campaign_ack", "")
    _save_game()

func _set_campaign_scene(scene_id: String, spawn_position := Vector2(-1.0, -1.0)) -> void:
    campaign_scene_id = scene_id
    var in_cabin := scene_id == "cabin"
    var target_zone_id := "senjin_village" if scene_id in ["senjin_village", "departure_complete"] else "echo_isles"
    if zone_map and target_zone_id != active_zone_id:
        if not zone_map.set_zone_id(target_zone_id):
            push_error("Could not switch the runtime world to zone %s." % target_zone_id)
            return
        active_zone_id = target_zone_id
        active_map_texture_path = zone_map.get_background_asset()
        active_encounter_table_id = zone_map.get_random_encounter_table()
        active_zone_display_name = str(zone_map.zone_data.get("display_name", target_zone_id))
        _load_walkability_geometry()
        _build_collision_world()
        if walkability_debug:
            walkability_debug.configure(WALKABLE_POLYGONS, _collision_rects_for_debug(), WALKABILITY_BLOCK_POLYGONS, WALKABILITY_BLOCK_IDS, MAP_SIZE)
        random_resource_data.clear()
        if random_resource_marker:
            random_resource_marker.visible = false
    if world_background:
        world_background.texture = load(CABIN_TEXTURE_CANDIDATE) if in_cabin else load(active_map_texture_path)
        world_background.position = MAP_SIZE * 0.5
        if in_cabin:
            world_background.scale = Vector2(MAP_SIZE.x / 1536.0, MAP_SIZE.y / 1024.0)
        elif world_background.texture:
            var texture_size := world_background.texture.get_size()
            world_background.scale = Vector2(MAP_SIZE.x / texture_size.x, MAP_SIZE.y / texture_size.y)
    if senjin_foreground:
        senjin_foreground.visible = active_zone_id == "senjin_village" and not in_cabin
    if world_tint:
        world_tint.color = Color(0.025, 0.015, 0.035, 0.12) if in_cabin else Color(0.04, 0.02, 0.08, 0.22) if active_zone_id == "echo_isles" else Color(0.035, 0.025, 0.02, 0.08)
    for body in collision_world_bodies:
        body.collision_layer = 0 if in_cabin else 1
        body.collision_mask = 0 if in_cabin else 1
    if player:
        var outdoor_player_scale := float(CALIBRATION.get("player_scale", 0.22))
        player_base_scale = float(CALIBRATION.get("cabin_player_scale", outdoor_player_scale)) if in_cabin else outdoor_player_scale
        _apply_player_frame_calibration()
    if player_collision_body:
        var foot_collider := player_collision_body.get_node_or_null("PlayerFootCollider") as CollisionShape2D
        if foot_collider and foot_collider.shape is RectangleShape2D:
            var foot_shape: Array = CALIBRATION.get("player_foot_shape", [20.0, 12.0])
            var foot_offset: Array = CALIBRATION.get("player_foot_offset", [0.0, 40.0])
            (foot_collider.shape as RectangleShape2D).size = Vector2(float(foot_shape[0]), float(foot_shape[1]))
            foot_collider.position = Vector2(float(foot_offset[0]), float(foot_offset[1]))
    if npc:
        npc.scale = Vector2.ONE * float(CALIBRATION.get("npc_scale", 0.22))
        npc.visible = not in_cabin and active_zone_id == "echo_isles" and scene_id != "departure_complete"
    for actor_list in campaign_actor_nodes.values():
        for actor_value in actor_list:
            var campaign_actor := actor_value as AnimatedSprite2D
            if is_instance_valid(campaign_actor):
                campaign_actor.scale = Vector2.ONE * float(CALIBRATION.get("npc_scale", 0.22))
    if npc_interaction_area:
        var area_shape := npc_interaction_area.get_child(0) as CollisionShape2D
        if area_shape and area_shape.shape is CircleShape2D:
            (area_shape.shape as CircleShape2D).radius = float(CALIBRATION.get("interaction_radius", 98.0))
    if spawn_position.x >= 0.0:
        player.position = spawn_position
        player_collision_body.position = spawn_position
    if camera:
        camera.limit_left = 0
        camera.limit_top = 0
        camera.limit_right = int(MAP_SIZE.x)
        camera.limit_bottom = int(MAP_SIZE.y)
    if npc_name:
        npc_name.visible = false
    if quest_marker:
        quest_marker.visible = false
    if objective_marker:
        objective_marker.visible = false
    if minimap_panel:
        var show_minimap := true
        if options_menu and options_menu.settings is Dictionary:
            show_minimap = bool(options_menu.settings.get("show_minimap", true))
        minimap_panel.visible = show_minimap and not in_cabin
    if minimap_texture and not in_cabin:
        minimap_texture.texture = load(active_map_texture_path)
    if minimap_title_label:
        minimap_title_label.text = "%s  •  MAPA" % active_zone_display_name.to_upper()
    if region_title_label:
        region_title_label.text = active_zone_display_name.to_upper()
    last_position = player.position
    if campaign_runtime:
        var checkpoint_chapter := str(campaign_runtime.chapter_id)
        var checkpoint_region := "awakening_cabin" if in_cabin else active_zone_id
        if active_zone_id == "senjin_village":
            checkpoint_chapter = "SENJIN_COMPLETE" if campaign_runtime.get_quest_state("QST_SEN_009") == "turned_in" else "SENJIN_VILLAGE"
        elif in_cabin:
            checkpoint_chapter = "ECHO_ISLES"
        else:
            checkpoint_chapter = "ECHO_ISLES"
        campaign_runtime.set_checkpoint(checkpoint_chapter, checkpoint_region, player.position)

func _refresh_campaign_world() -> void:
    if not campaign_mode or campaign_world_runtime == null:
        return
    for marker in campaign_point_nodes.values():
        (marker as Label).visible = false
    for prop_nodes in campaign_prop_nodes.values():
        for prop_root in prop_nodes:
            (prop_root as Node2D).visible = false
    for speaker_id in campaign_actor_nodes:
        var actor_list: Array = campaign_actor_nodes[speaker_id]
        var label_list: Array = campaign_actor_name_nodes.get(speaker_id, [])
        for actor in actor_list:
            if is_instance_valid(actor):
                actor.visible = false
        for actor_label in label_list:
            if is_instance_valid(actor_label):
                actor_label.visible = false
    var available_points: Array[Dictionary] = campaign_world_runtime.get_points_for_scene(campaign_scene_id, campaign_runtime)
    for point in available_points:
        var point_id := str(point.get("id", ""))
        var position_data: Array = point.get("position", [0.0, 0.0])
        var point_position := Vector2(float(position_data[0]), float(position_data[1]))
        var marker_position := _campaign_marker_position(point, point_position)
        var marker: Label = campaign_point_nodes.get(point_id)
        if marker:
            marker.position = _campaign_label_position(marker_position)
            marker.visible = true
        var prop_nodes: Array = campaign_prop_nodes.get(point_id, [])
        var prop_offsets: Array = point.get("prop_offsets", [])
        for prop_index in prop_nodes.size():
            var prop_root: Node2D = prop_nodes[prop_index]
            var prop_offset := Vector2.ZERO
            if prop_index < prop_offsets.size() and prop_offsets[prop_index] is Array and prop_offsets[prop_index].size() == 2:
                prop_offset = Vector2(float(prop_offsets[prop_index][0]), float(prop_offsets[prop_index][1]))
            prop_root.position = marker_position + prop_offset
            prop_root.visible = true
        var speaker_id := str(point.get("speaker", ""))
        if speaker_id.is_empty() or not campaign_actor_nodes.has(speaker_id):
            continue
        var actor_list: Array = campaign_actor_nodes[speaker_id]
        var label_list: Array = campaign_actor_name_nodes.get(speaker_id, [])
        var speaker_offset := Vector2.ZERO
        var speaker_offset_data: Variant = point.get("speaker_offset", [])
        if speaker_offset_data is Array and speaker_offset_data.size() == 2:
            speaker_offset = Vector2(float(speaker_offset_data[0]), float(speaker_offset_data[1]))
        for index in actor_list.size():
            var actor: AnimatedSprite2D = actor_list[index]
            if not is_instance_valid(actor):
                continue
            var actor_offset := speaker_offset
            if speaker_id == "children":
                actor_offset += Vector2(-50.0, 0.0) if index == 0 else Vector2(50.0, 0.0)
            actor.position = point_position + actor_offset
            actor.visible = true
            actor.play("idle")
            if index < label_list.size():
                var actor_label: Label = label_list[index]
                actor_label.position = actor.position + (Vector2(-116.0, 62.0) if speaker_id == "children" and index == 0 else Vector2(6.0, 62.0) if speaker_id == "children" else Vector2(-70.0, 62.0))
                actor_label.visible = true
        if speaker_id == "zekranu":
            npc.position = point_position + speaker_offset
            _sync_npc_anchors()
    if dialogue_panel.visible:
        var dialogue_point_id := str(campaign_dialogue_context.get("point_id", ""))
        for point_value in campaign_interaction_data.get("points", []):
            var dialogue_point: Dictionary = point_value
            if str(dialogue_point.get("id", "")) != dialogue_point_id:
                continue
            var dialogue_speaker_id := str(dialogue_point.get("speaker", ""))
            var dialogue_actors: Array = campaign_actor_nodes.get(dialogue_speaker_id, [])
            if dialogue_speaker_id.is_empty() or dialogue_actors.is_empty():
                break
            var dialogue_position_data: Array = dialogue_point.get("position", [0.0, 0.0])
            var dialogue_position := Vector2(float(dialogue_position_data[0]), float(dialogue_position_data[1]))
            var dialogue_offset_data: Variant = dialogue_point.get("speaker_offset", [])
            var dialogue_offset := Vector2.ZERO
            if dialogue_offset_data is Array and dialogue_offset_data.size() == 2:
                dialogue_offset = Vector2(float(dialogue_offset_data[0]), float(dialogue_offset_data[1]))
            for actor_value in dialogue_actors:
                var dialogue_actor: AnimatedSprite2D = actor_value
                if is_instance_valid(dialogue_actor):
                    dialogue_actor.position = dialogue_position + dialogue_offset
                    dialogue_actor.visible = true
                    dialogue_actor.play("idle")
            if dialogue_speaker_id == "zekranu":
                npc.position = dialogue_position + dialogue_offset
                _sync_npc_anchors()
            break
    if npc:
        npc.visible = active_zone_id == "echo_isles" and campaign_scene_id != "cabin"
    if npc_name:
        npc_name.visible = false
    _refresh_campaign_hud()

func _refresh_campaign_hud() -> void:
    if not campaign_mode or not campaign_runtime or not quest_state_label:
        return
    var quest_id := str(campaign_runtime.get_active_quest_id())
    var quest: Dictionary = campaign_runtime.get_quest_definition(quest_id)
    if quest.is_empty():
        quest_state_label.text = "%s • arco concluído" % active_zone_display_name
        return
    var objective_text := ""
    for objective in campaign_runtime.get_objective_definitions(quest_id):
        if bool(objective.get("optional", false)):
            continue
        var objective_id := str(objective.get("id", ""))
        var progress: int = campaign_runtime.get_objective_progress(quest_id, objective_id)
        var target := int(objective.get("target", 1))
        if progress < target:
            objective_text = str(objective.get("label_pt_BR", ""))
            if target > 1:
                objective_text += " (%d/%d)" % [progress, target]
            break
    var title := str(quest.get("title_pt_BR", quest_id))
    if campaign_scene_id == "cabin" and quest_id == "QST_ECHO_001":
        objective_text = "Explore a cabana e escolha antes de sair"
    quest_state_label.text = "%s  •  %s" % [title, objective_text] if not objective_text.is_empty() else title

func _update_campaign_interaction_feedback() -> void:
    interaction_prompt.visible = false
    _refresh_campaign_marker_visibility()
    if not campaign_mode or not world_started or paused or dialogue_panel.visible or encounter_active or cg_active:
        return
    var points: Array[Dictionary] = campaign_world_runtime.get_points_for_scene(campaign_scene_id, campaign_runtime)
    var nearest: Dictionary = {}
    var nearest_distance := INF
    var default_radius := float(campaign_interaction_data.get("interact_radius", 92.0))
    for point in points:
        var position_data: Array = point.get("position", [0.0, 0.0])
        var distance := player.position.distance_to(Vector2(float(position_data[0]), float(position_data[1])))
        if distance <= float(point.get("radius", default_radius)) and distance < nearest_distance:
            nearest = point
            nearest_distance = distance
    if nearest.is_empty():
        return
    var dialogue: Dictionary = campaign_dialogue_data.get("interactions", {}).get(str(nearest.get("dialogue_key", "")), {})
    interaction_prompt.text = "[%s]  %s" % [_interaction_key_label(), str(dialogue.get("label", "Interagir"))]
    interaction_prompt.visible = true

func _refresh_campaign_marker_visibility() -> void:
    if not campaign_mode or campaign_world_runtime == null or not world_started:
        for marker in campaign_point_nodes.values():
            (marker as Label).visible = false
        return
    var modal := paused or dialogue_panel.visible or encounter_active or cg_active
    var viewport_rect := get_viewport_rect()
    var safe_margin := Vector2(158.0, 70.0)
    var safe_rect := Rect2(viewport_rect.position + safe_margin, viewport_rect.size - safe_margin * 2.0)
    var canvas_transform := get_viewport().get_canvas_transform()
    var active_points: Array[Dictionary] = campaign_world_runtime.get_points_for_scene(campaign_scene_id, campaign_runtime)
    for point in active_points:
        var point_id := str(point.get("id", ""))
        var position_data: Array = point.get("position", [0.0, 0.0])
        var point_position := Vector2(float(position_data[0]), float(position_data[1]))
        var marker_position := _campaign_marker_position(point, point_position)
        var nearby := player.position.distance_to(point_position) <= 520.0
        var marker: Label = campaign_point_nodes.get(point_id)
        if marker:
            var label_center_screen := marker.get_global_transform_with_canvas() * (marker.size * 0.5)
            marker.visible = not modal and nearby and safe_rect.has_point(label_center_screen)
        var prop_nodes: Array = campaign_prop_nodes.get(point_id, [])
        var prop_offsets: Array = point.get("prop_offsets", [])
        for prop_index in prop_nodes.size():
            var prop_root: Node2D = prop_nodes[prop_index]
            var prop_screen_position := canvas_transform * prop_root.position
            var visible_prop := not modal and nearby and viewport_rect.grow(-10.0).has_point(prop_screen_position)
            prop_root.visible = visible_prop
        var speaker_id := str(point.get("speaker", ""))
        var actor_labels: Array = campaign_actor_name_nodes.get(speaker_id, [])
        var actor_nodes: Array = campaign_actor_nodes.get(speaker_id, [])
        for actor_index in mini(actor_labels.size(), actor_nodes.size()):
            var actor: Node2D = actor_nodes[actor_index]
            var actor_label: Label = actor_labels[actor_index]
            var actor_screen_position := canvas_transform * actor.position
            actor_label.visible = not modal and player.position.distance_to(actor.position) <= 520.0 and safe_rect.has_point(actor_screen_position)

func _try_campaign_interact() -> void:
    var points: Array[Dictionary] = campaign_world_runtime.get_points_for_scene(campaign_scene_id, campaign_runtime)
    var nearest: Dictionary = {}
    var nearest_distance := INF
    var default_radius := float(campaign_interaction_data.get("interact_radius", 92.0))
    for point in points:
        var position_data: Array = point.get("position", [0.0, 0.0])
        var distance := player.position.distance_to(Vector2(float(position_data[0]), float(position_data[1])))
        if distance <= float(point.get("radius", default_radius)) and distance < nearest_distance:
            nearest = point
            nearest_distance = distance
    if nearest.is_empty():
        _show_toast("Nenhum ponto da quest está próximo.", 2.0)
        return
    _process_campaign_point(nearest)

func _campaign_marker_position(point: Dictionary, fallback_position: Vector2) -> Vector2:
    var marker_position: Array = point.get("marker_position", [])
    if marker_position.size() == 2:
        return Vector2(float(marker_position[0]), float(marker_position[1]))
    return fallback_position

func _campaign_label_position(marker_position: Vector2) -> Vector2:
    var label_width := 300.0
    return Vector2(
        clampf(marker_position.x - label_width * 0.5, 12.0, MAP_SIZE.x - label_width - 12.0),
        clampf(marker_position.y - 56.0, 12.0, MAP_SIZE.y - 40.0)
    )

func _process_campaign_point(point: Dictionary) -> void:
    var point_id := str(point.get("id", ""))
    var quest_id := str(point.get("quest_id", ""))
    var action := str(point.get("action", ""))
    var dialogue_key := str(point.get("dialogue_key", ""))
    match action:
        "branch", "branch_finish":
            _open_campaign_branch(point)
        "objective_then_branch":
            var branches: Array[Dictionary] = campaign_runtime.get_available_branches(quest_id, str(point.get("group_id", "")))
            if not branches.is_empty():
                _open_campaign_branch(point)
            else:
                _campaign_increment_point_objectives(point)
                _campaign_sync_mirrors()
                _campaign_show_point_dialogue(point, "campaign_ack")
                _campaign_persist()
        "objective", "finish":
            _campaign_increment_point_objectives(point)
            _campaign_sync_mirrors()
            if action == "finish":
                campaign_dialogue_context = {"phase":"finish_ack", "quest_id":quest_id, "point_id":point_id}
                _campaign_show_point_dialogue(point, "campaign_finish_ack")
            else:
                _campaign_show_point_dialogue(point, "campaign_ack")
            _campaign_persist()
        "exit_cabin":
            campaign_runtime.set_flag("FLG_ECHO_001_CABIN_EXITED", true)
            _set_campaign_scene("echo_isles", CABIN_EXIT_SPAWN)
            var exit_dialogue: Dictionary = campaign_dialogue_data.get("interactions", {}).get(dialogue_key, {})
            var exit_body := _campaign_interaction_body(point_id, str(exit_dialogue.get("body", "Você atravessa a soleira e segue até o círculo ritual.")))
            campaign_dialogue_context.clear()
            dialogue_action = ""
            _show_toast(exit_body, 4.0)
            _campaign_persist()
        "boar_hunt":
            campaign_pending_encounter = {"point_id":point_id,"quest_id":quest_id,"objective_id":"boar_meat"}
            _start_encounter({"type":"monster_ambush","actors":["wild_boar"],"campaign_point_id":point_id})
        "trap":
            var trap_stage := int(campaign_runtime.counters.get("echo_003_trap_stage", 0))
            trap_stage += 1
            campaign_runtime.counters["echo_003_trap_stage"] = trap_stage
            if trap_stage >= 3:
                campaign_runtime.increment_objective(quest_id, "trap_meat", 1)
                campaign_runtime.inventory["boar_meat"] = int(campaign_runtime.inventory.get("boar_meat", 0)) + 4
                campaign_runtime.counters.erase("echo_003_trap_stage")
                _campaign_show_custom_dialogue("A emboscada funcionou", "A isca, o laço e a cobertura foram preparados na ordem certa. Mok’Jala receberá quatro porções sem exigir uma luta em cada etapa.", "campaign_ack", str(point.get("speaker", "")))
            else:
                _campaign_show_custom_dialogue("Preparar a armadilha", "Etapa %d/3: estudar as pegadas, posicionar a isca e cobrir o rastro." % trap_stage, "campaign_ack", str(point.get("speaker", "")))
            _campaign_sync_mirrors()
            _campaign_persist()
        "capture_frog":
            var frog_count: int = campaign_runtime.get_objective_progress(quest_id, "live_frogs")
            if frog_count < 6:
                campaign_runtime.increment_objective(quest_id, "live_frogs", 1)
                campaign_runtime.inventory["live_frog"] = int(campaign_runtime.inventory.get("live_frog", 0)) + 1
                campaign_runtime.counters["frog_capture_quality"] = int(campaign_runtime.counters.get("frog_capture_quality", 0)) + (1 if int(attributes.get("agility", 0)) >= 50 else 0)
                _campaign_show_custom_dialogue("Captura cuidadosa", "Sapos vivos: %d/6. O reagente permanece intacto." % (frog_count + 1), "campaign_ack", "")
                _campaign_sync_mirrors()
                _campaign_persist()
        "makrura_boss":
            campaign_pending_encounter = {"point_id":point_id,"quest_id":quest_id,"boss":true}
            var boss_context := {
                "spirit_helped":campaign_runtime.get_flag("FLG_WATER_SPIRIT_HELPED"),
                "analysis_done":campaign_runtime.get_flag("FLG_CONTAMINATION_ANALYZED"),
                "attributes":campaign_runtime.attributes.duplicate(true),
            }
            _start_encounter({"type":"monster_ambush","actors":["corrupted_makrura"],"campaign_boss":true,"boss_context":boss_context})
        "depart":
            _campaign_increment_point_objectives(point)
            _campaign_sync_mirrors()
            campaign_dialogue_context = {"phase":"finish_ack", "quest_id":quest_id, "point_id":point_id, "departure":true}
            _campaign_show_point_dialogue(point, "campaign_finish_ack")
            _campaign_persist()
        _:
            push_warning("Unknown campaign action at point %s: %s" % [point_id, action])
    _refresh_campaign_world()

func _campaign_increment_point_objectives(point: Dictionary) -> void:
    var quest_id := str(point.get("quest_id", ""))
    for objective_value in point.get("objectives", []):
        var objective: Dictionary = objective_value
        campaign_runtime.increment_objective(quest_id, str(objective.get("id", "")), int(objective.get("amount", 1)))
    if str(point.get("id", "")) == "q004_deliver" and not campaign_runtime.get_flag("FLG_ECHO_004_ANTIDOTE_RECEIVED"):
        var capture_quality := int(campaign_runtime.counters.get("frog_capture_quality", 0))
        campaign_runtime.counters["antidote_quality"] = 2 if capture_quality >= 4 else 1 if capture_quality >= 2 else 0
        campaign_runtime.inventory["antidote_standard"] = maxi(1, int(campaign_runtime.inventory.get("antidote_standard", 0)))
        campaign_runtime.set_flag("FLG_ECHO_004_ANTIDOTE_RECEIVED", true)

func _campaign_show_point_dialogue(point: Dictionary, action: String) -> void:
    var dialogue_key := str(point.get("dialogue_key", ""))
    var data: Dictionary = campaign_dialogue_data.get("interactions", {}).get(dialogue_key, {})
    var body_text := _campaign_interaction_body(str(point.get("id", "")), str(data.get("body", "")))
    campaign_dialogue_context = {"phase":"ack", "point_id":str(point.get("id", "")), "quest_id":str(point.get("quest_id", ""))}
    _campaign_show_custom_dialogue(str(data.get("title", "Echo Isles")), body_text, action, str(point.get("speaker", "")))

func _campaign_interaction_body(point_id: String, default_body: String) -> String:
    var variants: Array = campaign_dialogue_data.get("interaction_variants", {}).get(point_id, [])
    var resolved_body := default_body
    for variant_value in variants:
        if not variant_value is Dictionary:
            continue
        var variant: Dictionary = variant_value
        var required_flag := str(variant.get("flag", ""))
        if not required_flag.is_empty() and not campaign_runtime.get_flag(required_flag):
            continue
        var branch_requirement: Dictionary = variant.get("branch", {})
        if not branch_requirement.is_empty():
            var quest_id := str(branch_requirement.get("quest_id", ""))
            var group_id := str(branch_requirement.get("group_id", ""))
            var branch_id := str(branch_requirement.get("branch_id", ""))
            var quest_record: Dictionary = campaign_runtime.quest_records.get(quest_id, {})
            var chosen_groups: Dictionary = quest_record.get("branch_groups", {})
            if str(chosen_groups.get(group_id, "")) != branch_id:
                continue
        var affinity_requirement: Dictionary = variant.get("minimum_affinity", {})
        if not affinity_requirement.is_empty():
            var npc_id := str(affinity_requirement.get("npc", ""))
            if int(campaign_runtime.affinity.get(npc_id, 0)) < int(affinity_requirement.get("value", 0)):
                continue
        var body_variant := str(variant.get("body", ""))
        if not body_variant.is_empty():
            if bool(variant.get("append", false)):
                resolved_body += "\n\n" + body_variant
            else:
                resolved_body = body_variant
    if point_id == "q004_deliver":
        var quality := int(campaign_runtime.counters.get("antidote_quality", 0))
        if quality >= 2:
            resolved_body += "\n\nAs capturas cuidadosas preservaram o reagente: o antídoto sai em qualidade alta."
        elif quality == 1:
            resolved_body += "\n\nO antídoto funciona, embora parte do reagente tenha perdido qualidade."
        else:
            resolved_body += "\n\nTaz’Rima consegue um antídoto básico e registra a necessidade de melhorar a coleta."
    return resolved_body

func _campaign_show_custom_dialogue(title_text: String, body_text: String, action: String, speaker_id: String) -> void:
    _show_dialogue(title_text, body_text, action)
    _set_campaign_dialogue_portrait(speaker_id)
    dialogue_choices.text = ""
    dialogue_body.size = Vector2(830.0, 118.0)
    dialogue_body.position = Vector2(180.0, 52.0)
    dialogue_hint.text = "[%s] continuar" % _interaction_key_label()

func _set_campaign_dialogue_portrait(speaker_id: String) -> void:
    if speaker_id.is_empty() or speaker_id == "kataklysma":
        _set_dialogue_portrait(PLAYER_PORTRAIT)
        return
    if speaker_id == "zekranu":
        _set_dialogue_portrait(NPC_PORTRAIT)
        return
    var actor_list: Array = campaign_actor_nodes.get(speaker_id, [])
    if actor_list.is_empty() or not is_instance_valid(actor_list[0]):
        dialogue_portrait.texture = null
        dialogue_portrait_placeholder.text = "NPC"
        dialogue_portrait_placeholder.visible = true
        return
    var actor: AnimatedSprite2D = actor_list[0]
    var source: Texture2D = actor.sprite_frames.get_frame_texture("idle", 0)
    if source == null or source is AtlasTexture:
        dialogue_portrait.texture = source
    else:
        var source_size := source.get_size()
        var portrait := AtlasTexture.new()
        portrait.atlas = source
        portrait.region = Rect2(source_size.x * 0.26, 0.0, source_size.x * 0.48, source_size.y * 0.72)
        portrait.filter_clip = true
        dialogue_portrait.texture = portrait
    dialogue_portrait_placeholder.visible = false

func _open_campaign_branch(point: Dictionary) -> void:
    var quest_id := str(point.get("quest_id", ""))
    var group_id := str(point.get("group_id", ""))
    var branches: Array[Dictionary] = campaign_runtime.get_available_branches(quest_id, group_id)
    if branches.is_empty():
        _show_toast("Esta escolha ainda não está disponível.", 2.0)
        return
    var dialogue: Dictionary = campaign_dialogue_data.get("interactions", {}).get(str(point.get("dialogue_key", "")), {})
    campaign_dialogue_context = {
        "phase":"branch_choice",
        "quest_id":quest_id,
        "group_id":group_id,
        "point_id":str(point.get("id", "")),
        "action":str(point.get("action", "")),
        "speaker":str(point.get("speaker", "")),
        "auto_finish":str(point.get("action", "")) == "branch_finish",
    }
    campaign_branch_input_active = true
    _campaign_show_custom_dialogue(str(dialogue.get("title", "Escolha")), str(dialogue.get("body", "")), "campaign_branch_choice", str(point.get("speaker", "")))
    var choice_lines := PackedStringArray()
    for index in branches.size():
        choice_lines.append("[%d] %s" % [index + 1, str(branches[index].get("label_pt_BR", ""))])
    dialogue_choices.position = Vector2(180.0, 122.0)
    dialogue_choices.size = Vector2(830.0, 78.0)
    dialogue_choices.add_theme_font_size_override("font_size", 14)
    dialogue_choices.text = "\n".join(choice_lines)
    dialogue_body.size = Vector2(830.0, 72.0)
    dialogue_body.position = Vector2(180.0, 46.0)
    dialogue_hint.text = "1–%d escolher   •   E confirmar depois" % branches.size()

func _apply_campaign_branch_choice(choice_index: int) -> void:
    var quest_id := str(campaign_dialogue_context.get("quest_id", ""))
    var group_id := str(campaign_dialogue_context.get("group_id", ""))
    var branches: Array[Dictionary] = campaign_runtime.get_available_branches(quest_id, group_id)
    if choice_index < 1 or choice_index > branches.size():
        return
    var selected: Dictionary = branches[choice_index - 1]
    var result: Dictionary = campaign_runtime.resolve_branch(quest_id, group_id, str(selected.get("id", "")))
    if not bool(result.get("ok", false)):
        _show_toast("A escolha não pôde ser registrada; tente novamente.", 3.0)
        return
    campaign_branch_input_active = false
    var selected_point: Dictionary = campaign_world_runtime.get_point(str(campaign_dialogue_context.get("point_id", "")))
    _campaign_increment_point_objectives(selected_point)
    _campaign_sync_mirrors()
    var result_key := str(result.get("result", "success"))
    var result_text := str(campaign_dialogue_data.get("branch_results", {}).get(result_key, "A escolha foi registrada."))
    var branch_response := str(selected.get("response_pt_BR", ""))
    var consequence := str(selected.get("future_consequence_pt_BR", ""))
    var body := str(selected.get("label_pt_BR", ""))
    body += "\n\n" + (branch_response if not branch_response.is_empty() else result_text)
    if not bool(result.get("check_passed", true)) and not branch_response.is_empty():
        body += "\n\n" + result_text
    if not consequence.is_empty():
        body += "\n\n" + consequence
    if not bool(result.get("check_passed", true)):
        body += "\n\nA checagem não teve sucesso completo, mas a campanha continua por fail-forward."
    _campaign_show_custom_dialogue("Consequência registrada", body, "campaign_branch_ack", str(campaign_dialogue_context.get("speaker", "")))
    campaign_dialogue_context["phase"] = "branch_ack"
    campaign_dialogue_context["selected_branch"] = str(selected.get("id", ""))
    _campaign_persist()

func _continue_game() -> void:
    if not FileAccess.file_exists(save_path):
        _refresh_continue_button()
        _show_toast("Nenhum save encontrado. Inicie uma nova jornada.", 3.0)
        return
    _reset_demo()
    campaign_mode = true
    campaign_scene_id = "echo_isles"
    _set_gameplay_visible(true)
    menu_layer.visible = false
    if options_menu:
        options_menu.visible = false
    if dialogue_panel:
        dialogue_panel.visible = false
    dialogue_action = ""
    campaign_dialogue_context.clear()
    audio_manager.start_ambience()
    _load_game()

func _refresh_continue_button() -> void:
    if is_instance_valid(continue_button):
        continue_button.disabled = not FileAccess.file_exists(save_path)

func _show_menu_options() -> void:
    _open_options_menu()

func _show_menu_credits() -> void:
    _show_toast("Kataklysma — Lust Shaman's Journey • Echo Isles %s" % DEMO_VERSION, 4.0)

func _quit_game() -> void:
    get_tree().quit()

func _toggle_pause() -> void:
    if not world_started or encounter_active or dialogue_panel.visible or cg_active:
        return
    paused = not paused
    if not paused and options_menu:
        options_menu.visible = false
    pause_layer.visible = paused
    if paused:
        _refresh_pause_info()

func _refresh_pause_info() -> void:
    pause_info.text = "1  ATRIBUTOS\n2  QUESTS\n3  MAPA\n4  OPÇÕES\nS  SALVAR\nM  MENU PRINCIPAL\n\n" + _attributes_text() + "\n\n%s  CONTINUAR" % _pause_key_label()

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

func _make_entity_actor(enemy_id: String = "corrupted_makrura") -> AnimatedSprite2D:
    var actor := AnimatedSprite2D.new()
    actor.sprite_frames = _make_entity_sprite_frames(enemy_id)
    actor.animation = &"idle"
    return actor

func _make_entity_sprite_frames(enemy_id: String) -> SpriteFrames:
    var frames := SpriteFrames.new()
    if frames.has_animation("default"):
        frames.remove_animation("default")
    if enemy_id == "wild_boar":
        frames.add_animation("idle")
        frames.set_animation_speed("idle", 1.0)
        frames.set_animation_loop("idle", true)
        var boar_texture: Texture2D = load(WILD_BOAR_CANDIDATE)
        if boar_texture:
            frames.add_frame("idle", boar_texture)
    elif enemy_id == "water_spirit_weakened":
        _add_frames(frames, "idle", WATER_SPIRIT_IDLE_DIR, "entity_weakened_water_spirit_idle", 4, 4.0, true)
    else:
        _add_frames(frames, "idle", ENTITY_IDLE_DIR, "entity_corrupted_makrura_idle", 4, 4.0, true)
        _add_frames(frames, "combat", ENTITY_COMBAT_DIR, "entity_corrupted_makrura_combat", 4, 8.0, true)
    return frames

func _build_encounter_manager() -> void:
    encounter_manager = KataklysmaRandomEncounterManager.new()
    encounter_manager.name = "RandomEncounterManager"
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
        quest_marker.position = npc.position + Vector2(0.0, float(CALIBRATION.get("quest_marker_offset_y", -116.0)) + sin(marker_time * 3.0) * 5.0)
    _sync_npc_anchors()
    _process_random_event_npc(delta)
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
    _update_npc_routine(delta)
    _sync_npc_anchors()
    _move_player(delta)

func _move_player(delta: float) -> void:
    var direction := Vector2.ZERO
    if Input.is_action_pressed("move_left"):
        direction.x -= 1.0
    if Input.is_action_pressed("move_right"):
        direction.x += 1.0
    if Input.is_action_pressed("move_up"):
        direction.y -= 1.0
    if Input.is_action_pressed("move_down"):
        direction.y += 1.0
    if direction == Vector2.ZERO:
        player.play("idle_%s" % last_direction)
        return
    direction = direction.normalized()
    var motion: Vector2 = direction * MOVE_SPEED * delta
    tutorial_distance += motion.length()
    if tutorial_distance >= 380.0:
        _hide_tutorial()
    player_collision_body.position = player.position
    if not is_zero_approx(motion.x) and _is_walkable_position(player.position + Vector2(motion.x, 0.0)):
        player_collision_body.move_and_collide(Vector2(motion.x, 0.0))
    if not is_zero_approx(motion.y) and _is_walkable_position(player_collision_body.position + Vector2(0.0, motion.y)):
        player_collision_body.move_and_collide(Vector2(0.0, motion.y))
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
        var foot_offset: Array = CALIBRATION.get("player_foot_offset", [0.0, 48.0])
        var player_feet := player.position + Vector2(float(foot_offset[0]), float(foot_offset[1]))
        encounter_manager.try_roll(active_encounter_table_id, player_feet, not _is_walkable_position(player.position))

func _update_npc_routine(delta: float) -> void:
    if campaign_mode:
        if npc:
            npc.play("idle")
        return
    if not npc or player.position.distance_to(npc.position) < float(CALIBRATION.get("npc_pause_radius", 140.0)):
        if npc:
            npc.play("idle")
        return
    if npc_routine_wait > 0.0:
        npc_routine_wait -= delta
        npc.play("idle")
        return
    var target: Vector2 = NPC_ROUTE[npc_routine_index]
    if not _is_walkable_position(target):
        npc_routine_index = (npc_routine_index + 1) % NPC_ROUTE.size()
        npc_routine_wait = 1.5
        return
    if npc.position.distance_to(target) <= 2.0:
        npc_routine_index = (npc_routine_index + 1) % NPC_ROUTE.size()
        npc_routine_wait = 3.0 + float((npc_routine_index * 7) % 5)
        npc.play("idle")
        return
    var next_position := npc.position.move_toward(target, NPC_MOVE_SPEED * delta)
    if _is_walkable_position(next_position):
        npc.position = next_position
        npc.play("walk")
    else:
        npc.play("idle")
        npc_routine_wait = 1.0

func _sync_npc_anchors() -> void:
    if not npc:
        return
    if npc_interaction_area:
        npc_interaction_area.position = npc.position
    if npc_collision_body:
        npc_collision_body.position = npc.position + Vector2(0.0, 30.0)
    if npc_name:
        npc_name.position = npc.position + Vector2(-52.0, 64.0)
    if quest_marker:
        quest_marker.position.x = npc.position.x

func _is_walkable_position(world_position: Vector2) -> bool:
    if campaign_mode and campaign_scene_id == "cabin":
        var cabin_walkable := Rect2(Vector2(210.0, 230.0), Vector2(1250.0, 565.0))
        var foot_offset_cabin: Array = CALIBRATION.get("player_foot_offset", [0.0, 48.0])
        var foot_shape_cabin: Array = CALIBRATION.get("player_foot_shape", [20.0, 12.0])
        var feet_position_cabin := world_position + Vector2(float(foot_offset_cabin[0]), float(foot_offset_cabin[1]))
        var inset := Vector2(float(foot_shape_cabin[0]) * 0.5, float(foot_shape_cabin[1]) * 0.5)
        return cabin_walkable.has_point(feet_position_cabin - inset) and cabin_walkable.has_point(feet_position_cabin + inset)
    var foot_offset: Array = CALIBRATION.get("player_foot_offset", [0.0, 48.0])
    var foot_shape: Array = CALIBRATION.get("player_foot_shape", [20.0, 12.0])
    var feet_position := world_position + Vector2(float(foot_offset[0]), float(foot_offset[1]))
    var half_width := float(foot_shape[0]) * 0.5
    var half_height := float(foot_shape[1]) * 0.5
    var probes := [Vector2.ZERO, Vector2(-half_width, -half_height), Vector2(half_width, -half_height), Vector2(-half_width, half_height), Vector2(half_width, half_height)]
    for probe_offset in probes:
        var probe: Vector2 = feet_position + probe_offset
        for blocked_region in WALKABILITY_BLOCK_POLYGONS:
            if Geometry2D.is_point_in_polygon(probe, blocked_region):
                return false
        var inside_walkable := false
        for region in WALKABLE_POLYGONS:
            if Geometry2D.is_point_in_polygon(probe, region):
                inside_walkable = true
                break
        if not inside_walkable:
            return false
    return true

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
    if options_menu and options_menu.handle_key_event(key_event):
        return
    var pause_pressed: bool = InputMap.event_is_action(key_event, &"pause")
    var interact_pressed: bool = InputMap.event_is_action(key_event, &"interact")
    if cg_active:
        if interact_pressed or key_event.keycode == KEY_ESCAPE:
            _advance_cg()
        return
    if paused:
        if pause_pressed:
            _toggle_pause()
            return
        _handle_pause_input(key_event.keycode)
        return
    if encounter_active:
        _handle_encounter_input(key_event)
        return
    if dialogue_panel.visible:
        _handle_dialogue_input(key_event)
        return
    if pause_pressed:
        _toggle_pause()
    elif key_event.keycode == KEY_R:
        if campaign_mode:
            _start_campaign_game()
        else:
            _reset_demo()
    elif key_event.keycode == KEY_F10:
        _toggle_walkability_debug()
    elif key_event.keycode == KEY_F:
        _start_encounter({"type": "monster_ambush", "actors": ["makrura_corrupted"], "manual": true})
    elif interact_pressed:
        _try_interact()

func _try_interact() -> void:
    if campaign_mode:
        _try_campaign_interact()
        return
    var resource_position_data: Array = random_resource_data.get("position", [0.0, 0.0])
    var resource_position := Vector2(float(resource_position_data[0]), float(resource_position_data[1]))
    if not random_resource_data.is_empty() and player.position.distance_to(resource_position) < float(CALIBRATION.get("resource_interaction_radius", 90.0)):
        _collect_random_resource()
    elif player.position.distance_to(npc.position) < float(CALIBRATION.get("interaction_radius", 100.0)):
        _interact_with_npc()
    elif quest_state == "in_progress" and player.position.distance_to(OBJECTIVE_POSITION) < float(CALIBRATION.get("objective_interaction_radius", 110.0)):
        _interact_with_objective()
    else:
        _show_toast("Nenhum ponto de interação próximo.", 2.0)

func _hide_tutorial() -> void:
    if not tutorial_label.visible:
        return
    story_flags["tutorial_movement_seen"] = true
    if campaign_runtime and campaign_runtime.tutorial_flags is Dictionary:
        campaign_runtime.tutorial_flags["movement_seen"] = true
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
        _show_dialogue(_quest_text("npc_intro_title", "Zek'Ranu • Mentor Xamã"), _quest_text("npc_intro", ""), "npc_intro")
        dialogue_choices.text = _format_quest_choices()
        dialogue_hint.text = "1–5 escolher resposta   •   %s confirmar" % _interaction_key_label()
    elif quest_state == "in_progress":
        _show_dialogue("Zek'Ranu", _quest_text("npc_progress", ""), "close")
    elif quest_state == "complete":
        _show_dialogue("Zek'Ranu", _quest_text("npc_complete", ""), "turn_in_quest")
    else:
        _show_dialogue("Zek'Ranu", _quest_text("npc_turned_in", ""), "close")

func _format_quest_choices() -> String:
    var lines := PackedStringArray()
    var choices: Array = quest_dialogue_data.get("choices", [])
    for index in choices.size():
        var choice: Dictionary = choices[index]
        lines.append("[%d] %s — %s" % [index + 1, str(choice.get("label", "")), str(choice.get("text", ""))])
    return "\n".join(lines)

func _interact_with_objective() -> void:
    if quest_state != "in_progress":
        return
    _show_dialogue(_quest_text("objective_title", "Maré corrompida"), _quest_text("objective_body", ""), "complete_quest")

func _show_dialogue(title_text: String, body_text: String, action: String) -> void:
    dialogue_action = action
    dialogue_choice_selected = false
    dialogue_title.text = title_text
    dialogue_body.text = body_text
    dialogue_choices.text = ""
    dialogue_hint.text = "E / Espaço  confirmar"
    _set_dialogue_portrait(NPC_PORTRAIT if title_text.begins_with("Zek") else PLAYER_PORTRAIT)
    _set_modal_hud(true, 0.42)
    dialogue_panel.visible = true

func _set_modal_hud(is_modal: bool, secondary_alpha: float = 1.0) -> void:
    if quest_state_label:
        quest_state_label.modulate.a = secondary_alpha if is_modal else 1.0
    if minimap_panel:
        minimap_panel.modulate.a = secondary_alpha if is_modal else 1.0
    if not is_modal:
        return
    if interaction_prompt:
        interaction_prompt.visible = false
    if npc_name:
        npc_name.visible = false
    if tutorial_label:
        tutorial_label.visible = false
    if toast_label:
        toast_label.text = ""
        toast_time = 0.0

func _set_dialogue_portrait(portrait_path: String) -> void:
    var texture: Texture2D = load(portrait_path)
    if texture:
        dialogue_portrait.texture = texture
        dialogue_portrait_placeholder.visible = false
    else:
        dialogue_portrait.texture = load(PLAYER_PORTRAIT)
        dialogue_portrait_placeholder.visible = dialogue_portrait.texture == null

func _handle_dialogue_input(event: InputEventKey) -> void:
    var keycode: Key = event.keycode
    if campaign_branch_input_active:
        if keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]:
            _apply_campaign_branch_choice(int(keycode) - int(KEY_1) + 1)
        return
    if campaign_mode and dialogue_action == "campaign_ack":
        if InputMap.event_is_action(event, &"interact"):
            _confirm_dialogue()
        return
    if dialogue_action == "npc_intro" and keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]:
        _apply_dialogue_choice(int(keycode) - int(KEY_1) + 1)
    elif InputMap.event_is_action(event, &"interact"):
        _confirm_dialogue()

func _apply_dialogue_choice(choice_index: int) -> void:
    var choices: Array = quest_dialogue_data.get("choices", [])
    if choice_index < 1 or choice_index > choices.size():
        return
    var choice: Dictionary = choices[choice_index - 1]
    var attribute_name := str(choice.get("attribute", ""))
    if not attributes.has(attribute_name):
        push_warning("Quest dialogue refers to an unknown attribute: %s" % attribute_name)
        return
    attributes[attribute_name] = int(attributes[attribute_name]) + int(choice.get("attribute_delta", 2))
    var affinity_delta := int(choice.get("affinity_delta", 0))
    if affinity_delta != 0:
        npc_affinity["zekranu"] = int(npc_affinity.get("zekranu", 0)) + affinity_delta
    var story_flag := str(choice.get("story_flag", ""))
    if story_flag != "":
        story_flags[story_flag] = true
    dialogue_choice_selected = true
    audio_manager.play_ui("menu_select")
    dialogue_action = "accept_quest"
    dialogue_title.text = _quest_text("choice_consequence_title", "Kataklysma • resposta")
    _set_dialogue_portrait(PLAYER_PORTRAIT)
    dialogue_body.text = "%s\n\n%s" % [str(choice.get("response", "")), _quest_text("choice_consequence_suffix", "")]
    dialogue_choices.text = ""
    dialogue_hint.text = str(_quest_text("accept_hint", "%s aceitar quest")) % _interaction_key_label()

func _confirm_dialogue() -> void:
    if campaign_mode:
        if dialogue_action == "campaign_branch_choice":
            return
        var context := campaign_dialogue_context.duplicate(true)
        var action := dialogue_action
        _close_campaign_dialogue()
        if action == "campaign_finish_ack":
            _campaign_finish_quest(str(context.get("quest_id", "")))
        elif action == "campaign_branch_ack" and bool(context.get("auto_finish", false)):
            _campaign_finish_quest(str(context.get("quest_id", "")))
        else:
            campaign_dialogue_context.clear()
            _refresh_campaign_world()
            _campaign_persist()
        return
    if dialogue_action == "npc_intro":
        _apply_dialogue_choice(1)
        return
    dialogue_panel.visible = false
    dialogue_choices.text = ""
    match dialogue_action:
        "accept_quest":
            _set_quest_state("in_progress")
            audio_manager.play_ui("quest_accept")
            _show_toast(_quest_text("accept_notice", "Quest aceita."), 3.0)
        "complete_quest":
            objective_complete = true
            _set_quest_state("complete")
            _start_cg_sequence()
            audio_manager.play_ui("quest_complete")
            _show_toast(_quest_text("complete_notice", "Objetivo completo."), 3.0)
        "turn_in_quest":
            quest_turned_in = true
            _set_quest_state("turned_in")
            audio_manager.play_ui("quest_complete")
            _show_toast(_quest_text("turn_in_notice", "Quest entregue."), 5.0)
        _:
            pass
    _set_modal_hud(false)
    tutorial_label.visible = not story_flags.get("tutorial_movement_seen", false)
    dialogue_action = ""

func _close_campaign_dialogue() -> void:
    dialogue_panel.visible = false
    dialogue_choices.text = ""
    dialogue_action = ""
    campaign_branch_input_active = false
    _set_modal_hud(false)
    tutorial_label.visible = not story_flags.get("tutorial_movement_seen", false)

func _campaign_sync_mirrors() -> void:
    if not campaign_runtime:
        return
    attributes = campaign_runtime.attributes.duplicate(true)
    var tutorial_seen := bool(story_flags.get("tutorial_movement_seen", false))
    story_flags = campaign_runtime.story_flags.duplicate(true)
    story_flags["tutorial_movement_seen"] = tutorial_seen
    if campaign_runtime.tutorial_flags is Dictionary:
        campaign_runtime.tutorial_flags["movement_seen"] = tutorial_seen
    for affinity_id in campaign_runtime.affinity:
        npc_affinity[str(affinity_id)] = int(campaign_runtime.affinity[affinity_id])

func _campaign_persist() -> void:
    if not campaign_mode or not campaign_runtime:
        return
    campaign_runtime.safe_position = player.position
    match campaign_scene_id:
        "cabin":
            campaign_runtime.region_id = "awakening_cabin"
        "senjin_village", "departure_complete":
            campaign_runtime.region_id = "senjin_village"
        _:
            campaign_runtime.region_id = "echo_isles"
    _save_game()

func _campaign_finish_quest(quest_id: String) -> void:
    if quest_id.is_empty() or campaign_runtime.get_quest_state(quest_id) != "in_progress":
        return
    if not campaign_runtime.can_complete_quest(quest_id):
        _show_toast("Ainda há objetivos obrigatórios em aberto.", 3.0)
        _refresh_campaign_world()
        return
    if not campaign_runtime.complete_quest(quest_id):
        _show_toast("A quest não pôde ser concluída; o estado foi preservado.", 3.0)
        return
    _campaign_sync_mirrors()
    _campaign_persist()
    var should_show_cg := quest_id in ["QST_ECHO_002", "QST_ECHO_005"]
    if quest_id == "QST_ECHO_003" and str(campaign_runtime.quest_records[quest_id].get("completion_path", "")) == "hunt":
        should_show_cg = true
    if should_show_cg:
        campaign_cg_followup_quest = quest_id
        _start_cg_sequence(quest_id)
        if cg_active:
            return
        campaign_cg_followup_quest = ""
    _campaign_turn_in_quest(quest_id)

func _campaign_turn_in_quest(quest_id: String) -> void:
    if campaign_runtime.get_quest_state(quest_id) != "complete" or not campaign_runtime.turn_in_quest(quest_id):
        push_warning("Campaign quest could not be turned in: %s" % quest_id)
        return
    var show_senjin_arrival := false
    if quest_id == "QST_ECHO_008":
        campaign_runtime.chapter_id = "SENJIN_VILLAGE"
        campaign_runtime.region_id = "senjin_village"
        var arrival_spawn: Array = zone_map.get_walkability_data().get("calibration", {}).get("arrival_spawn", [1325.0, 690.0])
        var spawn_position := Vector2(float(arrival_spawn[0]), float(arrival_spawn[1]))
        _set_campaign_scene("senjin_village", spawn_position)
        if campaign_runtime.get_quest_state("QST_SEN_009") == "available":
            campaign_runtime.accept_quest("QST_SEN_009")
        campaign_runtime.set_flag("FLG_SEN_ARRIVAL_INTRO_SEEN", true)
        story_flags["tutorial_movement_seen"] = true
        campaign_runtime.tutorial_flags["movement_seen"] = true
        tutorial_label.visible = false
        tutorial_label.modulate.a = 0.0
        show_senjin_arrival = true
    elif quest_id == "QST_SEN_009":
        campaign_runtime.chapter_id = "SENJIN_COMPLETE"
        campaign_runtime.region_id = "senjin_village"
        _show_toast("Suprimentos assegurados. Sen’jin está pronta para a próxima etapa.", 5.0)
    else:
        var quest_order: Array = campaign_definition.get("quest_order", [])
        for next_quest_value in quest_order:
            var next_quest := str(next_quest_value)
            if campaign_runtime.is_quest_unlocked(next_quest):
                campaign_runtime.accept_quest(next_quest)
                break
        _show_toast("Quest entregue: %s" % str(campaign_runtime.get_quest_definition(quest_id).get("title_pt_BR", quest_id)), 3.5)
    campaign_dialogue_context.clear()
    _campaign_sync_mirrors()
    _refresh_campaign_world()
    _campaign_persist()
    if show_senjin_arrival:
        var arrival: Dictionary = campaign_dialogue_data.get("senjin", {}).get("arrival", {})
        _campaign_show_custom_dialogue(str(arrival.get("title", "Chegada a Sen’jin")), str(arrival.get("body", "A canoa alcança Sen’jin.")), "campaign_ack", "tazrima")

func _set_quest_state(new_state: String) -> void:
    if not quest_runtime.transition(new_state):
        push_warning("Invalid quest transition: %s -> %s" % [quest_state, new_state])
        return
    objective_marker.visible = quest_state == "in_progress"
    quest_marker.visible = quest_state != "turned_in"
    if quest_state == "turned_in":
        quest_state_label.text = _quest_text("hud_turned_in", "%s ✓ concluída") % _quest_text("quest_title", "Quest")
        quest_state_label.add_theme_color_override("font_color", Color("#a9f4b0"))
    else:
        var marker_texture_path: String = QUEST_MARKERS.get(quest_state, QUEST_MARKERS["available"])
        quest_marker.texture = load(marker_texture_path)
        match quest_state:
            "available":
                quest_state_label.text = _quest_text("hud_available", "%s ◈ Fale com Zek'Ranu") % _quest_text("quest_title", "Quest")
                quest_state_label.add_theme_color_override("font_color", Color("#f6d365"))
            "in_progress":
                quest_state_label.text = _quest_text("hud_in_progress", "%s ◈ Investigue") % _quest_text("quest_title", "Quest")
                quest_state_label.add_theme_color_override("font_color", Color("#72b7ff"))
            "complete":
                quest_state_label.text = _quest_text("hud_complete", "%s ✓ Volte ao Zek'Ranu") % _quest_text("quest_title", "Quest")
                quest_state_label.add_theme_color_override("font_color", Color("#8be28b"))
    minimap_quest_dot.visible = quest_state != "turned_in"
    minimap_objective_dot.visible = quest_state == "in_progress"
    minimap_resource_dot.visible = not random_resource_data.is_empty()

func _update_interaction_feedback() -> void:
    if campaign_mode:
        _update_campaign_interaction_feedback()
        return
    if not world_started or paused or cg_active or encounter_active or dialogue_panel.visible:
        interaction_prompt.visible = false
        objective_marker.visible = false
        if npc_name:
            npc_name.visible = false
        return
    objective_marker.visible = quest_state == "in_progress" and player.position.distance_to(OBJECTIVE_POSITION) < 400.0
    if not random_resource_data.is_empty():
        var resource_position_data: Array = random_resource_data.get("position", [0.0, 0.0])
        var resource_position := Vector2(float(resource_position_data[0]), float(resource_position_data[1]))
        random_resource_marker.visible = true
        random_resource_marker.position = resource_position + Vector2(-48.0, -28.0)
        if player.position.distance_to(resource_position) < float(CALIBRATION.get("resource_prompt_radius", 120.0)):
            var resource_name := str(random_resource_data.get("name", "recurso"))
            interaction_prompt.text = str(event_dialogue_data.get("resource_prompt", "[%s] Coletar %s")) % [_interaction_key_label(), resource_name]
            interaction_prompt.visible = true
            return
    else:
        random_resource_marker.visible = false
    var npc_distance: float = player.position.distance_to(npc.position)
    var objective_distance: float = player.position.distance_to(OBJECTIVE_POSITION)
    npc_name.visible = npc_distance < float(CALIBRATION.get("npc_prompt_radius", 155.0))
    if npc_distance < float(CALIBRATION.get("interaction_radius", 100.0)):
        interaction_prompt.text = "[%s]  Falar com Zek'Ranu" % _interaction_key_label()
        interaction_prompt.visible = true
    elif quest_state == "in_progress" and objective_distance < float(CALIBRATION.get("objective_interaction_radius", 110.0)):
        interaction_prompt.text = "[%s]  Investigar a Maré Corrompida" % _interaction_key_label()
        interaction_prompt.visible = true
    else:
        interaction_prompt.visible = false

func _update_minimap() -> void:
    if not minimap_panel or not player:
        return
    var map_origin := Vector2(10.0, 30.0)
    var map_extent := Vector2(190.0, 107.0)
    var player_map: Vector2 = map_origin + Vector2(player.position.x / MAP_SIZE.x * map_extent.x, player.position.y / MAP_SIZE.y * map_extent.y)
    var quest_position := npc.position
    var objective_position := OBJECTIVE_POSITION
    var has_campaign_target := false
    if campaign_mode and campaign_world_runtime and campaign_runtime:
        var available_points: Array[Dictionary] = campaign_world_runtime.get_points_for_scene(campaign_scene_id, campaign_runtime)
        if not available_points.is_empty():
            var point_position_data: Array = available_points[0].get("position", [player.position.x, player.position.y])
            quest_position = Vector2(float(point_position_data[0]), float(point_position_data[1]))
            objective_position = quest_position
            has_campaign_target = true
    var npc_map: Vector2 = map_origin + Vector2(quest_position.x / MAP_SIZE.x * map_extent.x, quest_position.y / MAP_SIZE.y * map_extent.y)
    var objective_map: Vector2 = map_origin + Vector2(objective_position.x / MAP_SIZE.x * map_extent.x, objective_position.y / MAP_SIZE.y * map_extent.y)
    minimap_player_dot.position = player_map
    minimap_quest_dot.position = npc_map
    minimap_objective_dot.position = objective_map
    if campaign_mode:
        minimap_objective_dot.visible = has_campaign_target and campaign_scene_id == "echo_isles"
    minimap_resource_dot.visible = not random_resource_data.is_empty()
    if not random_resource_data.is_empty():
        var position_data: Array = random_resource_data.get("position", [0.0, 0.0])
        minimap_resource_dot.position = map_origin + Vector2(float(position_data[0]) / MAP_SIZE.x * map_extent.x, float(position_data[1]) / MAP_SIZE.y * map_extent.y)

func _attributes_text() -> String:
    return "AGILIDADE  %d\nESTAMINA   %d\nINTELECTO  %d\nESPÍRITO   %d\nCORRUPÇÃO  %d\nLUXÚRIA    %d" % [
        int(attributes["agility"]), int(attributes["stamina"]), int(attributes["intellect"]),
        int(attributes["spirit"]), int(attributes["corruption"]), int(attributes["lust"]),
    ]

func _handle_pause_input(keycode: Key) -> void:
    var resume_hint := "%s voltar" % _pause_key_label()
    if keycode == KEY_1:
        pause_info.text = "ATRIBUTOS\n\n" + _attributes_text() + "\n\n" + resume_hint
    elif keycode == KEY_2:
        pause_info.text = "QUESTS\n\nPURIFICAR A MARÉ\nEstado: %s\nAfinidade Zek'Ranu: %d\n\n%s" % [quest_state, int(npc_affinity["zekranu"]), resume_hint]
    elif keycode == KEY_3:
        pause_info.text = "MAPA\n\n%s\nPOIs descobertos: %d\nMinimapa ativo no canto superior direito.\n\n%s" % [active_zone_display_name, discovered_pois.size(), resume_hint]
    elif keycode == KEY_4:
        _open_options_menu()
    elif keycode == KEY_S:
        _save_game()
        pause_info.text = "JOGO SALVO\n\nPosição, atributos, quest, afinidade, flags e POIs foram salvos.\n\n%s" % resume_hint
    elif keycode == KEY_M:
        _return_to_menu()

func _save_game() -> void:
    var save_data: Dictionary = {
        "version": "demo_v4",
        "quest_id": quest_runtime.quest_id,
        "player_position": [player.position.x, player.position.y],
        "quest_state": quest_state,
        "objective_complete": objective_complete,
        "quest_turned_in": quest_turned_in,
        "attributes": attributes.duplicate(true),
        "npc_affinity": npc_affinity.duplicate(true),
        "story_flags": story_flags.duplicate(true),
        "discovered_pois": discovered_pois.duplicate(true),
        "resources_collected": resources_collected,
        "random_resource_data": random_resource_data.duplicate(true),
        "tutorial_movement_seen": bool(story_flags.get("tutorial_movement_seen", false)),
        "campaign_mode": campaign_mode,
        "campaign_scene_id": campaign_scene_id,
        "campaign_state": campaign_runtime.export_state() if campaign_runtime else {},
    }
    var file := FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()
        _refresh_continue_button()

func _load_game() -> void:
    if not FileAccess.file_exists(save_path):
        _show_toast("Nenhum save encontrado. Uma nova jornada foi iniciada.", 3.0)
        return
    var file := FileAccess.open(save_path, FileAccess.READ)
    var parsed: Variant = JSON.parse_string(file.get_as_text()) if file else null
    if parsed is Dictionary:
        var data: Dictionary = parsed
        var saved_campaign: Variant = data.get("campaign_state", {})
        var saved_campaign_schema := int(saved_campaign.get("save_schema_version", 0)) if saved_campaign is Dictionary else 0
        var legacy_departure := str(data.get("campaign_scene_id", "")) == "departure_complete"
        var should_resave_migrated_save := false
        campaign_mode = bool(data.get("campaign_mode", false))
        campaign_scene_id = str(data.get("campaign_scene_id", "echo_isles"))
        var position_data: Array = data.get("player_position", [PLAYER_START.x, PLAYER_START.y])
        player.position = Vector2(float(position_data[0]), float(position_data[1]))
        player_collision_body.position = player.position
        quest_state = str(data.get("quest_state", "available"))
        objective_complete = bool(data.get("objective_complete", false))
        quest_turned_in = bool(data.get("quest_turned_in", false))
        attributes = data.get("attributes", attributes)
        npc_affinity = data.get("npc_affinity", npc_affinity)
        story_flags = data.get("story_flags", story_flags)
        if saved_campaign is Dictionary and not saved_campaign.is_empty() and campaign_runtime:
            if not campaign_runtime.restore_state(saved_campaign):
                push_warning("Save has an invalid or incompatible canonical campaign snapshot; prototype state was loaded unchanged.")
            elif campaign_mode:
                if campaign_runtime.get_quest_state("QST_ECHO_008") == "turned_in" and campaign_runtime.get_quest_state("QST_SEN_009") == "available":
                    campaign_runtime.accept_quest("QST_SEN_009")
                if legacy_departure and campaign_runtime.get_quest_state("QST_ECHO_008") == "turned_in":
                    campaign_scene_id = "senjin_village"
                    var arrival_spawn: Array = zone_map.get_walkability_data().get("calibration", {}).get("arrival_spawn", [1325.0, 690.0])
                    player.position = Vector2(float(arrival_spawn[0]), float(arrival_spawn[1]))
                    player_collision_body.position = player.position
                    campaign_runtime.chapter_id = "SENJIN_VILLAGE"
                    campaign_runtime.region_id = "senjin_village"
                    campaign_runtime.set_flag("FLG_SEN_ARRIVAL_INTRO_SEEN", true)
                    should_resave_migrated_save = true
                elif saved_campaign_schema == 1:
                    should_resave_migrated_save = true
        if campaign_mode:
            _campaign_sync_mirrors()
        if bool(data.get("tutorial_movement_seen", false)):
            story_flags["tutorial_movement_seen"] = true
        discovered_pois = data.get("discovered_pois", discovered_pois)
        resources_collected = int(data.get("resources_collected", 0))
        random_resource_data = data.get("random_resource_data", {})
        if campaign_mode:
            _set_campaign_scene(campaign_scene_id, player.position)
            _refresh_campaign_world()
            _resume_campaign_presentation_after_load()
        else:
            _set_quest_state(quest_state)
        random_resource_marker.visible = not random_resource_data.is_empty()
        if random_resource_marker.visible:
            var saved_resource_position: Array = random_resource_data.get("position", [player.position.x, player.position.y])
            random_resource_marker.position = Vector2(float(saved_resource_position[0]), float(saved_resource_position[1])) + Vector2(-48.0, -28.0)
        _update_minimap()
        tutorial_label.modulate.a = 1.0 if not story_flags.get("tutorial_movement_seen", false) else 0.0
        tutorial_label.visible = not story_flags.get("tutorial_movement_seen", false)
        if should_resave_migrated_save:
            _campaign_persist()
        _show_toast("Save carregado.", 3.0)

func _resume_campaign_presentation_after_load() -> void:
    if not campaign_runtime:
        return
    for quest_id_value in campaign_definition.get("quest_order", []):
        var quest_id := str(quest_id_value)
        if campaign_runtime.get_quest_state(quest_id) != "complete":
            continue
        var completion_path := str(campaign_runtime.quest_records[quest_id].get("completion_path", ""))
        var should_resume_cg := quest_id in ["QST_ECHO_002", "QST_ECHO_005"] or (quest_id == "QST_ECHO_003" and completion_path == "hunt")
        if should_resume_cg:
            campaign_cg_followup_quest = quest_id
            _start_cg_sequence(quest_id)
        else:
            _campaign_turn_in_quest(quest_id)
        return
    var active_quest_id := str(campaign_runtime.get_active_quest_id())
    if active_quest_id.is_empty() or campaign_runtime.get_quest_state(active_quest_id) != "in_progress":
        return
    if campaign_runtime.can_complete_quest(active_quest_id):
        _campaign_finish_quest(active_quest_id)
        return
    if active_quest_id == "QST_ECHO_006" and campaign_runtime.get_objective_progress(active_quest_id, "makrura_defeated") > 0 and campaign_runtime.get_objective_progress(active_quest_id, "fragment_decided") == 0:
        campaign_cg_followup_quest = "makrura_fragment"
        _start_cg_sequence(active_quest_id)
        if not cg_active:
            campaign_cg_followup_quest = ""

func _start_cg_sequence(sequence_quest_id: String = "") -> void:
    cg_frames.clear()
    var sequence: Array = CAMPAIGN_CG_VARIANTS.get(sequence_quest_id, CG_VARIANTS)
    for frame_path in sequence:
        cg_frames.append(str(frame_path))
    for frame_path in cg_frames:
        if not ResourceLoader.exists(frame_path):
            push_error("CG sequence asset is missing: %s" % frame_path)
            cg_frames.clear()
            return
    cg_index = 0
    cg_time = 0.0
    cg_active = true
    cg_layer.visible = true
    _show_cg_frame()

func _show_cg_frame() -> void:
    if cg_frames.is_empty():
        return
    cg_image.texture = load(cg_frames[cg_index])
    if campaign_mode:
        var quest_id := "QST_ECHO_006" if campaign_cg_followup_quest == "makrura_fragment" else campaign_cg_followup_quest
        var title := str(campaign_runtime.get_quest_definition(quest_id).get("title_pt_BR", "Echo Isles")) if not quest_id.is_empty() else "Echo Isles"
        cg_caption.text = "%s • quadro %d / %d" % [title.to_upper(), cg_index + 1, cg_frames.size()]
    else:
        cg_caption.text = str(_quest_text("cg_caption", "ECHO ISLES • visão da maré • %d / %d")) % [cg_index + 1, cg_frames.size()]

func _process_cg(delta: float) -> void:
    cg_time += delta
    if cg_time >= 2.5:
        _advance_cg()

func _advance_cg() -> void:
    cg_time = 0.0
    if cg_index >= cg_frames.size() - 1:
        cg_active = false
        cg_layer.visible = false
        if campaign_mode and campaign_cg_followup_quest == "makrura_fragment":
            campaign_cg_followup_quest = ""
            _show_toast("O Makrura foi derrotado. Decida o destino do fragmento.", 4.0)
            _refresh_campaign_world()
            _campaign_persist()
        elif campaign_mode and not campaign_cg_followup_quest.is_empty():
            var completed_quest := campaign_cg_followup_quest
            campaign_cg_followup_quest = ""
            _campaign_turn_in_quest(completed_quest)
        else:
            _show_toast(_quest_text("cg_complete", "Quest completa."), 4.0)
    else:
        cg_index += 1
        _show_cg_frame()

func _return_to_menu() -> void:
    paused = false
    pause_layer.visible = false
    if options_menu:
        options_menu.visible = false
    audio_manager.stop_ambience()
    _set_gameplay_visible(false)
    menu_layer.visible = true
    _refresh_continue_button()

func _on_encounter_triggered(_table_id: String, encounter: Dictionary) -> void:
    _start_encounter(encounter)

func _start_encounter(encounter: Dictionary) -> void:
    var encounter_type := str(encounter.get("type", ""))
    if encounter_type != "monster_ambush":
        _handle_noncombat_encounter(encounter)
        return

    var enemy_id := _resolve_combat_enemy(encounter.get("actors", []))
    if enemy_id.is_empty():
        push_warning("Emboscada ignorada: a tabela não definiu um inimigo de combate compatível.")
        _show_toast("Emboscada sem inimigo configurado; nenhum combate foi iniciado.", 3.0)
        return

    encounter_active = true
    encounter_choice_made = false
    encounter_hint.visible = false
    _set_modal_hud(true, 0.24)
    combat_system = CombatSystem.new()
    _set_combat_enemy_art(enemy_id)
    audio_manager.play_ui("combat")
    var boss_context: Dictionary = encounter.get("boss_context", {})
    var snapshot: Dictionary = combat_system.start_battle(enemy_id, bool(encounter.get("campaign_boss", false)), boss_context)
    if bool(encounter.get("campaign_boss", false)):
        encounter_body.text = "Arena do Makrura — três fases. Poças condutivas, ovos e pedra ritual podem ser neutralizados com [6]."
    else:
        encounter_body.text = "Uma criatura emboscou Kataklysma durante a exploração.\nAmeaça: %s" % str(snapshot["enemy"]["display_name"])
    combat_player_sprite.visible = true
    combat_enemy_sprite.visible = true
    combat_player_sprite.play("idle")
    combat_enemy_sprite.play("idle")
    _refresh_combat_ui(snapshot)
    encounter_panel.visible = true

func _resolve_combat_enemy(actor_ids: Variant) -> String:
    if not actor_ids is Array:
        return ""
    var candidates: Array[String] = []
    for actor_id in actor_ids:
        match str(actor_id):
            "wild_boar":
                if ResourceLoader.exists(WILD_BOAR_CANDIDATE):
                    candidates.append("wild_boar")
            "water_spirit_weakened":
                candidates.append("water_spirit_weakened")
            "makrura_corrupted", "corrupted_makrura":
                candidates.append("corrupted_makrura")
    if candidates.is_empty():
        return ""
    return candidates[encounter_rng.randi_range(0, candidates.size() - 1)]

func _set_combat_enemy_art(enemy_id: String) -> void:
    combat_enemy_sprite.sprite_frames = _make_entity_sprite_frames(enemy_id)
    combat_enemy_sprite.animation = &"idle"
    combat_enemy_sprite.offset = Vector2.ZERO
    combat_enemy_sprite.scale = Vector2.ONE * 0.42
    if enemy_id == "wild_boar":
        combat_enemy_sprite.scale = Vector2.ONE * 0.20
        combat_enemy_sprite.offset = Vector2(0.0, 76.0)
    elif enemy_id == "water_spirit_weakened":
        combat_enemy_sprite.scale = Vector2.ONE * 0.34

func _handle_noncombat_encounter(encounter: Dictionary) -> void:
    var encounter_type := str(encounter.get("type", ""))
    var actors: Array = encounter.get("actors", [])
    match encounter_type:
        "npc_walkby":
            _start_npc_walkby(actors)
        "resource_find":
            _reveal_random_resource(actors)
        "spirit_omen":
            var omen: Dictionary = event_dialogue_data.get("spirit_omen", {})
            var flag := str(omen.get("flag", "echo_isles_spirit_omen_attuned"))
            if not bool(story_flags.get(flag, false)):
                attributes["spirit"] = mini(100, int(attributes.get("spirit", 0)) + 1)
                story_flags[flag] = true
                _show_toast(str(omen.get("message", "Um presságio espiritual atravessa a maré.")), 4.0)
            else:
                _show_toast("O presságio é familiar; Kataklysma já aprendeu a reconhecer esse sinal.", 3.0)
        "supply_problem":
            var senjin_events: Dictionary = campaign_dialogue_data.get("senjin", {}).get("events", {})
            var supply_flag := "FLG_SEN_RANDOM_SUPPLY_RESOLVED"
            if campaign_mode and active_zone_id == "senjin_village" and not campaign_runtime.get_flag(supply_flag):
                campaign_runtime.set_flag(supply_flag, true)
                campaign_runtime.inventory["ration"] = int(campaign_runtime.inventory.get("ration", 0)) + 1
                campaign_runtime.reputation["local"] = int(campaign_runtime.reputation.get("local", 0)) + 1
                _campaign_sync_mirrors()
                _show_toast(str(senjin_events.get("supply_problem_first", "A vila recupera uma ração.")), 4.0)
                _campaign_persist()
            else:
                _show_toast(str(senjin_events.get("supply_problem_repeat", "A situação dos suprimentos está estável.")), 3.0)
        "alchemy_request":
            var alchemy_events: Dictionary = campaign_dialogue_data.get("senjin", {}).get("events", {})
            var alchemy_flag := "FLG_SEN_RANDOM_ALCHEMY_REQUEST_RESOLVED"
            if campaign_mode and active_zone_id == "senjin_village" and not campaign_runtime.get_flag(alchemy_flag):
                campaign_runtime.set_flag(alchemy_flag, true)
                campaign_runtime.inventory["field_reagent"] = int(campaign_runtime.inventory.get("field_reagent", 0)) + 1
                campaign_runtime.affinity["tazrima"] = int(campaign_runtime.affinity.get("tazrima", 0)) + 1
                _campaign_sync_mirrors()
                _show_toast(str(alchemy_events.get("alchemy_request_first", "Taz’Rima registra o reagente.")), 4.0)
                _campaign_persist()
            else:
                _show_toast(str(alchemy_events.get("alchemy_request_repeat", "O estoque de reagentes está suficiente.")), 3.0)
        _:
            push_warning("Non-combat event is not configured for zone %s: %s" % [active_zone_id, encounter_type])
            _show_toast("Este evento não está configurado para a região atual.", 3.0)

func _start_npc_walkby(actor_ids: Array) -> void:
    if is_instance_valid(random_event_npc):
        random_event_npc.queue_free()
        random_event_npc = null
    var available_ids: Array[String] = []
    for actor_id in actor_ids:
        var actor_key := str(actor_id)
        if RANDOM_NPC_DATA.has(actor_key):
            var actor_data: Dictionary = RANDOM_NPC_DATA[actor_key]
            if ResourceLoader.exists("%s/IDLE/npc_%s_idle_001.png" % [actor_data["path"], actor_key]):
                available_ids.append(actor_key)
        elif campaign_mode and active_zone_id == "senjin_village" and CAMPAIGN_NPC_SPRITE_DATA.has(actor_key):
            var actor_info: Dictionary = CAMPAIGN_NPC_SPRITE_DATA[actor_key]
            var actor_root := "%s/%s" % [NPC_SPRITE_ROOT, str(actor_info.get("folder", actor_key))]
            if ResourceLoader.exists("%s/IDLE/npc_%s_idle_001.png" % [actor_root, actor_key]):
                available_ids.append(actor_key)
    if available_ids.is_empty():
        push_warning("NPC walk-by table has no integrated sprite in this zone.")
        _show_toast(str(event_dialogue_data.get("walkby_fallback", "Uma viajante cruza a trilha.")), 3.0)
        return
    var actor_id: String = available_ids[encounter_rng.randi_range(0, available_ids.size() - 1)]
    var actor_data: Dictionary = RANDOM_NPC_DATA.get(actor_id, {})
    var actor_name := str(actor_data.get("name", CAMPAIGN_NPC_SPRITE_DATA.get(actor_id, {}).get("name", actor_id)))
    var direction_candidates := [Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0)]
    var chosen_direction := Vector2.ZERO
    var start_position := player.position
    for candidate in direction_candidates:
        var start_candidate: Vector2 = player.position - candidate * 54.0
        var end_candidate: Vector2 = player.position + candidate * 54.0
        if _is_walkable_position(start_candidate) and _is_walkable_position(end_candidate):
            chosen_direction = candidate
            start_position = start_candidate
            break
    if chosen_direction == Vector2.ZERO:
        _show_toast(str(event_dialogue_data.get("walkby_fallback", "Uma viajante cruza a trilha.")), 3.0)
        return
    var actor_path := str(actor_data.get("path", "%s/%s" % [NPC_SPRITE_ROOT, CAMPAIGN_NPC_SPRITE_DATA.get(actor_id, {}).get("folder", actor_id)]))
    random_event_npc = _make_actor(actor_name, "%s/IDLE" % actor_path, "%s/WALK" % actor_path, "npc_%s" % actor_id)
    random_event_npc.name = "RandomWalkby_%s" % actor_id
    random_event_npc.position = start_position
    random_event_npc.scale = Vector2.ONE * float(CALIBRATION.get("npc_scale", 0.26))
    random_event_npc.flip_h = chosen_direction.x < 0.0
    random_event_npc.z_index = 5
    world_entities.add_child(random_event_npc)
    random_event_npc.play("walk_front")
    random_event_npc_direction = chosen_direction
    random_event_npc_time = 2.8
    var localized_message := str(event_dialogue_data.get("npc_walkby", {}).get(actor_id, ""))
    if campaign_mode and active_zone_id == "senjin_village":
        localized_message = str(campaign_dialogue_data.get("senjin", {}).get("events", {}).get("walkby", {}).get(actor_id, localized_message))
    _show_toast(localized_message, 3.0)

func _process_random_event_npc(delta: float) -> void:
    if not is_instance_valid(random_event_npc):
        return
    random_event_npc_time -= delta
    var next_position := random_event_npc.position + random_event_npc_direction * 55.0 * delta
    if _is_walkable_position(next_position):
        random_event_npc.position = next_position
    else:
        random_event_npc_time = 0.0
    if random_event_npc_time <= 0.0:
        random_event_npc.queue_free()
        random_event_npc = null

func _reveal_random_resource(actor_ids: Array) -> void:
    if not random_resource_data.is_empty():
        _show_toast("O recurso encontrado anteriormente ainda aguarda coleta.", 3.0)
        return
    var candidates: Array[String] = []
    var resource_data: Dictionary = event_dialogue_data.get("resource_find", {})
    for actor_id in actor_ids:
        var key := str(actor_id)
        if resource_data.has(key):
            candidates.append(key)
    if candidates.is_empty():
        _show_toast(str(event_dialogue_data.get("resource_fallback", "Um recurso local foi encontrado.")), 3.0)
        return
    var resource_id: String = candidates[encounter_rng.randi_range(0, candidates.size() - 1)]
    var definition: Dictionary = resource_data[resource_id]
    var resource_position := player.position + Vector2(34.0, 0.0)
    if not _is_walkable_position(resource_position):
        resource_position = player.position
    random_resource_data = {
        "id": resource_id,
        "name": str(definition.get("name", "recurso")),
        "position": [resource_position.x, resource_position.y],
    }
    random_resource_marker.visible = true
    random_resource_marker.position = resource_position + Vector2(-48.0, -28.0)
    _show_toast(str(definition.get("found", "Recurso encontrado.")) % _interaction_key_label(), 4.0)

func _collect_random_resource() -> void:
    if random_resource_data.is_empty():
        return
    var resource_id := str(random_resource_data.get("id", ""))
    var resource_definitions: Dictionary = event_dialogue_data.get("resource_find", {})
    var definition: Dictionary = resource_definitions.get(resource_id, {})
    resources_collected += 1
    discovered_pois["resource_%s_%d" % [resource_id, resources_collected]] = true
    random_resource_data.clear()
    random_resource_marker.visible = false
    _show_toast(str(definition.get("collected", "Recurso registrado.")), 3.5)

func _handle_encounter_input(event: InputEventKey) -> void:
    var keycode: Key = event.keycode
    if encounter_choice_made and (InputMap.event_is_action(event, &"interact") or keycode == KEY_ESCAPE):
        var result: String = combat_system.battle_result if combat_system else ""
        encounter_panel.visible = false
        encounter_active = false
        combat_player_sprite.visible = false
        combat_enemy_sprite.visible = false
        _set_modal_hud(false)
        tutorial_label.visible = not story_flags.get("tutorial_movement_seen", false)
        var campaign_result_handled := false
        if campaign_mode and not campaign_pending_encounter.is_empty():
            var pending: Dictionary = campaign_pending_encounter.duplicate(true)
            if result in ["victory", "neutralized"]:
                var quest_id := str(pending.get("quest_id", ""))
                if bool(pending.get("boss", false)):
                    for objective_id in ["boss_phase_one", "boss_phase_two", "boss_phase_three", "makrura_defeated"]:
                        campaign_runtime.set_objective_progress(quest_id, objective_id, 1)
                    if result == "neutralized":
                        campaign_runtime.set_flag("FLG_MAKRURA_NEUTRALIZED", true)
                    else:
                        campaign_runtime.set_flag("FLG_MAKRURA_DEFEATED", true)
                    campaign_pending_encounter.clear()
                    _campaign_sync_mirrors()
                    campaign_cg_followup_quest = "makrura_fragment"
                    _campaign_persist()
                    _start_cg_sequence("QST_ECHO_006")
                    if not cg_active:
                        campaign_cg_followup_quest = ""
                        _refresh_campaign_world()
                    campaign_result_handled = true
                else:
                    var objective_id := str(pending.get("objective_id", ""))
                    campaign_runtime.increment_objective(quest_id, objective_id, 1)
                    campaign_runtime.inventory["boar_meat"] = int(campaign_runtime.inventory.get("boar_meat", 0)) + 1
                    campaign_pending_encounter.clear()
                    _campaign_sync_mirrors()
                    _campaign_persist()
                    _refresh_campaign_world()
                    campaign_result_handled = true
            else:
                campaign_pending_encounter.clear()
                _campaign_persist()
                _refresh_campaign_world()
                campaign_result_handled = true
        if campaign_result_handled:
            return
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
        KEY_6:
            action = "terrain"
        KEY_7:
            action = "neutralize"
        _:
            return
    var snapshot: Dictionary = combat_system.perform_action(action)
    _refresh_combat_ui(snapshot)
    var phase: String = str(snapshot.get("phase", "player_turn"))
    if phase in ["victory", "neutralized", "defeat", "fled"]:
        encounter_choice_made = true
        encounter_hint.text = "Combate encerrado — %s para voltar ao mapa" % _interaction_key_label()

func _refresh_combat_ui(snapshot: Dictionary) -> void:
    var player_stats: Dictionary = snapshot.get("player", {})
    var enemy_stats: Dictionary = snapshot.get("enemy", {})
    combat_enemy_name_label.text = str(enemy_stats.get("display_name", "Ameaça")).to_upper()
    combat_player_bar.max_value = float(player_stats.get("max_hp", 1))
    combat_player_bar.value = float(player_stats.get("hp", 0))
    combat_player_spirit_bar.max_value = float(player_stats.get("max_spirit", 1))
    combat_player_spirit_bar.value = float(player_stats.get("spirit", 0))
    combat_enemy_bar.max_value = float(enemy_stats.get("max_hp", 1))
    combat_enemy_bar.value = float(enemy_stats.get("hp", 0))
    var event_lines: Array = snapshot.get("events", [])
    combat_log_label.text = "\n".join(event_lines)
    var phase: String = str(snapshot.get("phase", "player_turn"))
    encounter_hint.visible = phase in ["victory", "neutralized", "defeat", "fled"]
    if phase == "player_turn":
        combat_turn_label.text = "SUA VEZ  •  Round %d" % int(snapshot.get("round", 1))
        var boss_phase := int(snapshot.get("boss_phase", 0))
        if boss_phase > 0:
            combat_action_label.text = "[1] Ataque  [2] Canalizar  [3] Guarda  [4] Purificar  [5] Fugir  [6] Arena%s" % ("  [7] Neutralizar" if snapshot.get("actions", []).has("neutralize") else "")
        else:
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
    campaign_mode = false
    campaign_scene_id = "echo_isles"
    campaign_pending_encounter.clear()
    campaign_cg_followup_quest = ""
    cg_active = false
    cg_index = 0
    cg_time = 0.0
    cg_frames.clear()
    if cg_layer:
        cg_layer.visible = false
    quest_state = "available"
    objective_complete = false
    quest_turned_in = false
    attributes = {"agility": 61, "stamina": 54, "intellect": 82, "spirit": 73, "corruption": 21, "lust": 43}
    npc_affinity = {"zekranu": 0}
    story_flags.clear()
    _reset_campaign_runtime()
    discovered_pois = {"awakening_cabin": true, "training_clearing": true}
    resources_collected = 0
    random_resource_data.clear()
    random_resource_marker.visible = false
    if is_instance_valid(random_event_npc):
        random_event_npc.queue_free()
        random_event_npc = null
    tutorial_distance = 0.0
    tutorial_time = 0.0
    player.position = PLAYER_START
    npc.position = NPC_POSITION
    _set_campaign_scene("echo_isles", PLAYER_START)
    npc_routine_index = 0
    npc_routine_wait = 2.0
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
    campaign_dialogue_context.clear()
    campaign_branch_input_active = false
    _set_modal_hud(false)
    tutorial_label.modulate.a = 1.0
    player_collision_body.position = PLAYER_START
    _sync_npc_anchors()
    for actor_list in campaign_actor_nodes.values():
        for campaign_actor in actor_list:
            if is_instance_valid(campaign_actor):
                campaign_actor.visible = false
    for label_list in campaign_actor_name_nodes.values():
        for campaign_label in label_list:
            if is_instance_valid(campaign_label):
                campaign_label.visible = false
    _set_quest_state("available")

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
        "minimap_texture_loaded": minimap_texture != null and minimap_texture.texture != null,
        "encounter_manager_loaded": encounter_manager != null,
        "quest_state": quest_state,
    }
