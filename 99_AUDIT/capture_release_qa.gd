extends SceneTree

const OUTPUT_DIR := "res://docs/qa/screenshots"

func _init() -> void:
    call_deferred("_capture_all")

func _capture_all() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
    var demo = load("res://03_GODOT/scenes/main.tscn").instantiate()
    root.add_child(demo)
    await process_frame
    demo.audio_manager.enabled = false
    await _save_frame("01_release_main_menu.png")

    demo._start_new_game()
    demo._hide_tutorial()
    demo.tutorial_label.visible = false
    demo.toast_label.text = ""
    demo.player.position = Vector2(470.0, 390.0)
    demo.player_collision_body.position = demo.player.position
    await _save_frame("02_release_gameplay_scale.png")

    demo._toggle_walkability_debug()
    demo.toast_label.text = ""
    await _save_frame("03_release_walkable_overlay_01.png")
    demo.player.position = Vector2(1250.0, 220.0)
    demo.player_collision_body.position = demo.player.position
    await _save_frame("04_release_walkable_overlay_02.png")
    demo._toggle_walkability_debug()
    demo.toast_label.text = ""

    demo.player.position = Vector2(250.0, 760.0)
    demo.player_collision_body.position = demo.player.position
    await _save_frame("05_release_blocked_water.png")
    demo.player.position = Vector2(120.0, 470.0)
    demo.player_collision_body.position = demo.player.position
    await _save_frame("06_release_blocked_cliff.png")
    demo.player.position = Vector2(575.0, 380.0)
    demo.player_collision_body.position = demo.player.position
    await _save_frame("07_release_blocked_rocks.png")

    demo.player.position = Vector2(430.0, 470.0)
    demo.player_collision_body.position = demo.player.position
    demo.player.play("walk_front")
    await _save_frame("08_release_walk_front.png")
    demo.player.play("walk_back")
    await _save_frame("09_release_walk_back.png")
    demo.player.play("walk_left")
    demo.player.flip_h = false
    await _save_frame("10_release_walk_left.png")
    demo.player.play("walk_right")
    demo.player.flip_h = false
    await _save_frame("11_release_walk_right.png")

    demo.player.position = demo.NPC_POSITION
    demo.player_collision_body.position = demo.player.position
    demo._interact_with_npc()
    await _save_frame("12_release_dialogue_zekranu.png")
    demo._apply_dialogue_choice(1)
    await _save_frame("13_release_dialogue_kataklysma.png")

    demo.dialogue_panel.visible = false
    demo._confirm_dialogue()
    demo.player.position = demo.PLAYER_START
    demo.player_collision_body.position = demo.player.position
    await _save_frame("14_release_minimap.png")
    await _save_frame("15_release_quest_progress.png")

    demo._start_cg_sequence()
    await _save_frame("16_release_cg.png")
    demo.cg_active = false
    demo.cg_layer.visible = false

    demo._start_encounter({"type": "monster_ambush", "actors": ["makrura_corrupted"]})
    await _save_frame("17_release_combat.png")
    demo.encounter_panel.visible = false
    demo.encounter_active = false
    demo.player.position = Vector2(760.0, 505.0)
    demo.player_collision_body.position = demo.player.position
    await _save_frame("18_release_final_gameplay.png")

    demo.audio_manager.free()
    demo.free()
    print("RELEASE_QA_CAPTURE: PASS")
    quit(0)

func _save_frame(file_name: String) -> void:
    await process_frame
    var image: Image = root.get_viewport().get_texture().get_image()
    image.save_png("%s/%s" % [OUTPUT_DIR, file_name])
