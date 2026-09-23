extends SceneTree

var failures: Array[String] = []

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed_scene: PackedScene = load("res://03_GODOT/scenes/main.tscn")
    if packed_scene == null:
        failures.append("main scene could not be loaded")
        _finish()
        return
    var demo = packed_scene.instantiate()
    root.add_child(demo)
    await process_frame
    demo.audio_manager.enabled = false
    demo._start_new_game()
    if not bool(demo.world_started):
        failures.append("new game start")
    if not bool(demo.camera.enabled) or demo.camera.limit_right != int(demo.MAP_SIZE.x):
        failures.append("camera limits")
    if bool(demo._is_walkable_position(Vector2(250.0, 760.0))):
        failures.append("water walkability boundary")
    if not bool(demo._is_walkable_position(demo.PLAYER_START)):
        failures.append("player start walkability")
    if not bool(demo.collision_probe_for_test(demo.PLAYER_START, Vector2(250.0, 760.0))):
        failures.append("water collision probe")
    if not bool(demo.collision_probe_for_test(demo.PLAYER_START, Vector2(575.0, 380.0))):
        failures.append("rock collision probe")
    if not bool(demo.collision_probe_for_test(demo.PLAYER_START, Vector2(100.0, 500.0))):
        failures.append("cliff collision probe")
    if not bool(demo.collision_probe_for_test(demo.NPC_POSITION - Vector2(100.0, 0.0), demo.NPC_POSITION)):
        failures.append("NPC collision probe")
    for animation_name in ["idle_front", "idle_back", "idle_left", "idle_right", "walk_front", "walk_back", "walk_left", "walk_right"]:
        if not demo.player.sprite_frames.has_animation(animation_name):
            failures.append("animation " + animation_name)

    var checks: Dictionary = demo.demo_smoke_test()
    for check_name in ["player_loaded", "player_idle_frames", "npc_loaded", "npc_idle_frames", "quest_marker_loaded", "objective_marker_loaded", "encounter_manager_loaded"]:
        if not bool(checks.get(check_name, false)):
            failures.append(check_name)
    _expect_state(demo, "available", "initial quest state")

    demo._interact_with_npc()
    if demo.dialogue_portrait.texture == null:
        failures.append("Zekranu portrait")
    demo._confirm_dialogue()
    demo._confirm_dialogue()
    if demo.dialogue_portrait.texture == null:
        failures.append("Kataklysma portrait")
    _expect_state(demo, "in_progress", "quest acceptance")

    demo.player.position = demo.OBJECTIVE_POSITION
    demo._interact_with_objective()
    demo._confirm_dialogue()
    _expect_state(demo, "complete", "objective completion")
    demo.cg_active = false
    demo.cg_layer.visible = false

    demo.player.position = demo.NPC_POSITION
    demo._interact_with_npc()
    demo._confirm_dialogue()
    _expect_state(demo, "turned_in", "quest delivery")

    demo._start_encounter({"type": "monster_ambush", "actors": ["makrura_corrupted"]})
    if not bool(demo.encounter_active):
        failures.append("encounter start")
    for _turn in range(12):
        if str(demo.combat_system.phase) != "player_turn":
            break
        demo._handle_encounter_input(KEY_1)
    if not bool(demo.encounter_choice_made):
        failures.append("combat did not reach a terminal result")
    demo._handle_encounter_input(KEY_E)
    if bool(demo.encounter_active):
        failures.append("encounter resolution")

    demo._save_game()
    var saved_position: Vector2 = demo.player.position
    demo.player.position = demo.NPC_POSITION
    demo._load_game()
    if demo.player.position != saved_position:
        failures.append("save/load position")

    if failures.is_empty():
        print("DEMO_SMOKE_TEST: PASS")
    else:
        print("DEMO_SMOKE_TEST: FAIL -> %s" % ", ".join(failures))
    if demo.audio_manager:
        demo.audio_manager.free()
    demo.free()
    _finish()

func _expect_state(demo, expected: String, label: String) -> void:
    if str(demo.quest_state) != expected:
        failures.append("%s expected %s got %s" % [label, expected, str(demo.quest_state)])

func _finish() -> void:
    quit(0 if failures.is_empty() else 1)
