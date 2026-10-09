extends SceneTree

const OUTPUT_DIR := "res://docs/qa/screenshots/phase2"

var failures: Array[String] = []
var save_path := ""
var settings_path := ""


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var demo = load("res://03_GODOT/scenes/main.tscn").instantiate()
	var nonce := str(Time.get_ticks_usec())
	save_path = "user://phase2_capture_%s.json" % nonce
	settings_path = "user://phase2_capture_%s.cfg" % nonce
	demo.save_path_override = save_path
	demo.options_settings_path_override = settings_path
	root.add_child(demo)
	await process_frame
	demo.audio_manager.enabled = false
	demo.camera.position_smoothing_enabled = false
	await _capture("01_campaign_menu.png")
	for child in demo.menu_layer.get_children():
		if child is Button and child.text == "NOVO JOGO":
			child.pressed.emit()
			break
	await process_frame
	await _capture("02_cabin_opening_dialogue.png")
	demo._confirm_dialogue()
	await process_frame
	await process_frame
	var window_marker: Label = demo.campaign_point_nodes.get("q001_window")
	if window_marker:
		var window_marker_center: Vector2 = window_marker.get_global_transform_with_canvas() * (window_marker.size * 0.5)
		if window_marker.visible and window_marker_center.y < 70.0:
			_fail("offscreen cabin interaction marker is hidden rather than clipped at the top edge")
	await _capture("03_q001_cabin.png")
	for point_id in ["q001_necklace", "q001_bowl", "q001_window", "q001_pouch"]:
		_use_point(demo, point_id)
	_open_branch(demo, "q001_choice")
	await _capture("04_q001_vertical_choices.png")
	_choose_branch(demo, "q001_choice", "confident")
	_use_point(demo, "q001_exit")
	_use_point(demo, "q001_zekranu")
	for point_id in ["q002_earth", "q002_fire", "q002_water", "q002_air"]:
		_use_point(demo, point_id)
	await _capture("05_q002_totem_circle.png")
	_open_branch(demo, "q002_answer")
	await _capture("06_q002_zekranu_choices.png")
	_choose_branch(demo, "q002_answer", "method")
	await _capture("07_q002_cg_start.png")
	for _advance in 2:
		if demo.cg_active:
			demo._advance_cg()
	await _capture("08_q002_cg_climax.png")
	for _advance in 2:
		if demo.cg_active:
			demo._advance_cg()

	_use_point(demo, "q003_request")
	_choose_branch(demo, "q003_method", "surplus")
	_use_point(demo, "q003_surplus")
	_use_point(demo, "q003_return")
	_use_point(demo, "q004_request")
	_use_point(demo, "q004_apprentice")
	_open_branch(demo, "q004_apprentice")
	await _capture("09_q004_apprentice_choices.png")
	_choose_branch(demo, "q004_apprentice", "barter")
	await _capture("10_q004_frog_collection_progress.png")
	for _frog in 4:
		_use_point(demo, "q004_frogs")
	_use_point(demo, "q004_deliver")
	_use_point(demo, "q005_shore")
	_open_point_dialogue(demo, "q005_spirit")
	await _capture("11_q005_water_spirit.png")
	demo._confirm_dialogue()
	_use_point(demo, "q005_trace")
	_choose_branch(demo, "q005_choice", "help")
	await _capture("12_q005_cg.png")
	for _advance in 4:
		if demo.cg_active:
			demo._advance_cg()

	_use_point(demo, "q006_boss")
	await _capture("13_q006_makrura_combat.png")
	var neutralize_event := InputEventKey.new()
	neutralize_event.keycode = KEY_7
	demo._handle_encounter_input(neutralize_event)
	var close_event := InputEventKey.new()
	close_event.keycode = KEY_ESCAPE
	demo._handle_encounter_input(close_event)
	await _capture("14_q006_boss_resolution_cg.png")
	for _advance in 4:
		if demo.cg_active:
			demo._advance_cg()
	_choose_branch(demo, "q006_fragment", "study")
	_use_point(demo, "q007_clues")
	_use_point(demo, "q007_children")
	_open_branch(demo, "q007_children")
	await _capture("15_q007_children_choices.png")
	_choose_branch(demo, "q007_children", "protect")
	_use_point(demo, "q007_restore")
	_use_point(demo, "q008_pack")
	_use_point(demo, "q008_makjala")
	_use_point(demo, "q008_rakjin")
	_choose_branch(demo, "q008_choice", "ambition")
	await _capture("16_q008_departure_choice.png")
	_use_point(demo, "q008_boat")
	await _capture("17_q008_departure_complete.png")

	var audio_manager: Node = demo.audio_manager
	demo.queue_free()
	await process_frame
	if audio_manager:
		audio_manager.stop_ambience()
	for path in [save_path, settings_path]:
		var absolute_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)
	await _capture_q003_hunt_route()
	if failures.is_empty():
		print("CAMPAIGN_QA_CAPTURE: PASS (21 current campaign screenshots)")
		quit(0)
	else:
		push_error("CAMPAIGN_QA_CAPTURE: FAIL -> %s" % ", ".join(failures))
		quit(1)


