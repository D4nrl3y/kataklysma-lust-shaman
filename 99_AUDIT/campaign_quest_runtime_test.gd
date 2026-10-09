extends SceneTree

const RuntimeScript = preload("res://03_GODOT/scripts/campaign_quest_runtime.gd")
const CAMPAIGN_PATH := "res://03_GODOT/data/campaign/echo_isles.json"

var failures: Array[String] = []
var checks := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var file := FileAccess.open(CAMPAIGN_PATH, FileAccess.READ)
	_check(file != null, "canonical Echo Isles campaign data opens")
	if file == null:
		_finish()
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	_check(typeof(parsed) == TYPE_DICTIONARY, "campaign data is valid JSON object")
	if typeof(parsed) != TYPE_DICTIONARY:
		_finish()
		return
	var campaign: Dictionary = parsed
	var runtime: Variant = RuntimeScript.new()
	_check(runtime.validate_definition(campaign).is_empty(), "all quest, objective, branch and prerequisite references validate")
	var invalid_campaign: Dictionary = campaign.duplicate(true)
	invalid_campaign["quests"]["QST_ECHO_001"]["completion"]["all"][0]["objective_id"] = "missing_objective"
	_check(not runtime.validate_definition(invalid_campaign).is_empty(), "broken objective references are rejected during content validation")
	_check(runtime.configure(campaign, {"agility": 61, "stamina": 54, "intellect": 82, "spirit": 73, "corruption": 21, "lust": 43}), "campaign runtime configures")
	_check(campaign.get("quest_order", []).size() == 9, "campaign includes the eight Echo Isles quests and QST_SEN_009")
	_check(runtime.get_active_quest_id() == "QST_ECHO_001", "the first unlocked canonical quest is discoverable before acceptance")
	_check(not runtime.is_quest_unlocked("QST_ECHO_002"), "later quest remains locked before its prerequisite is turned in")
	_test_awakening_and_spine(runtime)
	_test_branch_gates(campaign)
	_test_senjin_quest(campaign)
	_test_save_round_trip(campaign)
	_finish()


