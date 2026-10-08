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
    if not bool(demo.menu_layer.visible) or bool(demo.world_started):
        failures.append("initial main menu state")
    if demo.options_menu == null:
        failures.append("options menu instance")
    else:
        demo._show_menu_options()
        if not bool(demo.options_menu.visible):
            failures.append("options menu open")
        demo.options_menu.visible = false
        demo.options_menu.settings["show_minimap"] = false
        demo.options_menu._apply_settings(false)
        if bool(demo.minimap_panel.visible):
            failures.append("minimap option off")
        demo.options_menu.settings["show_minimap"] = true
        demo.options_menu._apply_settings(false)
        if not bool(demo.minimap_panel.visible):
            failures.append("minimap option on")
    demo._start_new_game()
    if not bool(demo.world_started):
        failures.append("new game start")
    if not bool(demo.camera.enabled) or demo.camera.limit_right != int(demo.MAP_SIZE.x):
        failures.append("camera limits")
    if demo.camera.get_parent() != demo.player:
        failures.append("camera is not attached to the player")
    if demo.player.get_parent() == null or not bool(demo.player.get_parent().y_sort_enabled):
        failures.append("player Y-sort root")
    if demo.npc.get_parent() == null or demo.player.get_parent() != demo.npc.get_parent():
        failures.append("shared player/NPC Y-sort root")
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
    if demo.player.sprite_frames.get_frame_count("idle_back") != 2:
        failures.append("idle back frame count")
    if demo.player.sprite_frames.get_frame_count("idle_left") != 2:
        failures.append("idle left frame count")
    if demo.player.sprite_frames.get_frame_count("idle_right") != 2:
        failures.append("idle right frame count")
    for directional_name in ["walk_back", "walk_left", "walk_right"]:
        if demo.player.sprite_frames.get_frame_count(directional_name) != 8:
            failures.append(directional_name + " frame count")
        elif demo.player.sprite_frames.get_frame_texture(directional_name, 0) == demo.player.sprite_frames.get_frame_texture("walk_front", 0):
            failures.append(directional_name + " uses front fallback")
    for walkable_position in [demo.NPC_POSITION, demo.OBJECTIVE_POSITION, Vector2(340.0, 320.0), Vector2(1380.0, 192.0), Vector2(1400.0, 482.0)]:
        if not bool(demo._is_walkable_position(walkable_position)):
            failures.append("walkable sample " + str(walkable_position))
    for prop_ground in [Vector2(381.0, 360.0), Vector2(420.0, 346.0), Vector2(470.0, 332.0), Vector2(505.0, 323.0), Vector2(573.0, 346.0), Vector2(596.0, 359.0)]:
        if bool(demo._is_walkable_position(prop_ground - Vector2(0.0, 48.0))):
            failures.append("solid training prop not blocked " + str(prop_ground))
    for blocked_position in [Vector2(250.0, 760.0), Vector2(100.0, 500.0), Vector2(1500.0, 850.0), Vector2(150.0, 620.0)]:
        if bool(demo._is_walkable_position(blocked_position)):
            failures.append("blocked sample " + str(blocked_position))
    if not bool(demo.tutorial_label.visible) or bool(demo.story_flags.get("tutorial_movement_seen", false)):
        failures.append("movement tutorial initial state")
    demo.tutorial_time = 2.99
    demo._process(0.02)
    if not bool(demo.story_flags.get("tutorial_movement_seen", false)):
        failures.append("movement tutorial timer flag")
    await create_timer(0.4).timeout
    if bool(demo.tutorial_label.visible):
        failures.append("movement tutorial fade out")

    var checks: Dictionary = demo.demo_smoke_test()
    for check_name in ["player_loaded", "player_idle_frames", "npc_loaded", "npc_idle_frames", "quest_marker_loaded", "objective_marker_loaded", "minimap_texture_loaded", "encounter_manager_loaded"]:
        if not bool(checks.get(check_name, false)):
            failures.append(check_name)
    _expect_state(demo, "available", "initial quest state")

    var starting_spirit := int(demo.attributes["spirit"])
    var starting_affinity := int(demo.npc_affinity["zekranu"])
    demo._interact_with_npc()
    if demo.dialogue_portrait.texture == null:
        failures.append("Zekranu portrait")
    demo._confirm_dialogue()
    if int(demo.attributes["spirit"]) != starting_spirit + 2:
        failures.append("dialogue choice attribute consequence")
    if int(demo.npc_affinity["zekranu"]) != starting_affinity + 2:
        failures.append("dialogue choice NPC affinity consequence")
    demo._confirm_dialogue()
    if demo.dialogue_portrait.texture == null:
        failures.append("Kataklysma portrait")
    _expect_state(demo, "in_progress", "quest acceptance")

    demo.player.position = demo.OBJECTIVE_POSITION
    demo._interact_with_objective()
    demo._confirm_dialogue()
    _expect_state(demo, "complete", "objective completion")
    if not bool(demo.cg_active) or demo.cg_frames.size() != 4 or demo.cg_image.texture == null:
        failures.append("CG sequence assets/state")
    for expected_frame in range(1, 4):
        demo._process_cg(2.5)
        if not bool(demo.cg_active) or int(demo.cg_index) != expected_frame:
            failures.append("CG sequence transition to frame %d" % (expected_frame + 1))
        elif demo.cg_image.texture == null or demo.cg_image.texture.resource_path != str(demo.cg_frames[expected_frame]):
            failures.append("CG sequence texture frame %d" % (expected_frame + 1))
    demo._process_cg(2.5)
    if bool(demo.cg_active):
        failures.append("CG sequence did not complete")
    demo.cg_active = false
    demo.cg_layer.visible = false

    demo.player.position = demo.NPC_POSITION
    demo._interact_with_npc()
    demo._confirm_dialogue()
    _expect_state(demo, "turned_in", "quest delivery")

    demo._toggle_pause()
    if not bool(demo.paused) or not bool(demo.pause_layer.visible):
        failures.append("pause open")
    demo._toggle_pause()
    if bool(demo.paused) or bool(demo.pause_layer.visible):
        failures.append("pause resume")

    for noncombat_type in ["npc_walkby", "resource_find", "spirit_omen"]:
        demo._start_encounter({"type": noncombat_type, "actors": []})
        if bool(demo.encounter_active):
            failures.append("non-combat event opened battle: " + noncombat_type)

    demo._start_encounter({"type": "monster_ambush", "actors": ["makrura_corrupted"]})
    if not bool(demo.encounter_active):
        failures.append("encounter start")
    for _turn in range(12):
        if str(demo.combat_system.phase) != "player_turn":
            break
        var attack_event := InputEventKey.new()
        attack_event.keycode = KEY_1
        demo._handle_encounter_input(attack_event)
    if not bool(demo.encounter_choice_made):
        failures.append("combat did not reach a terminal result")
    var confirm_event := InputEventKey.new()
    confirm_event.keycode = KEY_ESCAPE
    demo._handle_encounter_input(confirm_event)
    if bool(demo.encounter_active):
        failures.append("encounter resolution")

    var saved_quest_state: String = str(demo.quest_state)
    var saved_attributes: Dictionary = demo.attributes.duplicate(true)
    var saved_affinity: Dictionary = demo.npc_affinity.duplicate(true)
    var saved_flags: Dictionary = demo.story_flags.duplicate(true)
    var saved_pois: Dictionary = demo.discovered_pois.duplicate(true)
    demo._save_game()
    var saved_position: Vector2 = demo.player.position
    demo.player.position = demo.NPC_POSITION
    demo.attributes["spirit"] = -1
    demo.quest_state = "available"
    demo._load_game()
    if demo.player.position != saved_position:
        failures.append("save/load position")
    if str(demo.quest_state) != saved_quest_state or not _numeric_dictionaries_match(demo.attributes, saved_attributes):
        failures.append("save/load quest and attributes")
    if not _numeric_dictionaries_match(demo.npc_affinity, saved_affinity) or demo.story_flags != saved_flags or demo.discovered_pois != saved_pois:
        failures.append("save/load affinity, flags and POIs")

    if demo.encounter_manager.try_roll(demo.ZONE_ID, false):
        failures.append("zone id was incorrectly accepted as encounter table")
    for _step in 18:
        demo.encounter_manager.register_step()
    if not demo.encounter_manager.try_roll("echo_isles_day", false):
        failures.append("Echo Isles encounter table did not roll")
    elif bool(demo.encounter_active) and str(demo.combat_system.enemy.get("id", "")) not in ["water_spirit_weakened", "corrupted_makrura"]:
        failures.append("encounter selected an unsupported combat actor")

    if failures.is_empty():
        print("DEMO_SMOKE_TEST: PASS")
    else:
        print("DEMO_SMOKE_TEST: FAIL -> %s" % ", ".join(failures))
    if demo.audio_manager:
        demo.audio_manager.stop_ambience()
    demo.queue_free()
    await process_frame
    await create_timer(0.5).timeout
    _finish()

func _expect_state(demo, expected: String, label: String) -> void:
    if str(demo.quest_state) != expected:
        failures.append("%s expected %s got %s" % [label, expected, str(demo.quest_state)])

func _numeric_dictionaries_match(actual: Dictionary, expected: Dictionary) -> bool:
    if actual.size() != expected.size():
        return false
    for key in expected:
        if not actual.has(key) or int(actual[key]) != int(expected[key]):
            return false
    return true

func _finish() -> void:
    quit(0 if failures.is_empty() else 1)
