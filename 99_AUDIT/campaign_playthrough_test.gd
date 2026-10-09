extends SceneTree

var failures: Array[String] = []
var test_save_path := ""
var test_settings_path := ""

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var nonce := str(Time.get_ticks_usec())
	test_save_path = "user://campaign_playthrough_%s.json" % nonce
	test_settings_path = "user://campaign_playthrough_%s.cfg" % nonce
	var packed_scene: PackedScene = load("res://03_GODOT/scenes/main.tscn")
	if packed_scene == null:
		_fail("main scene could not be loaded")
		_finish()
		return
	var demo = packed_scene.instantiate()
	demo.save_path_override = test_save_path
	demo.options_settings_path_override = test_settings_path
	root.add_child(demo)
	await process_frame
	demo.audio_manager.enabled = false
	_expect(demo.campaign_world_runtime != null, "campaign interaction runtime loaded")
	_expect(demo.campaign_world_runtime.validation_errors.is_empty(), "campaign interaction catalog validation")
	_expect(demo.menu_layer.visible and not demo.world_started, "campaign begins from the main menu")
	_validate_world_anchor_walkability(demo)
	var new_game_button: Button
	for child in demo.menu_layer.get_children():
		if child is Button and child.text == "NOVO JOGO":
			new_game_button = child
	_expect(new_game_button != null, "new-game button exists")
	if new_game_button:
		new_game_button.pressed.emit()
	await process_frame
	_expect(demo.campaign_mode, "public new-game button starts canonical campaign")
	_expect(str(demo.campaign_runtime.get_active_quest_id()) == "QST_ECHO_001", "campaign starts at QST_ECHO_001")
	_expect(demo.campaign_scene_id == "cabin" and demo.world_background.texture.resource_path.ends_with("echo_isles_cabin_interior_candidate_v001.png"), "campaign starts inside the candidate hut scene")
	_expect(demo._is_walkable_position(demo.player.position), "cabin player start is walkable")
	demo._confirm_dialogue()

	for point_id in ["q001_necklace", "q001_bowl", "q001_window", "q001_pouch"]:
		_use_point(demo, point_id)
	_choose_branch(demo, "q001_choice", "confident")
	_expect(demo.campaign_runtime.get_flag("FLG_ECHO_001_CONFIDENT"), "Q001 branch flag persists")
	_expect(int(demo.attributes.get("lust", 0)) == 44, "Q001 choice changes the matching attribute by the canonical delta")
	var saved_cabin_position: Vector2 = demo.player.position
	demo._return_to_menu()
	demo._continue_game()
	await process_frame
	_expect(demo.campaign_mode and demo.campaign_scene_id == "cabin", "continue loads saved campaign scene without replacing the save")
	_expect(demo.campaign_runtime.get_flag("FLG_ECHO_001_CONFIDENT"), "continue restores the irreversible Q001 branch")
	_expect(demo.player.position == saved_cabin_position, "continue restores the cabin position")
	demo._confirm_dialogue()
	_use_point(demo, "q001_exit")
	_expect(demo.dialogue_body.text.contains("confiança recém-escolhida"), "Q001 exit bark reflects the persistent choice")
	_expect(demo.campaign_scene_id == "echo_isles" and demo.campaign_runtime.get_flag("FLG_ECHO_001_CABIN_EXITED"), "cabin exit is gated by the saved choice")
	_use_point(demo, "q001_zekranu")
	_expect(str(demo.campaign_runtime.get_active_quest_id()) == "QST_ECHO_002", "Q001 completion unlocks Q002")

	for point_id in ["q002_earth", "q002_fire", "q002_water", "q002_air"]:
		_use_point(demo, point_id)
	_expect(demo.campaign_runtime.get_objective_progress("QST_ECHO_002", "air_refusal_observed") == 1, "air totem refusal is recorded")
	_choose_branch(demo, "q002_answer", "method")
	_expect(demo.cg_active and demo.cg_frames.size() == 4, "Q002 uses the four-frame totem CG")
	demo._return_to_menu()
	demo._continue_game()
	await process_frame
	_expect(demo.cg_active and demo.campaign_runtime.get_quest_state("QST_ECHO_002") == "complete", "loading during the totem CG resumes the pending campaign presentation")
	_advance_cg(demo)
	_expect(str(demo.campaign_runtime.get_active_quest_id()) == "QST_ECHO_003", "CG returns to the next quest")

	_use_point(demo, "q003_request")
	_choose_branch(demo, "q003_method", "surplus")
	_use_point(demo, "q003_surplus")
	_expect(not demo.encounter_active, "surplus solution does not start combat")
	_use_point(demo, "q003_return")
	_expect(demo.dialogue_body.text.contains("excedente"), "Q003 return dialogue evaluates the selected surplus route")
	_expect(str(demo.campaign_runtime.get_active_quest_id()) == "QST_ECHO_004", "Q003 fail-forward alternative completes and unlocks Q004")

	_use_point(demo, "q004_request")
	_use_point(demo, "q004_apprentice")
	_choose_branch(demo, "q004_apprentice", "charm")
	_expect(demo.campaign_runtime.get_flag("FLG_ECHO_004_CHARM_ATTEMPT"), "Q004 charm check records its attempted branch")
	_expect(demo.campaign_runtime.get_objective_progress("QST_ECHO_004", "live_frogs") == 2, "successful Q004 charm check only credits two partial captures")
	_expect(int(demo.campaign_runtime.inventory.get("live_frog", 0)) == 2, "Q004 partial charm reward is included in the carried inventory")
	for index in range(4):
		_use_point(demo, "q004_frogs")
	_expect(demo.campaign_runtime.get_objective_progress("QST_ECHO_004", "live_frogs") == 6, "Q004 counts six live captures")
	_use_point(demo, "q004_deliver")
	_expect(demo.campaign_runtime.get_flag("FLG_ECHO_004_ANTIDOTE_RECEIVED"), "Q004 delivery grants the antidote once")
	_expect(int(demo.campaign_runtime.counters.get("antidote_quality", -1)) == 2, "careful Q004 captures produce high antidote quality")
	_expect(demo.dialogue_body.text.contains("qualidade alta"), "Q004 delivery dialogue reports the resulting antidote quality")
	_expect(str(demo.campaign_runtime.get_active_quest_id()) == "QST_ECHO_005", "Q004 delivery unlocks Q005")

	_use_point(demo, "q005_shore")
	_use_point(demo, "q005_spirit")
	_use_point(demo, "q005_trace")
	_choose_branch(demo, "q005_choice", "help")
	_expect(demo.campaign_runtime.get_flag("FLG_WATER_SPIRIT_HELPED"), "Q005 branch affects boss preparation")
	_expect(demo.cg_active and demo.cg_frames.size() == 4, "Q005 uses the four-frame water-spirit CG")
	_advance_cg(demo)
	_expect(str(demo.campaign_runtime.get_active_quest_id()) == "QST_ECHO_006", "Q005 CG returns to Q006")
	var saved_water_scene: String = demo.campaign_scene_id
	var saved_water_position: Vector2 = demo.player.position
	demo._return_to_menu()
	demo._continue_game()
	await process_frame
	_expect(demo.campaign_mode and demo.campaign_scene_id == saved_water_scene, "continue restores the Q006 campaign scene")
	_expect(demo.campaign_runtime.get_active_quest_id() == "QST_ECHO_006", "continue restores the active boss quest")
	_expect(demo.campaign_runtime.get_flag("FLG_WATER_SPIRIT_HELPED") and demo.player.position == saved_water_position, "continue preserves the spirit branch and safe position")

	_use_point(demo, "q006_boss")
	_expect(demo.encounter_active and demo.combat_system != null, "Q006 starts a real boss encounter")
	if demo.combat_system == null:
		if demo.audio_manager:
			demo.audio_manager.stop_ambience()
		demo.queue_free()
		await process_frame
		_finish()
		return
	_expect(demo.combat_system.get_snapshot().get("actions", []).has("neutralize"), "Q005 spirit help enables a boss neutralization attempt")
	var neutralize_event := InputEventKey.new()
	neutralize_event.keycode = KEY_7
	demo._handle_encounter_input(neutralize_event)
	_expect(demo.combat_system.battle_result == "neutralized", "Makrura neutralization path resolves")
	var close_event := InputEventKey.new()
	close_event.keycode = KEY_ESCAPE
	demo._handle_encounter_input(close_event)
	_expect(demo.cg_active and demo.campaign_runtime.get_flag("FLG_MAKRURA_NEUTRALIZED"), "boss resolution triggers CG and persists neutralized outcome")
	demo._return_to_menu()
	demo._continue_game()
	await process_frame
	_expect(demo.cg_active and demo.campaign_runtime.get_flag("FLG_MAKRURA_NEUTRALIZED"), "loading during the boss CG resumes it without losing the combat outcome")
	_advance_cg(demo)
	_choose_branch(demo, "q006_fragment", "study")
	_expect(demo.campaign_runtime.get_flag("FLG_FRAGMENT_STUDIED"), "fragment decision is persistent")
	_expect(str(demo.campaign_runtime.get_active_quest_id()) == "QST_ECHO_007", "Q006 completion unlocks Q007")
	demo._return_to_menu()
	demo._continue_game()
	await process_frame
	_expect(demo.campaign_runtime.get_active_quest_id() == "QST_ECHO_007", "continue resumes after boss victory and fragment decision")
	_expect(demo.campaign_runtime.get_flag("FLG_FRAGMENT_STUDIED") and demo.campaign_runtime.get_flag("FLG_MAKRURA_NEUTRALIZED"), "boss outcome and fragment choice survive save/load")

	_use_point(demo, "q007_clues")
	_use_point(demo, "q007_children")
	_choose_branch(demo, "q007_children", "protect")
	_use_point(demo, "q007_restore")
	_expect(demo.dialogue_body.text.contains("sem expor as crianças"), "Q007 restoration dialogue reflects the chosen resolution")
	_expect(str(demo.campaign_runtime.get_active_quest_id()) == "QST_ECHO_008", "Q007 restoration unlocks Q008")

	_use_point(demo, "q008_pack")
	_use_point(demo, "q008_makjala")
	_expect(demo.dialogue_body.text.contains("protegido as crianças"), "Q008 Mak’Jala farewell reacts to the Q007 resolution")
	_use_point(demo, "q008_rakjin")
	_choose_branch(demo, "q008_choice", "ambition")
	_use_point(demo, "q008_boat")
	_expect(demo.campaign_runtime.chapter_id == "SENJIN_VILLAGE", "Q008 boat advances into the Sen’jin chapter")
	_expect(demo.campaign_runtime.get_quest_state("QST_ECHO_008") == "turned_in", "Q008 is delivered exactly once")
	_expect(demo.campaign_scene_id == "senjin_village", "Q008 loads the Sen’jin map after the departure acknowledgement")
	_expect(str(demo.world_background.texture.resource_path).ends_with("senjin_village_background_concept_v001.png"), "Sen’jin background replaces Echo Isles at the transition")
	_expect(demo.campaign_runtime.get_quest_state("QST_SEN_009") == "in_progress", "arrival unlocks and starts QST_SEN_009")
	_expect(demo.campaign_dialogue_data.get("senjin", {}).get("arrival", {}).get("title", "") == demo.dialogue_title.text, "Sen’jin arrival dialogue is displayed in PT-BR")
	_expect(demo._is_walkable_position(demo.player.position), "arrival spawn is inside Sen’jin walkability")
	demo._confirm_dialogue()
	_use_point(demo, "q009_supply_report")
	_use_point(demo, "q009_depot")
	_use_point(demo, "q009_trail")
	_use_point(demo, "q009_rukka")
	_expect(demo.campaign_runtime.get_objective_progress("QST_SEN_009", "discover_rukka_motive") == 1, "Ruk’ka’s family motivation is recorded before the council")
	_expect(not demo.encounter_active, "the investigation and resolution scenes do not start combat")
	var senjin_save_position: Vector2 = demo.player.position
	demo._return_to_menu()
	demo._continue_game()
	await process_frame
	_expect(demo.campaign_runtime.get_active_quest_id() == "QST_SEN_009" and demo.campaign_scene_id == "senjin_village", "Sen’jin investigation resumes from save/load")
	_expect(demo.player.position == senjin_save_position and demo.campaign_runtime.get_objective_progress("QST_SEN_009", "discover_rukka_motive") == 1, "Sen’jin position and investigation state persist")
	_expect(demo._is_walkable_position(demo.player.position) and str(demo.world_background.texture.resource_path).ends_with("senjin_village_background_concept_v001.png"), "load restores Sen’jin map and walkable player placement")
	_choose_branch(demo, "q009_council", "pay_shortage")
	_expect(demo.campaign_runtime.get_quest_state("QST_SEN_009") == "turned_in", "QST_SEN_009 completes and turns in after the council choice")
	_expect(demo.campaign_runtime.get_flag("FLG_RUKKA_PROTECTED") and int(demo.campaign_runtime.inventory.get("gold", 0)) == 80, "protection route preserves its flag and exact 20 percent gold cost")
	_expect(int(demo.campaign_runtime.trust.get("rukka", 0)) == 20 and int(demo.campaign_runtime.reputation.get("local", 0)) == 4, "protection route applies its relationship and reputation outcomes")
	_expect(demo.campaign_runtime.chapter_id == "SENJIN_COMPLETE" and demo.campaign_scene_id == "senjin_village", "QST_SEN_009 closes the slice in Sen’jin without loading another region")
	_expect(demo.encounter_manager.is_spawn_position("senjin_village_day", demo.player.position + Vector2(0.0, 40.0)), "Sen’jin random-event table recognizes the village plaza")
	_expect(not demo.encounter_manager.is_spawn_position("senjin_village_day", Vector2(800.0, 900.0)), "Sen’jin random-event table rejects the ocean")
	demo.encounter_manager._steps_since_event = 0
	demo.encounter_manager._cooldown_left = 0.0
	_expect(not demo.encounter_manager.try_roll("senjin_village_day", Vector2(950.0, 300.0)), "Sen’jin events respect the minimum-step frequency gate")
	demo.encounter_manager._steps_since_event = demo.encounter_manager.minimum_steps_between_events
	demo.encounter_manager._cooldown_left = 1.0
	_expect(not demo.encounter_manager.try_roll("senjin_village_day", Vector2(950.0, 300.0)), "Sen’jin events respect the cooldown gate")
	demo.encounter_manager._cooldown_left = 0.0
	_expect(not demo.encounter_manager.try_roll("senjin_village_day", Vector2(950.0, 300.0), true), "blocked Sen’jin state suppresses a regional encounter roll")
	demo._handle_noncombat_encounter({"type":"supply_problem","actors":["supply_crate"],"zone_id":"senjin_village"})
	_expect(int(demo.campaign_runtime.inventory.get("ration", 0)) == 1 and demo.campaign_runtime.get_flag("FLG_SEN_RANDOM_SUPPLY_RESOLVED"), "regional supply event grants one persistent ration")
	_expect(not demo.encounter_active, "supply event does not start combat")
	demo._handle_noncombat_encounter({"type":"supply_problem","actors":["supply_crate"],"zone_id":"senjin_village"})
	_expect(int(demo.campaign_runtime.inventory.get("ration", 0)) == 1, "regional supply event does not duplicate its one-time reward")
	demo._handle_noncombat_encounter({"type":"alchemy_request","actors":["tazrima"],"zone_id":"senjin_village"})
	_expect(int(demo.campaign_runtime.inventory.get("field_reagent", 0)) == 1 and int(demo.campaign_runtime.affinity.get("tazrima", 0)) == 1, "regional alchemy event records reagent and Taz’Rima affinity")
	_expect(not demo.encounter_active, "alchemy event does not start combat")
	demo._handle_noncombat_encounter({"type":"alchemy_request","actors":["tazrima"],"zone_id":"senjin_village"})
	_expect(int(demo.campaign_runtime.inventory.get("field_reagent", 0)) == 1, "regional alchemy event cannot duplicate its one-time reagent")
	demo._start_npc_walkby(["tazrima", "rukka"])
	_expect(is_instance_valid(demo.random_event_npc), "Sen’jin walk-by event uses an integrated named NPC sprite")
	_expect(not demo.encounter_active, "named NPC walk-by does not start combat")
	if is_instance_valid(demo.random_event_npc):
		var walkby_start: Vector2 = demo.random_event_npc.position
		demo._process_random_event_npc(0.25)
		_expect(demo.random_event_npc.position != walkby_start, "Sen’jin walk-by follows a short traversable route")
		demo._process_random_event_npc(3.0)
		await process_frame
		_expect(not is_instance_valid(demo.random_event_npc), "Sen’jin walk-by exits instead of remaining as a permanent NPC")
	var completed_senjin_position: Vector2 = demo.player.position
	demo._return_to_menu()
	demo._continue_game()
	await process_frame
	_expect(demo.campaign_runtime.get_quest_state("QST_SEN_009") == "turned_in", "completed Sen’jin quest remains turned in after a fresh load")
	_expect(demo.campaign_runtime.chapter_id == "SENJIN_COMPLETE" and demo.campaign_scene_id == "senjin_village", "completed save resumes at the Sen’jin slice ending")
	_expect(demo.player.position == completed_senjin_position, "completed Sen’jin save restores the safe player position")
	_expect(demo.campaign_runtime.get_flag("FLG_RUKKA_PROTECTED") and int(demo.campaign_runtime.inventory.get("gold", 0)) == 80, "completed Sen’jin choice and gold balance persist after load")

	if failures.is_empty():
		print("CAMPAIGN_PLAYTHROUGH_TEST: PASS (Echo Isles QST_ECHO_001–008 + Sen’jin QST_SEN_009)")
	else:
		print("CAMPAIGN_PLAYTHROUGH_TEST: FAIL -> %s" % ", ".join(failures))
	if demo.audio_manager:
		demo.audio_manager.stop_ambience()
	demo.queue_free()
	await process_frame
	await create_timer(0.3).timeout
	_finish()