func _test_awakening_and_spine(runtime: Variant) -> void:
	_check(runtime.accept_quest("QST_ECHO_001"), "first canonical quest can start")
	_check(runtime.get_active_quest_id() == "QST_ECHO_001", "active quest query returns the in-progress quest")
	_check(not runtime.complete_quest("QST_ECHO_001"), "quest cannot complete before choice and objective")
	var branch_result: Dictionary = runtime.resolve_branch("QST_ECHO_001", "awakening_choice", "confident")
	_check(bool(branch_result.get("ok", false)), "Awakening branch resolves")
	_check(runtime.get_flag("FLG_ECHO_001_CONFIDENT"), "Awakening flag is committed before scene exit")
	_check(int(runtime.attributes["lust"]) == 44, "Awakening attribute delta applies once")
	_check(not runtime.resolve_branch("QST_ECHO_001", "awakening_choice", "confident").get("ok", false), "same branch group cannot apply twice")
	_check(int(runtime.attributes["lust"]) == 44, "duplicate branch attempt does not duplicate its effect")
	_check(runtime.increment_objective("QST_ECHO_001", "meet_zekranu"), "objective progress advances")
	_check(runtime.can_complete_quest("QST_ECHO_001"), "Awakening acceptance requirements are met")
	_check(runtime.complete_quest("QST_ECHO_001") and runtime.turn_in_quest("QST_ECHO_001"), "Awakening completes and turns in")
	_check(runtime.is_quest_unlocked("QST_ECHO_002"), "turn-in unlocks the next canonical quest")
	_check(not runtime.turn_in_quest("QST_ECHO_001"), "turn-in is not repeatable")
	_check(runtime.accept_quest("QST_ECHO_002"), "Voice of the Elements starts after Awakening")
	_check(runtime.get_available_branches("QST_ECHO_002", "elemental_response").is_empty(), "response remains unavailable before the ritual")
	_check(runtime.increment_objective("QST_ECHO_002", "earth_totem"), "earth totem interaction advances")
	_check(runtime.increment_objective("QST_ECHO_002", "fire_totem"), "fire totem interaction advances")
	_check(runtime.increment_objective("QST_ECHO_002", "water_totem"), "water totem interaction advances")
	_check(runtime.increment_objective("QST_ECHO_002", "air_totem"), "air totem refusal interaction advances")
	_check(runtime.increment_objective("QST_ECHO_002", "air_refusal_observed"), "deliberate air refusal is recorded")
	_check(runtime.increment_objective("QST_ECHO_002", "answer_zekranu"), "mentor response objective advances")
	var patience: Dictionary = runtime.resolve_branch("QST_ECHO_002", "elemental_response", "patience")
	_check(bool(patience.get("ok", false)), "elemental response branch resolves")
	_check(int(runtime.trust.get("elemental", 0)) == 5 and int(runtime.trust.get("zekranu", 0)) == 8, "elemental trust and Zek’Ranu trust apply independently")
	_check(runtime.can_complete_quest("QST_ECHO_002"), "ritual and response satisfy QST_ECHO_002 gate")
	_check(runtime.complete_quest("QST_ECHO_002") and runtime.turn_in_quest("QST_ECHO_002"), "QST_ECHO_002 completion advances the spine")
	_check(runtime.accept_quest("QST_ECHO_003"), "Fresh Meat starts in canonical order")
	_check(runtime.get_available_branches("QST_ECHO_003", "after_hunt").is_empty(), "post-hunt ritual is unavailable before choosing the hunt route")
	_check(not runtime.resolve_branch("QST_ECHO_003", "food_method", "trap").get("ok", false), "food method cannot be chosen before Mok’Jala gives the task")
	_check(runtime.increment_objective("QST_ECHO_003", "receive_mokjala_request"), "Mok’Jala’s request is registered")
	_check(runtime.resolve_branch("QST_ECHO_003", "food_method", "trap").get("ok", false), "noncombat trap route can be selected")
	_check(runtime.get_available_branches("QST_ECHO_003", "after_hunt").is_empty(), "post-hunt ritual stays unavailable on the trap route")
	_check(runtime.increment_objective("QST_ECHO_003", "trap_meat"), "trap route objective advances without requiring combat")
	_check(runtime.increment_objective("QST_ECHO_003", "return_to_mokjala"), "alternate route returns to Mok’Jala")
	_check(runtime.can_complete_quest("QST_ECHO_003"), "selected alternate route satisfies Fresh Meat completion")


