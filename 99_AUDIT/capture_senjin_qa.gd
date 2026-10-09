extends SceneTree

const OUTPUT_DIR := "res://docs/qa/screenshots/phase3"

var failures: Array[String] = []
var save_path := ""
var settings_path := ""
var demo

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var nonce := str(Time.get_ticks_usec())
	save_path = "user://senjin_capture_%s.json" % nonce
	settings_path = "user://senjin_capture_%s.cfg" % nonce
	var packed_scene: PackedScene = load("res://03_GODOT/scenes/main.tscn")
	_check(packed_scene != null, "main scene loads for Sen’jin captures")
	if packed_scene == null:
		_finish()
		return
	demo = packed_scene.instantiate()
	demo.save_path_override = save_path
	demo.options_settings_path_override = settings_path
	root.add_child(demo)
	await process_frame
	demo.audio_manager.enabled = false
	demo.camera.position_smoothing_enabled = false
	demo.campaign_mode = true
	demo.menu_layer.visible = false
	demo._set_gameplay_visible(true)
	for quest_id_value in demo.campaign_definition.get("quest_order", []):
		var quest_id := str(quest_id_value)
		demo.campaign_runtime.quest_records[quest_id]["state"] = "turned_in"
	demo.campaign_runtime.quest_records["QST_SEN_009"]["state"] = "in_progress"
	demo.campaign_runtime.inventory["gold"] = 100
	demo.campaign_runtime.tutorial_flags["movement_seen"] = true
	demo.campaign_runtime.set_flag("FLG_SEN_ARRIVAL_INTRO_SEEN", true)
	demo.story_flags["tutorial_movement_seen"] = true
	demo._set_campaign_scene("senjin_village", Vector2(1325.0, 690.0))
	demo._campaign_sync_mirrors()
	demo._refresh_campaign_world()
	demo.tutorial_label.visible = false
	_check(demo.world_background.texture != null and str(demo.world_background.texture.resource_path).ends_with("senjin_village_background_concept_v001.png"), "Sen’jin background is loaded")
	_check(demo.senjin_foreground != null and demo.senjin_foreground.texture != null and demo.senjin_foreground.visible, "Sen’jin foreground candidate is imported and visible")
	_check(demo._is_walkable_position(demo.player.position), "arrival spawn is walkable")
	await _capture("01_senjin_arrival_gameplay.png")
	demo.player.position = Vector2(220.0, 500.0)
	demo.player_collision_body.position = demo.player.position
	_check(demo._is_walkable_position(demo.player.position), "foreground comparison position on the adjacent village path is walkable")
	await _capture("07_senjin_foreground_candidate.png")
	demo.player.position = Vector2(1325.0, 690.0)
	demo.player_collision_body.position = demo.player.position
	var original_camera_position: Vector2 = demo.camera.position
	var original_camera_zoom: Vector2 = demo.camera.zoom
	demo.camera.position = Vector2(836.0, 470.5) - demo.player.position
	demo.camera.zoom = Vector2(0.75, 0.75)
	var debug_key := InputEventKey.new()
	debug_key.keycode = KEY_F10
	debug_key.pressed = true
	demo._unhandled_input(debug_key)
	_check(demo.walkability_debug.visible, "F10 walkability overlay toggle activates the Sen’jin geometry")
	await _capture("08_senjin_walkability_debug.png")
	demo._unhandled_input(debug_key)
	demo.camera.position = original_camera_position
	demo.camera.zoom = original_camera_zoom

	var arrival: Dictionary = demo.campaign_dialogue_data.get("senjin", {}).get("arrival", {})
	demo._campaign_show_custom_dialogue(str(arrival.get("title", "Chegada a Sen’jin")), str(arrival.get("body", "")), "campaign_ack", "tazrima")
	await _capture("02_senjin_arrival_dialogue.png")
	demo._confirm_dialogue()
	_use_point("q009_supply_report")
	_use_point("q009_depot")
	_use_point("q009_trail")
	var rukka_point: Dictionary = _find_point("q009_rukka")
	_check(not rukka_point.is_empty(), "Ruk’ka reveal point is available after the depot trail")
	if not rukka_point.is_empty():
		_position_for_point(rukka_point)
		demo._try_campaign_interact()
		_check(demo.dialogue_panel.visible and demo.dialogue_title.text == "Por que a comida sumiu", "Ruk’ka motive scene opens with the localized dialogue")
		var taz_actors: Array = demo.campaign_actor_nodes.get("tazrima", [])
		var rukka_actors: Array = demo.campaign_actor_nodes.get("rukka", [])
		_check(not demo.npc.visible, "Zek’Ranu is not rendered in Sen’jin")
		var taz_council_position := Vector2(811.0, 408.0) + Vector2(-82.0, -22.0)
		var rukka_speaker_position := Vector2(1005.0, 444.0) + Vector2(-72.0, -18.0)
		_check(not taz_actors.is_empty() and taz_actors[0].visible and taz_actors[0].position.distance_to(taz_council_position) <= 2.0, "Taz’Rima is visible at her separate council position")
		_check(not rukka_actors.is_empty() and rukka_actors[0].visible and rukka_actors[0].position.distance_to(rukka_speaker_position) <= 2.0, "Ruk’ka is positioned as the current speaker")
		await _capture("03_senjin_rukka_reveal.png")
		demo._confirm_dialogue()

	var council_point: Dictionary = _find_point("q009_council")
	_check(not council_point.is_empty(), "council resolution point is available after investigation")
	if not council_point.is_empty():
		_position_for_point(council_point)
		demo._try_campaign_interact()
		_check(demo.campaign_branch_input_active, "council presents the four authored resolutions")
		_check(demo.dialogue_choices.text.split("\n", false).size() == 4, "council choices render as a four-line vertical list")
		await _capture("04_senjin_council_choices.png")
		var branches: Array[Dictionary] = demo.campaign_runtime.get_available_branches("QST_SEN_009", "council_resolution")
		var selected_index := -1
		for index in branches.size():
			if str(branches[index].get("id", "")) == "pay_shortage":
				selected_index = index + 1
				break
		_check(selected_index > 0, "protection resolution is available for consequence capture")
		if selected_index > 0:
			demo._apply_campaign_branch_choice(selected_index)
			await _capture("05_senjin_council_consequence.png")
			demo._confirm_dialogue()
			_check(demo.campaign_runtime.get_quest_state("QST_SEN_009") == "turned_in", "captured protection path resolves the quest")
			await _capture("06_senjin_supply_secured.png")

	if failures.is_empty():
		print("SENJIN_QA_CAPTURE: PASS (8 PNGs; scene, foreground, walkability, arrival, Ruk’ka, choices, consequence, resolution)")
	else:
		push_error("SENJIN_QA_CAPTURE: FAIL -> %s" % ", ".join(failures))
	if demo and demo.audio_manager:
		demo.audio_manager.stop_ambience()
	if demo:
		demo.queue_free()
	await process_frame
	_finish()

