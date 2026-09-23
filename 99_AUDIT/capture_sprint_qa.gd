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
    await _save_frame("01_menu_final.png")

    demo._start_new_game()
    demo.player.position = Vector2(300.0, 250.0)
    demo.player_collision_body.position = demo.player.position
    await _save_frame("02_scale_hut.png")
    demo.player.position = Vector2(470.0, 390.0)
    demo.player_collision_body.position = demo.player.position
    await _save_frame("03_scale_training_area.png")

    demo._toggle_walkability_debug()
    demo.toast_label.text = ""
    await _save_frame("04_walkable_debug.png")
    demo._toggle_walkability_debug()
    demo.toast_label.text = ""

    demo.player.position = Vector2(250.0, 760.0)
    demo.player_collision_body.position = demo.player.position
    await _save_frame("05_blocked_water.png")
    demo.player.position = Vector2(120.0, 470.0)
    demo.player_collision_body.position = demo.player.position
    await _save_frame("06_blocked_cliff.png")
    demo.player.position = Vector2(575.0, 380.0)
    demo.player_collision_body.position = demo.player.position
    await _save_frame("07_blocked_rocks.png")

    demo.player.position = Vector2(700.0, 430.0)
    demo.player_collision_body.position = demo.player.position
    demo.player.play("idle_back")
    await _save_frame("08_idle_back.png")
    demo.player.play("idle_left")
    demo.player.flip_h = false
    await _save_frame("09_idle_left.png")
    demo.player.play("idle_right")
    demo.player.flip_h = false
    await _save_frame("10_idle_right.png")
    demo.player.play("walk_back")
    await _save_frame("11_walk_back.png")
    demo.player.play("walk_left")
    demo.player.flip_h = false
    await _save_frame("12_walk_left.png")
    demo.player.play("walk_right")
    demo.player.flip_h = false
    await _save_frame("13_walk_right.png")

    demo.player.position = demo.NPC_POSITION
    demo.player_collision_body.position = demo.player.position
    demo._interact_with_npc()
    await _save_frame("14_dialogue_zekranu.png")
    demo._apply_dialogue_choice(1)
    await _save_frame("15_dialogue_kataklysma.png")
    demo.dialogue_panel.visible = false
    demo._interact_with_npc()
    await _save_frame("16_dialogue_vertical_choices.png")

    demo.dialogue_panel.visible = false
    demo._reset_demo()
    demo._set_gameplay_visible(true)
    demo._hide_tutorial()
    demo.tutorial_label.visible = false
    demo.toast_label.text = ""
    await _save_frame("17_minimap_final.png")
    await _save_frame("18_quest_before_accept.png")

    demo.player.position = demo.NPC_POSITION
    demo.player_collision_body.position = demo.player.position
    demo._interact_with_npc()
    demo._apply_dialogue_choice(1)
    demo._confirm_dialogue()
    await _save_frame("19_quest_after_accept.png")

    demo.dialogue_panel.visible = false
    demo.player.position = Vector2(760.0, 505.0)
    demo.player_collision_body.position = demo.player.position
    demo.tutorial_label.visible = false
    demo.toast_label.text = ""
    await _save_frame("20_gameplay_final.png")

    demo.audio_manager.free()
    demo.free()
    print("SPRINT_QA_CAPTURE: PASS")
    quit(0)

func _save_frame(file_name: String) -> void:
    await process_frame
    var image: Image = root.get_viewport().get_texture().get_image()
    image.save_png("%s/%s" % [OUTPUT_DIR, file_name])