func _test_branch_gates(campaign: Dictionary) -> void:
	var low_lust: Variant = RuntimeScript.new()
	_check(low_lust.configure(campaign, {"lust": 14}), "low-Luxúria fixture configures")
	var low_save: Dictionary = _quest_fixture_state(low_lust, "QST_ECHO_004")
	_check(low_lust.restore_state(low_save), "QST_ECHO_004 test checkpoint restores")
	low_lust.increment_objective("QST_ECHO_004", "speak_to_tazrima")
	low_lust.increment_objective("QST_ECHO_004", "meet_apprentice")
	var failed_check: Dictionary = low_lust.resolve_branch("QST_ECHO_004", "frog_method", "charm")
	_check(bool(failed_check.get("ok", false)) and not bool(failed_check.get("check_passed", true)), "failed social check remains a valid fail-forward choice")
	_check(str(failed_check.get("result", "")) == "fail_forward", "failed charm check reports fail-forward, not quest failure")
	_check(low_lust.get_flag("FLG_ECHO_004_CHARM_ATTEMPT"), "charm attempt persists even when the check fails")
	_check(low_lust.get_objective_progress("QST_ECHO_004", "live_frogs") == 0, "failed charm grants no partial frog credit")
	_check(not low_lust.can_complete_quest("QST_ECHO_004"), "partial charm outcome does not waive the six-live-frog objective")
	var high_lust: Variant = RuntimeScript.new()
	_check(high_lust.configure(campaign, {"lust": 15}), "threshold Luxúria fixture configures")
	_check(high_lust.restore_state(_quest_fixture_state(high_lust, "QST_ECHO_004")), "threshold quest checkpoint restores")
	high_lust.increment_objective("QST_ECHO_004", "speak_to_tazrima")
	high_lust.increment_objective("QST_ECHO_004", "meet_apprentice")
	var passed_check: Dictionary = high_lust.resolve_branch("QST_ECHO_004", "frog_method", "charm")
	_check(bool(passed_check.get("check_passed", false)) and str(passed_check.get("result", "")) == "partial_success", "successful charm remains explicitly partial")
	_check(high_lust.get_objective_progress("QST_ECHO_004", "live_frogs") == 2, "successful charm grants only two partial frog captures")
	_check(int(high_lust.inventory.get("live_frog", 0)) == 2, "successful charm frog inventory matches objective credit")
	var hunt_route: Variant = RuntimeScript.new()
	_check(hunt_route.configure(campaign), "hunt route fixture configures")
	_check(hunt_route.restore_state(_quest_fixture_state(hunt_route, "QST_ECHO_003")), "hunt route checkpoint restores")
	hunt_route.increment_objective("QST_ECHO_003", "receive_mokjala_request")
	_check(hunt_route.resolve_branch("QST_ECHO_003", "food_method", "hunt").get("ok", false), "hunt route can be selected")
	_check(hunt_route.get_available_branches("QST_ECHO_003", "after_hunt").is_empty(), "ritual waits until the hunt is complete")
	hunt_route.increment_objective("QST_ECHO_003", "boar_meat", 4)
	_check(_contains_branch(hunt_route.get_available_branches("QST_ECHO_003", "after_hunt"), "rite"), "post-hunt ritual becomes available after all four portions")
	_check(hunt_route.resolve_branch("QST_ECHO_003", "after_hunt", "rite").get("ok", false), "optional ritual branch resolves after hunting")
	hunt_route.increment_objective("QST_ECHO_003", "return_to_mokjala")
	_check(hunt_route.can_complete_quest("QST_ECHO_003"), "hunt plus return satisfies Fresh Meat acceptance")
	var boss: Variant = RuntimeScript.new()
	_check(boss.configure(campaign), "Makrura fixture configures")
	_check(boss.restore_state(_quest_fixture_state(boss, "QST_ECHO_006")), "Makrura checkpoint restores")
	boss.increment_objective("QST_ECHO_006", "boss_phase_one")
	boss.increment_objective("QST_ECHO_006", "boss_phase_two")
	boss.increment_objective("QST_ECHO_006", "boss_phase_three")
	_check(boss.increment_objective("QST_ECHO_006", "makrura_defeated"), "boss objective resolves")
	_check(int(boss.inventory.get("makrura_fragment", 0)) == 1, "boss resolution places the fragment into campaign inventory")
	_check(boss.increment_objective("QST_ECHO_006", "makrura_defeated"), "repeated objective event is safely bounded")
	_check(int(boss.inventory.get("makrura_fragment", 0)) == 1, "boss reward is not duplicated")
	_check(boss.resolve_branch("QST_ECHO_006", "fragment_fate", "destroy").get("ok", false), "post-boss fragment decision resolves")
	_check(int(boss.inventory.get("makrura_fragment", 0)) == 0 and int(boss.inventory.get("elemental_blessing", 0)) == 1, "destroying fragment consumes it and grants the blessing")
	var departure: Variant = RuntimeScript.new()
	_check(departure.configure(campaign), "departure fixture configures")
	_check(departure.restore_state(_quest_fixture_state(departure, "QST_ECHO_008")), "departure checkpoint restores")
	departure.increment_objective("QST_ECHO_008", "pack_belongings")
	departure.increment_objective("QST_ECHO_008", "farewell_makjala")
	departure.increment_objective("QST_ECHO_008", "farewell_rakjin")
	_check(not _contains_branch(departure.get_available_branches("QST_ECHO_008", "departure_choice"), "secret"), "secret departure is hidden when the fragment was not hidden")
	departure.story_flags["FLG_FRAGMENT_HIDDEN"] = true
	_check(_contains_branch(departure.get_available_branches("QST_ECHO_008", "departure_choice"), "secret"), "secret departure becomes available only with the hidden-fragment flag")
	_check(departure.resolve_branch("QST_ECHO_008", "departure_choice", "secret").get("ok", false), "conditional secret departure branch resolves")
	_check(int(departure.counters.get("world_tension", 0)) == 3, "departure secret consequence persists in world state")