func _validate_world_anchor_walkability(demo) -> void:
	var previous_scene: String = demo.campaign_scene_id
	var previous_position: Vector2 = demo.player.position
	for point_value in demo.campaign_interaction_data.get("points", []):
		var point: Dictionary = point_value
		var position_data: Array = point.get("position", [0.0, 0.0])
		var position := Vector2(float(position_data[0]), float(position_data[1]))
		demo.campaign_mode = true
		demo._set_campaign_scene(str(point.get("scene", "echo_isles")))
		if not demo._is_walkable_position(position):
			_fail("interaction anchor is outside walkability: " + str(point.get("id", "")))
	demo._set_campaign_scene(previous_scene, previous_position)

func _use_point(demo, point_id: String) -> void:
	var available: Array[Dictionary] = demo.campaign_world_runtime.get_points_for_scene(demo.campaign_scene_id, demo.campaign_runtime)
	var selected: Dictionary = {}
	for point in available:
		if str(point.get("id", "")) == point_id:
			selected = point
			break
	if selected.is_empty():
		_fail("campaign point is not available: " + point_id)
		return
	var position_data: Array = selected.get("position", [0.0, 0.0])
	demo.player.position = Vector2(float(position_data[0]), float(position_data[1]))
	demo.player_collision_body.position = demo.player.position
	demo._try_campaign_interact()
	if selected.get("action", "") not in ["boar_hunt", "makrura_boss", "trap", "capture_frog"] and demo.dialogue_action not in ["campaign_ack", "campaign_finish_ack", "campaign_branch_choice", "campaign_branch_ack"]:
		_fail("physical interaction did not activate expected point: " + point_id)
	if demo.dialogue_action in ["campaign_ack", "campaign_finish_ack"]:
		demo._confirm_dialogue()

