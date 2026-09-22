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

    var checks: Dictionary = demo.demo_smoke_test()
    for check_name in ["player_loaded", "player_idle_frames", "npc_loaded", "npc_idle_frames", "quest_marker_loaded", "objective_marker_loaded", "encounter_manager_loaded"]:
        if not bool(checks.get(check_name, false)):
            failures.append(check_name)
    _expect_state(demo, "available", "initial quest state")

    demo._interact_with_npc()
    demo._confirm_dialogue()
    _expect_state(demo, "in_progress", "quest acceptance")

    demo.player.position = demo.OBJECTIVE_POSITION
    demo._interact_with_objective()
    demo._confirm_dialogue()
    _expect_state(demo, "complete", "objective completion")

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

    if failures.is_empty():
        print("DEMO_SMOKE_TEST: PASS")
    else:
        print("DEMO_SMOKE_TEST: FAIL -> %s" % ", ".join(failures))
    demo.queue_free()
    _finish()

func _expect_state(demo, expected: String, label: String) -> void:
    if str(demo.quest_state) != expected:
        failures.append("%s expected %s got %s" % [label, expected, str(demo.quest_state)])

func _finish() -> void:
    quit(0 if failures.is_empty() else 1)