func _test_save_round_trip(campaign: Dictionary) -> void:
	var source: Variant = RuntimeScript.new()
	_check(source.configure(campaign, {"spirit": 73, "lust": 43}), "save source runtime configures")
	_check(source.accept_quest("QST_ECHO_001"), "save source starts QST_ECHO_001")
	_check(source.resolve_branch("QST_ECHO_001", "awakening_choice", "studied").get("ok", false), "save source records a narrative branch")
	_check(source.increment_objective("QST_ECHO_001", "meet_zekranu"), "save source records objective state")
	source.set_checkpoint("ECHO_AWAKENING", "echo_isles", Vector2(342.5, 188.0))
	source.set_tutorial_seen("movement_seen")
	source.event_seed = 71204
	source.event_sequence = 3
	var saved: Dictionary = source.export_state()
	var restored: Variant = RuntimeScript.new()
	_check(restored.configure(campaign), "load target runtime configures")
	_check(restored.restore_state(saved), "campaign save round-trips")
	_check(restored.get_quest_state("QST_ECHO_001") == "in_progress", "quest state resumes after load")
	_check(restored.get_active_quest_id() == "QST_ECHO_001", "active quest resumes after load")
	_check(restored.get_objective_progress("QST_ECHO_001", "meet_zekranu") == 1, "objective progress resumes after load")
	_check(restored.get_flag("FLG_ECHO_001_STUDIED") and restored.journal_entries.has("lore_four_elements_first_mark"), "branch flag and journal entry resume")
	_check(int(restored.attributes.get("intellect", 0)) == 1, "branch attribute delta is not lost on load")
	_check(not restored.resolve_branch("QST_ECHO_001", "awakening_choice", "studied").get("ok", false) and int(restored.attributes.get("intellect", 0)) == 1, "loaded branch cannot replay and duplicate its consequence")
	_check(restored.safe_position == Vector2(342.5, 188.0) and restored.chapter_id == "ECHO_AWAKENING", "safe position and chapter resume after load")
	_check(bool(restored.tutorial_flags.get("movement_seen", false)) and restored.event_seed == 71204 and restored.event_sequence == 3, "tutorial and deterministic event state resume after load")
	var wrong_campaign: Dictionary = saved.duplicate(true)
	wrong_campaign["campaign_id"] = "another_campaign"
	_check(not restored.restore_state(wrong_campaign), "save from a different campaign is rejected")
	var legacy_state: Dictionary = saved.duplicate(true)
	legacy_state["save_schema_version"] = 1
	legacy_state["quests"].erase("QST_SEN_009")
	legacy_state["inventory"].erase("gold")
	_check(restored.restore_state(legacy_state), "Phase 2 save migrates without a QST_SEN_009 record")
	_check(restored.get_quest_state("QST_SEN_009") == "available", "legacy save initializes only the new Sen’jin quest")
	_check(int(restored.inventory.get("gold", 0)) == 100, "legacy save receives the default campaign gold balance")


