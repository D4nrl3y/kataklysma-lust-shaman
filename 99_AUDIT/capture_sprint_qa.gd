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
    await _save_frame("01_main_menu.png")

    demo._start_new_game()
    await process_frame
    await _save_frame("02_gameplay_scale.png")
    await _save_frame("03_valid_path.png")

    demo.player.position = Vector2(250.0, 760.0)
    demo.player_collision_body.position = demo.player.position
    await process_frame
    await _save_frame("04_blocked_water.png")

    demo.player.position = Vector2(575.0, 380.0)
    demo.player_collision_body.position = demo.player.position
    await process_frame
    await _save_frame("05_blocked_rocks.png")

    demo.player.position = Vector2(650.0, 500.0)
    demo.player_collision_body.position = demo.player.position
    demo.player.play("walk_left")
    demo.player.flip_h = true
    await process_frame
    await _save_frame("06_walk_left.png")

    demo.player.play("walk_right")
    demo.player.flip_h = false
    await process_frame
    await _save_frame("07_walk_right.png")

    demo.player.position = demo.NPC_POSITION
    demo.player_collision_body.position = demo.player.position
    demo._interact_with_npc()
    await process_frame
    await _save_frame("08_dialogue_zekranu.png")

    demo._apply_dialogue_choice(1)
    await process_frame
    await _save_frame("09_dialogue_kataklysma.png")

    demo.dialogue_panel.visible = false
    demo.player.position = demo.PLAYER_START
    demo.player_collision_body.position = demo.player.position
    await process_frame
    await _save_frame("10_minimap_hud.png")

    demo.audio_manager.free()
    demo.free()
    print("SPRINT_QA_CAPTURE: PASS")
    quit(0)

func _save_frame(file_name: String) -> void:
    await process_frame
    var image: Image = root.get_viewport().get_texture().get_image()
    image.save_png("%s/%s" % [OUTPUT_DIR, file_name])
