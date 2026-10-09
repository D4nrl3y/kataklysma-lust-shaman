extends SceneTree

var failures: Array[String] = []
var save_paths: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene: PackedScene = load("res://03_GODOT/scenes/main.tscn")
	if packed_scene == null:
		_fail("main scene loads")
		_finish()
		return
	var demo = packed_scene.instantiate()
	demo.save_path_override = _new_save_path("trap")
	demo.options_settings_path_override = _new_save_path("settings")
	root.add_child(demo)
	await process_frame
	demo.audio_manager.enabled = false
	demo.campaign_mode = true
	demo.world_started = true
	_expect(_restore_q3_checkpoint(demo), "Q003 route checkpoint restores in the playable scene")
	demo._refresh_campaign_world()

	_use_point(demo, "q003_request")
	_choose_branch(demo, "q003_method", "trap")
	_expect(demo.campaign_runtime.get_flag("FLG_ECHO_003_TRAPPED"), "trap route choice persists its flag")
	_expect(not demo.encounter_active, "noncombat trap route does not open combat")
	for _step in 3:
		_use_point(demo, "q003_trap")
	_expect(demo.campaign_runtime.get_objective_progress("QST_ECHO_003", "trap_meat") == 1, "three-step preparation records the trap solution")
	_expect(int(demo.campaign_runtime.inventory.get("boar_meat", 0)) == 4, "trap yields the canonical four portions")
	_use_point(demo, "q003_return")
	_expect(demo.campaign_runtime.get_quest_state("QST_ECHO_003") == "turned_in", "trap route completes and turns in Q003")
	_expect(demo.campaign_runtime.get_active_quest_id() == "QST_ECHO_004", "trap route unlocks Q004")

	_expect(_restore_q3_checkpoint(demo), "Q003 hunt route checkpoint restores")
	demo._refresh_campaign_world()
	_use_point(demo, "q003_request")
	_choose_branch(demo, "q003_method", "hunt")
	for _portion in 4:
		_use_point(demo, "q003_hunt")
		_expect(demo.encounter_active and demo.combat_system != null, "hunt starts a real turn-based wild-boar encounter")
		if demo.combat_system == null:
			break
		var snapshot: Dictionary = demo.combat_system.get_snapshot()
		for _turn in 30:
			if str(snapshot.get("phase", "")) != "player_turn":
				break
			snapshot = demo.combat_system.perform_action("strike")
		if str(snapshot.get("result", "")) != "victory":
			_fail("wild-boar encounter can be defeated with the configured combat rules")
			break
		demo.encounter_choice_made = true
		var close_event := InputEventKey.new()
		close_event.keycode = KEY_ESCAPE
		demo._handle_encounter_input(close_event)
		_expect(not demo.encounter_active, "victory returns from combat to campaign exploration")
	_expect(demo.campaign_runtime.get_objective_progress("QST_ECHO_003", "boar_meat") == 4, "four actual victories fill the hunt objective")
	_choose_branch(demo, "q003_rite", "rite")
	_expect(demo.campaign_runtime.get_flag("FLG_ECHO_003_RITE"), "optional post-hunt rite resolves in the playable interaction flow")
	_expect(int(demo.campaign_runtime.trust.get("elemental", 0)) == 3, "post-hunt rite applies its elemental trust consequence")
	_use_point(demo, "q003_return")
	_expect(str(demo.campaign_runtime.quest_records["QST_ECHO_003"].get("completion_path", "")) == "hunt", "hunt completion records the selected canonical path")
	_expect(demo.cg_active and demo.cg_frames.size() == 4, "hunt completion triggers its four-frame CG")
	for _frame in 4:
		if demo.cg_active:
			demo._advance_cg()
	_expect(demo.campaign_runtime.get_active_quest_id() == "QST_ECHO_004", "hunt route unlocks Q004")

	if demo.audio_manager:
		demo.audio_manager.stop_ambience()
	demo.queue_free()
	await process_frame
	_finish()


func _restore_q3_checkpoint(demo) -> bool:
	if not demo.campaign_runtime.configure(demo.campaign_definition, demo.attributes):
		return false
	var order: Array = demo.campaign_definition.get("quest_order", [])
	for quest_id_value in order:
		var quest_id := str(quest_id_value)
		if quest_id == "QST_ECHO_003":
			demo.campaign_runtime.quest_records[quest_id]["state"] = "in_progress"
			break
		demo.campaign_runtime.quest_records[quest_id]["state"] = "turned_in"
	demo._campaign_sync_mirrors()
	demo.campaign_scene_id = "echo_isles"
	demo.encounter_active = false
	demo.encounter_choice_made = false
	demo.campaign_pending_encounter.clear()
	return true


func _use_point(demo, point_id: String) -> void:
	var point := _find_point(demo, point_id)
	if point.is_empty():
		_fail("campaign point is available: " + point_id)
		return
	var position_data: Array = point.get("position", [0.0, 0.0])
	demo.player.position = Vector2(float(position_data[0]), float(position_data[1]))
	demo.player_collision_body.position = demo.player.position
	demo._try_campaign_interact()
	if demo.dialogue_action in ["campaign_ack", "campaign_finish_ack"]:
		demo._confirm_dialogue()


func _choose_branch(demo, point_id: String, branch_id: String) -> void:
	var point := _find_point(demo, point_id)
	if point.is_empty():
		_fail("branch point is available: " + point_id)
		return
	var position_data: Array = point.get("position", [0.0, 0.0])
	demo.player.position = Vector2(float(position_data[0]), float(position_data[1]))
	demo.player_collision_body.position = demo.player.position
	demo._try_campaign_interact()
	if not demo.campaign_branch_input_active:
		_fail("branch interaction opens the choice UI: " + point_id)
		return
	var branches: Array[Dictionary] = demo.campaign_runtime.get_available_branches(str(point.get("quest_id", "")), str(point.get("group_id", "")))
	for index in branches.size():
		if str(branches[index].get("id", "")) == branch_id:
			demo._apply_campaign_branch_choice(index + 1)
			demo._confirm_dialogue()
			return
	_fail("requested route exists: " + point_id + "/" + branch_id)


func _find_point(demo, point_id: String) -> Dictionary:
	for point in demo.campaign_world_runtime.get_points_for_scene(demo.campaign_scene_id, demo.campaign_runtime):
		if str(point.get("id", "")) == point_id:
			return point
	return {}


func _new_save_path(label: String) -> String:
	var path := "user://campaign_alternates_%s_%s.json" % [label, Time.get_ticks_usec()]
	save_paths.append(path)
	return path


func _expect(condition: bool, label: String) -> void:
	if not condition:
		_fail(label)


func _fail(label: String) -> void:
	failures.append(label)
	push_error("CAMPAIGN_ALTERNATE_ROUTES_TEST: FAIL | %s" % label)


func _finish() -> void:
	for path in save_paths:
		var absolute_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)
	if failures.is_empty():
		print("CAMPAIGN_ALTERNATE_ROUTES_TEST: PASS (Q003 trap and hunt routes)")
		quit(0)
	else:
		push_error("CAMPAIGN_ALTERNATE_ROUTES_TEST: %d checks failed" % failures.size())
		quit(1)
