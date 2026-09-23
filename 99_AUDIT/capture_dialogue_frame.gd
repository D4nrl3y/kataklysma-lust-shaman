extends SceneTree

func _init() -> void:
    call_deferred("_capture")

func _capture() -> void:
    var demo = load("res://03_GODOT/scenes/main.tscn").instantiate()
    root.add_child(demo)
    await process_frame
    demo._start_new_game()
    demo.player.position = demo.NPC_POSITION
    demo._interact_with_npc()
    await process_frame
    var image: Image = root.get_viewport().get_texture().get_image()
    image.save_png("res://99_AUDIT/demo_dialogue_frame.png")
    print("DEMO_DIALOGUE_FRAME_CAPTURE: PASS")
    quit(0)