func _use_point(point_id: String) -> void:
	var point := _find_point(point_id)
	_check(not point.is_empty(), "Sen’jin point is available: " + point_id)
	if point.is_empty():
		return
	_position_for_point(point)
	demo._try_campaign_interact()
	if demo.dialogue_action in ["campaign_ack", "campaign_finish_ack"]:
		demo._confirm_dialogue()

func _find_point(point_id: String) -> Dictionary:
	for point in demo.campaign_world_runtime.get_points_for_scene("senjin_village", demo.campaign_runtime):
		if str(point.get("id", "")) == point_id:
			return point
	return {}

func _position_for_point(point: Dictionary) -> void:
	var position_data: Array = point.get("position", [0.0, 0.0])
	demo.player.position = Vector2(float(position_data[0]), float(position_data[1]))
	demo.player_collision_body.position = demo.player.position

func _capture(file_name: String) -> void:
	await process_frame
	await process_frame
	var viewport_texture: ViewportTexture = root.get_viewport().get_texture()
	var image: Image = viewport_texture.get_image() if viewport_texture else null
	if image == null or image.is_empty():
		_check(false, "rendered screenshot is available: " + file_name)
		return
	var path := "%s/%s" % [ProjectSettings.globalize_path(OUTPUT_DIR), file_name]
	_check(image.save_png(path) == OK, "screenshot saves: " + file_name)
	print("SENJIN_QA_IMAGE | %s | %dx%d" % [path, image.get_width(), image.get_height()])

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
		push_error("SENJIN_QA_CAPTURE: " + label)

func _finish() -> void:
	for path in [save_path, settings_path]:
		if path.is_empty():
			continue
		var absolute_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)
	quit(0 if failures.is_empty() else 1)