func _test_senjin_quest(campaign: Dictionary) -> void:
	var protected: Variant = RuntimeScript.new()
	_check(protected.configure(campaign, {"spirit": 73, "lust": 43}), "Sen’jin branch fixture configures")
	_check(protected.restore_state(_quest_fixture_state(protected, "QST_SEN_009")), "Sen’jin quest fixture restores")
	for objective_id in ["hear_supply_report", "inspect_depot", "follow_rukka_trail", "discover_rukka_motive"]:
		protected.increment_objective("QST_SEN_009", objective_id)
	_check(protected.get_available_branches("QST_SEN_009", "council_resolution").size() == 4, "council choice appears after all investigation objectives")
	var payment: Dictionary = protected.resolve_branch("QST_SEN_009", "council_resolution", "pay_shortage")
	_check(bool(payment.get("ok", false)), "protection branch resolves")
	_check(int(protected.inventory.get("gold", 0)) == 80, "protection branch deducts twenty percent of starting gold")
	_check(int(protected.attributes.get("spirit", 0)) == 75 and int(protected.trust.get("rukka", 0)) == 20, "protection branch applies Spirit and Ruk’ka trust")
	_check(int(protected.reputation.get("local", 0)) == 4 and protected.get_flag("FLG_RUKKA_PROTECTED"), "protection branch stores local reputation and its flag")
	_check(protected.can_complete_quest("QST_SEN_009"), "protection outcome fail-forwards to secured supplies")

	var paid_job: Variant = RuntimeScript.new()
	_check(paid_job.configure(campaign, {"intellect": 10}), "paid messenger branch fixture configures")
	_check(paid_job.restore_state(_quest_fixture_state(paid_job, "QST_SEN_009")), "paid messenger branch fixture restores")
	for objective_id in ["hear_supply_report", "inspect_depot", "follow_rukka_trail", "discover_rukka_motive"]:
		paid_job.increment_objective("QST_SEN_009", objective_id)
	var job_result: Dictionary = paid_job.resolve_branch("QST_SEN_009", "council_resolution", "paid_job")
	_check(bool(job_result.get("ok", false)) and paid_job.get_flag("FLG_RUKKA_WORK"), "paid messenger solution resolves with its persistent flag")
	_check(int(paid_job.attributes.get("intellect", 0)) == 12 and paid_job.unlock_tags.has("rukka_messenger_npc"), "paid messenger solution applies intellect and unlock outcomes")
	_check(paid_job.can_complete_quest("QST_SEN_009"), "paid messenger solution satisfies the required council resolution")

	var informant: Variant = RuntimeScript.new()
	_check(informant.configure(campaign, {"corruption": 0}), "informant branch fixture configures")
	_check(informant.restore_state(_quest_fixture_state(informant, "QST_SEN_009")), "informant branch fixture restores")
	for objective_id in ["hear_supply_report", "inspect_depot", "follow_rukka_trail", "discover_rukka_motive"]:
		informant.increment_objective("QST_SEN_009", objective_id)
	var informant_result: Dictionary = informant.resolve_branch("QST_SEN_009", "council_resolution", "informant")
	_check(bool(informant_result.get("ok", false)) and informant.get_flag("FLG_RUKKA_INFORMANT"), "informant solution resolves with its persistent flag")
	_check(int(informant.attributes.get("corruption", 0)) == 2 and int(informant.counters.get("underworld_heat", 0)) == 2, "informant solution applies Corruption and underworld heat")
	_check(informant.unlock_tags.has("rukka_future_information") and informant.can_complete_quest("QST_SEN_009"), "informant outcome unlocks future information and completes QST_SEN_009")

	var insufficient_gold: Variant = RuntimeScript.new()
	_check(insufficient_gold.configure(campaign), "insufficient-gold branch fixture configures")
	_check(insufficient_gold.restore_state(_quest_fixture_state(insufficient_gold, "QST_SEN_009")), "insufficient-gold branch fixture restores")
	insufficient_gold.inventory["gold"] = 0
	for objective_id in ["hear_supply_report", "inspect_depot", "follow_rukka_trail", "discover_rukka_motive"]:
		insufficient_gold.increment_objective("QST_SEN_009", objective_id)
	_check(insufficient_gold.get_available_branches("QST_SEN_009", "council_resolution").size() == 3, "pay route is unavailable without funds while three alternatives remain")
	var rejected_payment: Dictionary = insufficient_gold.resolve_branch("QST_SEN_009", "council_resolution", "pay_shortage")
	_check(not bool(rejected_payment.get("ok", false)) and int(insufficient_gold.inventory.get("gold", 0)) == 0, "unfunded protection choice cannot consume gold or resolve the branch")

	var charm_pass: Variant = RuntimeScript.new()
	_check(charm_pass.configure(campaign, {"lust": 30}), "successful council charm fixture configures")
	_check(charm_pass.restore_state(_quest_fixture_state(charm_pass, "QST_SEN_009")), "successful council charm fixture restores")
	for objective_id in ["hear_supply_report", "inspect_depot", "follow_rukka_trail", "discover_rukka_motive"]:
		charm_pass.increment_objective("QST_SEN_009", objective_id)
	var success: Dictionary = charm_pass.resolve_branch("QST_SEN_009", "council_resolution", "charm")
	_check(bool(success.get("ok", false)) and bool(success.get("check_passed", false)), "charm meets the Lust 30 threshold")
	_check(int(charm_pass.desire.get("council_npc", 0)) == 5 and int(charm_pass.reputation.get("social", 0)) == 3, "successful charm applies the specified desire and social reputation effects")
	_check(charm_pass.can_complete_quest("QST_SEN_009"), "successful charm secures supplies")

	var charm_fail: Variant = RuntimeScript.new()
	_check(charm_fail.configure(campaign, {"lust": 29}), "failed council charm fixture configures")
	_check(charm_fail.restore_state(_quest_fixture_state(charm_fail, "QST_SEN_009")), "failed council charm fixture restores")
	for objective_id in ["hear_supply_report", "inspect_depot", "follow_rukka_trail", "discover_rukka_motive"]:
		charm_fail.increment_objective("QST_SEN_009", objective_id)
	var failure: Dictionary = charm_fail.resolve_branch("QST_SEN_009", "council_resolution", "charm")
	_check(bool(failure.get("ok", false)) and not bool(failure.get("check_passed", true)) and str(failure.get("result", "")) == "fail_forward", "failed charm check remains a fail-forward outcome")
	_check(charm_fail.get_flag("FLG_RUKKA_COUNCIL_SAW_MANIPULATION"), "failed charm records that the council noticed the manipulation")
	_check(charm_fail.can_complete_quest("QST_SEN_009"), "failed charm still secures supplies")


func _quest_fixture_state(runtime: Variant, active_quest_id: String) -> Dictionary:
	var state: Dictionary = runtime.export_state()
	var order: Array = runtime.definition.get("quest_order", [])
	for quest_id_value in order:
		var quest_id := str(quest_id_value)
		if quest_id == active_quest_id:
			state["quests"][quest_id]["state"] = "in_progress"
			break
		state["quests"][quest_id]["state"] = "turned_in"
	return state


func _contains_branch(branches: Array[Dictionary], branch_id: String) -> bool:
	for branch in branches:
		if str(branch.get("id", "")) == branch_id:
			return true
	return false


func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		push_error("CAMPAIGN_QUEST_RUNTIME_TEST: FAIL | %s" % label)


func _finish() -> void:
	if failures.is_empty():
		print("CAMPAIGN_QUEST_RUNTIME_TEST: PASS (%d checks)" % checks)
		quit(0)
	else:
		push_error("CAMPAIGN_QUEST_RUNTIME_TEST: %d/%d checks failed" % [failures.size(), checks])
		quit(1)
