extends SceneTree

const OUTPUT_DIR := "res://docs/qa/screenshots/user_report_regression"

var failures: Array[String] = []
var demo

func _init() -> void:
	call_deferred("_capture")

func _capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	demo = load("res://03_GODOT/scenes/main.tscn").instantiate()
	var nonce := str(Time.get_ticks_usec())
	demo.save_path_override = "user://user_report_capture_%s.json" % nonce
	demo.options_settings_path_override = "user://user_report_capture_%s.cfg" % nonce
	root.add_child(demo)
	await process_frame
	demo.audio_manager.enabled = false
	demo.camera.position_smoothing_enabled = false
	demo._start_campaign_game()
	demo._close_campaign_dialogue()
	demo.set_process(false)
	demo._hide_tutorial()
	demo.tutorial_label.visible = false
	demo.toast_label.text = ""
	demo.toast_time = 0.0
	demo.dialogue_panel.visible = false
	demo.player.speed_scale = 0.0

	demo._set_campaign_scene("cabin", Vector2(835.0, 555.0))
	demo._refresh_campaign_world()
	demo.player.animation = &"idle_front"
	demo.player.frame = 0
	demo.player.pause()
	demo._apply_player_frame_calibration()
	await _save_frame("01_cabin_scale.png")

	var side_capture_position := Vector2(500.0, 350.0)
	demo._set_campaign_scene("echo_isles", side_capture_position)
	if not demo._is_walkable_position(side_capture_position):
		failures.append("side-frame capture position is outside the training-clearing path")
	demo.gameplay_hud.visible = false
	for marker in demo.campaign_point_nodes.values():
		marker.visible = false
	for label_list in demo.campaign_actor_name_nodes.values():
		for actor_label in label_list:
			actor_label.visible = false
	demo.npc_name.visible = false
	demo.quest_marker.visible = false
	demo.objective_marker.visible = false
	demo.random_resource_marker.visible = false
	demo.interaction_prompt.visible = false
	demo.player.animation = &"walk_left"
	demo.player.frame = 4
	demo.player.pause()
	demo._apply_player_frame_calibration()
	await _save_frame("02_side_walk_normalized.png")

	demo.gameplay_hud.visible = true
	demo._set_campaign_scene("cabin", Vector2(835.0, 555.0))
	var exit_point: Dictionary = {}
	for point_value in demo.campaign_interaction_data.get("points", []):
		var point: Dictionary = point_value
		if str(point.get("id", "")) == "q001_exit":
			exit_point = point
			break
	if exit_point.is_empty():
		failures.append("q001_exit interaction not found")
	else:
		demo._process_campaign_point(exit_point)
		if not demo._is_walkable_position(demo.player.position):
			failures.append("outdoor exit spawn is not walkable")
		if demo.dialogue_panel.visible:
			failures.append("cabin exit unexpectedly blocks movement with a modal")
		if demo.toast_label.text.is_empty():
			failures.append("non-modal exit narrative is missing")
		var start_position: Vector2 = demo.player.position
		Input.action_press(&"move_right")
		demo._move_player(0.12)
		Input.action_release(&"move_right")
		if demo.player.position.distance_to(start_position) <= 1.0:
			failures.append("player did not move immediately after leaving the cabin")
		demo.player.pause()
		await _save_frame("03_exit_spawn_after_movement.png")

	demo.audio_manager.stop_ambience()
	var paths := [demo.save_path, demo.options_menu.settings_path]
	demo.queue_free()
	await process_frame
	for path in paths:
		var absolute_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)
	if failures.is_empty():
		print("USER_REPORT_REGRESSION_CAPTURES: PASS (3 PNGs in %s)" % OUTPUT_DIR)
		quit(0)
	else:
		push_error("USER_REPORT_REGRESSION_CAPTURES: FAIL -> %s" % ", ".join(failures))
		quit(1)

func _save_frame(file_name: String) -> void:
	await process_frame
	var viewport_texture: ViewportTexture = root.get_viewport().get_texture()
	if viewport_texture == null:
		failures.append("%s: viewport texture unavailable" % file_name)
		return
	var image: Image = viewport_texture.get_image()
	if image == null or image.is_empty():
		failures.append("%s: viewport produced no pixels" % file_name)
		return
	var error := image.save_png("%s/%s" % [OUTPUT_DIR, file_name])
	if error != OK:
		failures.append("%s: PNG save failed (%d)" % [file_name, error])