func _capture_q003_hunt_route() -> void:
	var hunt_demo = load("res://03_GODOT/scenes/main.tscn").instantiate()
	var nonce := str(Time.get_ticks_usec())
	save_path = "user://phase2_hunt_capture_%s.json" % nonce
	settings_path = "user://phase2_hunt_capture_%s.cfg" % nonce
	hunt_demo.save_path_override = save_path
	hunt_demo.options_settings_path_override = settings_path
	root.add_child(hunt_demo)
	await process_frame
	hunt_demo.audio_manager.enabled = false
	hunt_demo._set_gameplay_visible(true)
	hunt_demo.menu_layer.visible = false
	hunt_demo.campaign_mode = true
	for quest_id_value in hunt_demo.campaign_definition.get("quest_order", []):
		var quest_id := str(quest_id_value)
		if quest_id == "QST_ECHO_003":
			hunt_demo.campaign_runtime.quest_records[quest_id]["state"] = "in_progress"
			break
		hunt_demo.campaign_runtime.quest_records[quest_id]["state"] = "turned_in"
	hunt_demo._campaign_sync_mirrors()
	hunt_demo._set_campaign_scene("echo_isles", Vector2(430.0, 355.0))
	hunt_demo._refresh_campaign_world()
	_use_point(hunt_demo, "q003_request")
	_choose_branch(hunt_demo, "q003_method", "hunt")
	for portion in 4:
		_use_point(hunt_demo, "q003_hunt")
		if portion == 0:
			await _capture("18_q003_hunt_battle.png")
		var snapshot: Dictionary = hunt_demo.combat_system.get_snapshot()
		for _turn in 30:
			if str(snapshot.get("phase", "")) != "player_turn":
				break
			snapshot = hunt_demo.combat_system.perform_action("strike")
		if str(snapshot.get("result", "")) != "victory":
			_fail("Q003 wild-boar hunt reaches victory for each of four portions")
			break
		hunt_demo.encounter_choice_made = true
		var close_event := InputEventKey.new()
		close_event.keycode = KEY_ESCAPE
		hunt_demo._handle_encounter_input(close_event)
	_use_point(hunt_demo, "q003_return")
	if not hunt_demo.cg_active or hunt_demo.cg_frames.size() != 4:
		_fail("Q003 hunt branch triggers the four-frame CG")
	else:
		await _capture("19_q003_hunt_cg_start.png")
		for _advance in 2:
			hunt_demo._advance_cg()
		await _capture("20_q003_hunt_cg_climax.png")
		hunt_demo._advance_cg()
		await _capture("21_q003_hunt_cg_resolution.png")
		hunt_demo._advance_cg()
	if hunt_demo.audio_manager:
		hunt_demo.audio_manager.stop_ambience()
	hunt_demo.queue_free()
	await process_frame
	for path in [save_path, settings_path]:
		var absolute_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)