func _choose_branch(demo, point_id: String, branch_id: String) -> void:
	var available: Array[Dictionary] = demo.campaign_world_runtime.get_points_for_scene(demo.campaign_scene_id, demo.campaign_runtime)
	var selected_point: Dictionary = {}
	for point in available:
		if str(point.get("id", "")) == point_id:
			selected_point = point
			break
	if selected_point.is_empty():
		_fail("branch point is not available: " + point_id)
		return
	var position_data: Array = selected_point.get("position", [0.0, 0.0])
	demo.player.position = Vector2(float(position_data[0]), float(position_data[1]))
	demo.player_collision_body.position = demo.player.position
	demo._try_campaign_interact()
	if not demo.campaign_branch_input_active:
		_fail("branch UI did not open: " + point_id)
		return
	var branches: Array[Dictionary] = demo.campaign_runtime.get_available_branches(str(selected_point.get("quest_id", "")), str(selected_point.get("group_id", "")))
	var choice_index := -1
	for index in branches.size():
		if str(branches[index].get("id", "")) == branch_id:
			choice_index = index + 1
			break
	if choice_index < 1:
		_fail("requested branch is unavailable: " + point_id + "/" + branch_id)
		return
	demo._apply_campaign_branch_choice(choice_index)
	demo._confirm_dialogue()

func _advance_cg(demo) -> void:
	for _frame in 4:
		if demo.cg_active:
			demo._advance_cg()

func _expect(condition: bool, label: String) -> void:
	if not condition:
		_fail(label)

func _fail(label: String) -> void:
	failures.append(label)
	print("CAMPAIGN_TEST_CHECK_FAIL: " + label)

func _finish() -> void:
	for path in [test_save_path, test_settings_path]:
		if path.is_empty():
			continue
		var absolute_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)
	quit(0 if failures.is_empty() else 1)
