extends SceneTree


func _init() -> void:
    call_deferred("_capture")


func _capture() -> void:
    var demo = load("res://03_GODOT/scenes/main.tscn").instantiate()
    root.add_child(demo)
    await process_frame
    demo._start_new_game()
    demo._start_encounter({"type": "monster_ambush", "actors": ["wild_boar"]})
    await process_frame
    await process_frame
    var image: Image = root.get_viewport().get_texture().get_image()
    var output_path := ProjectSettings.globalize_path("res://docs/qa/screenshots/24_wild_boar_candidate.png")
    var error := image.save_png(output_path)
    if error != OK:
        push_error("Could not save wild boar candidate QA capture: %s" % error)
        demo.queue_free()
        await process_frame
        quit(1)
        return
    print("WILD_BOAR_CANDIDATE_CAPTURE: PASS | %s" % output_path)
    demo.queue_free()
    await process_frame
    quit(0)
