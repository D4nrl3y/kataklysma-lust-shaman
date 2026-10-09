extends SceneTree

var failures: Array[String] = []
var save_path := ""
var check_count := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	save_path = "user://user_report_regression_%s.json" % Time.get_ticks_usec()
	var packed_scene := load("res://03_GODOT/scenes/main.tscn") as PackedScene
	_check(packed_scene != null, "main scene loads")
	if packed_scene == null:
		_finish()
		return
	var demo = packed_scene.instantiate()
	demo.save_path_override = save_path
	root.add_child(demo)
	await process_frame
	demo.audio_manager.enabled = false
	demo._start_campaign_game()
	demo._confirm_dialogue()
	demo.campaign_mode = true
	_check(is_equal_approx(demo.CALIBRATION.get("player_scale", 0.0), 0.22), "outdoor player scale remains at the road-calibrated 0.22")
	_check(is_equal_approx(demo.CALIBRATION.get("cabin_player_scale", 0.0), 0.26), "cabin uses the reviewed 0.26 character scale")

	# Side-view frames must occupy one stable silhouette height and share a floor baseline.
	for scene_id in ["cabin", "echo_isles"]:
		var scene_spawn: Vector2 = Vector2(835.0, 555.0) if scene_id == "cabin" else demo.CABIN_EXIT_SPAWN
		demo._set_campaign_scene(scene_id, scene_spawn)
		var expected_height: float = demo.player_base_scale * demo.player_side_reference_height
		for animation_name in ["idle_left", "idle_right", "walk_left", "walk_right"]:
			var frames: Array = demo.player_frame_geometry.get(animation_name, [])
			_check(not frames.is_empty(), "%s frames are cached" % animation_name)
			for frame_index in range(frames.size()):
				demo.player.animation = StringName(animation_name)
				demo.player.frame = frame_index
				var frame_geometry: Dictionary = frames[frame_index]
				var frame_rect: Rect2i = frame_geometry["rect"]
				var texture_size: Vector2 = frame_geometry["texture_size"]
				var rendered_height: float = float(frame_rect.size.y) * demo.player.scale.y
				var rendered_floor: float = (demo.player.offset.y + float(frame_rect.end.y) - texture_size.y * 0.5) * demo.player.scale.y
				_check(absf(rendered_height - expected_height) <= 0.01, "%s frame %d has normalized visible height" % [animation_name, frame_index + 1])
				_check(absf(rendered_floor - demo.player_reference_floor_offset) <= 0.01, "%s frame %d keeps the same foot pivot" % [animation_name, frame_index + 1])

	# Exercise the actual cabin exit action and the normal gameplay movement loop.
	demo._set_campaign_scene("echo_isles", demo.CABIN_EXIT_SPAWN)
	var map_image: Image = demo.world_background.texture.get_image()
	demo._set_campaign_scene("cabin", Vector2(835.0, 555.0))
	_check(demo._is_walkable_position(demo.player.position), "cabin start position is walkable")
	_check(is_equal_approx(demo.player_base_scale, 0.26), "cabin character scale is applied in gameplay")
	var exit_point: Dictionary = {}
	for point_value in demo.campaign_interaction_data.get("points", []):
		var point: Dictionary = point_value
		if str(point.get("id", "")) == "q001_exit":
			exit_point = point
			break
	_check(not exit_point.is_empty(), "QST_ECHO_001 cabin exit point exists")
	if not exit_point.is_empty():
		demo._process_campaign_point(exit_point)
	_check(demo.campaign_scene_id == "echo_isles", "cabin exit changes to Echo Isles")
	_check(demo.player.position == demo.CABIN_EXIT_SPAWN, "cabin exit uses the tested outdoor trail spawn")
	_check(demo._is_walkable_position(demo.player.position), "outdoor exit spawn is walkable")
	var exit_sand_pixels := _visual_sand_pixels(map_image, demo.player.position)
	print("CABIN_EXIT_GROUND_SAMPLE | position=%s | dirt_pixels=%d/273" % [demo.player.position, exit_sand_pixels])
	_check(exit_sand_pixels >= 200, "exit spawn footprint overlaps visible dirt path, not rock or water")
	_check(not demo.dialogue_panel.visible, "cabin exit does not open a movement-blocking modal")
	_check(not demo.toast_label.text.is_empty(), "cabin exit keeps its narrative as a non-modal toast")
	for direction_value in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		var target: Vector2 = demo.player.position + direction_value * 12.0
		_check(demo._is_walkable_position(target), "exit spawn has walkable clearance toward %s" % direction_value)
		_check(not demo.collision_probe_for_test(demo.player.position, target), "exit spawn has physical clearance toward %s" % direction_value)
	var start_position: Vector2 = demo.player.position
	Input.action_press(&"move_right")
	demo._process(0.12)
	Input.action_release(&"move_right")
	var moved_distance: float = demo.player.position.distance_to(start_position)
	print("CABIN_EXIT_MOTION | start=%s | end=%s | distance=%.2f" % [start_position, demo.player.position, moved_distance])
	_check(moved_distance > 1.0, "movement resumes immediately through the gameplay process")
	_check(is_equal_approx(demo.player_base_scale, 0.22), "outdoor character scale is restored after leaving cabin")
	if demo.audio_manager:
		demo.audio_manager.stop_ambience()
		if demo.audio_manager.music_player:
			demo.audio_manager.music_player.stream = null
	demo.queue_free()
	await process_frame
	await create_timer(0.25).timeout
	var absolute_save_path := ProjectSettings.globalize_path(save_path)
	if FileAccess.file_exists(absolute_save_path):
		DirAccess.remove_absolute(absolute_save_path)
	_finish()

func _check(condition: bool, label: String) -> void:
	check_count += 1
	if not condition:
		failures.append(label)
		push_error("USER_REPORT_REGRESSION_TEST: " + label)

func _visual_sand_pixels(image: Image, actor_position: Vector2) -> int:
	var foot_point := actor_position + Vector2(0.0, 40.0)
	var sand_pixels := 0
	for y in range(roundi(foot_point.y) - 6, roundi(foot_point.y) + 7):
		for x in range(roundi(foot_point.x) - 10, roundi(foot_point.x) + 11):
			var color := image.get_pixel(x, y)
			if color.r > color.g * 1.08 and color.g > color.b * 1.05 and color.r > 55.0 / 255.0:
				sand_pixels += 1
	return sand_pixels

func _finish() -> void:
	if failures.is_empty():
		print("USER_REPORT_REGRESSION_TEST: PASS (%d checks)" % check_count)
		quit(0)
	else:
		push_error("USER_REPORT_REGRESSION_TEST: FAIL (%d issues)" % failures.size())
		quit(1)