func _use_point(demo, point_id: String) -> void:
	var point := _find_point(demo, point_id)
	if point.is_empty():
		_fail("point is available: " + point_id)
		return
	_position_player_for_point(demo, point)
	demo._try_campaign_interact()
	if demo.dialogue_action in ["campaign_ack", "campaign_finish_ack"]:
		demo._confirm_dialogue()


func _open_branch(demo, point_id: String) -> void:
	var point := _find_point(demo, point_id)
	if point.is_empty():
		_fail("branch point is available: " + point_id)
		return
	_position_player_for_point(demo, point)
	demo._try_campaign_interact()
	if not demo.campaign_branch_input_active:
		_fail("branch choice opens: " + point_id)


func _open_point_dialogue(demo, point_id: String) -> void:
	var point := _find_point(demo, point_id)
	if point.is_empty():
		_fail("dialogue point is available: " + point_id)
		return
	_position_player_for_point(demo, point)
	demo._try_campaign_interact()
	if demo.dialogue_action.is_empty():
		_fail("NPC dialogue opens for screenshot: " + point_id)
	if point_id == "q005_spirit":
		var spirits: Array = demo.campaign_actor_nodes.get("water_spirit", [])
		if spirits.is_empty() or not is_instance_valid(spirits[0]) or not spirits[0].visible:
			_fail("water spirit remains visible in the world during dialogue")
		elif spirits[0].position.distance_to(demo.player.position) < 32.0:
			_fail("water spirit is spatially distinct from Kataklysma during dialogue")


func _position_player_for_point(demo, point: Dictionary) -> void:
	var position_data: Array = point.get("position", [0.0, 0.0])
	demo.player.position = Vector2(float(position_data[0]), float(position_data[1]))
	demo.player_collision_body.position = demo.player.position


func _choose_branch(demo, point_id: String, branch_id: String) -> void:
	var point := _find_point(demo, point_id)
	if point.is_empty():
		_fail("branch point is available: " + point_id)
		return
	if not demo.campaign_branch_input_active:
		_open_branch(demo, point_id)
	if not demo.campaign_branch_input_active:
		return
	var branches: Array[Dictionary] = demo.campaign_runtime.get_available_branches(str(point.get("quest_id", "")), str(point.get("group_id", "")))
	for index in branches.size():
		if str(branches[index].get("id", "")) == branch_id:
			demo._apply_campaign_branch_choice(index + 1)
			demo._confirm_dialogue()
			return
	_fail("branch exists: " + point_id + "/" + branch_id)


func _find_point(demo, point_id: String) -> Dictionary:
	for point in demo.campaign_world_runtime.get_points_for_scene(demo.campaign_scene_id, demo.campaign_runtime):
		if str(point.get("id", "")) == point_id:
			return point
	return {}


func _capture(file_name: String) -> void:
	await process_frame
	await process_frame
	var viewport_texture: ViewportTexture = root.get_viewport().get_texture()
	if viewport_texture == null:
		_fail("viewport unavailable for " + file_name)
		return
	var image: Image = viewport_texture.get_image()
	if image == null or image.is_empty():
		_fail("rendered image is empty for " + file_name)
		return
	var output_path := "%s/%s" % [ProjectSettings.globalize_path(OUTPUT_DIR), file_name]
	var error := image.save_png(output_path)
	if error != OK:
		_fail("could not save %s (%d)" % [file_name, error])
	else:
		print("CAMPAIGN_QA_IMAGE | %s | %dx%d" % [output_path, image.get_width(), image.get_height()])


func _fail(message: String) -> void:
	failures.append(message)
	push_error("CAMPAIGN_QA_CAPTURE: " + message)
