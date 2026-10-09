extends SceneTree

const CampaignQuestRuntimeScript = preload("res://03_GODOT/scripts/campaign_quest_runtime.gd")
const CAMPAIGN_PATH := "res://03_GODOT/data/campaign/echo_isles.json"

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var file := FileAccess.open(CAMPAIGN_PATH, FileAccess.READ)
	var definition: Dictionary = JSON.parse_string(file.get_as_text()) if file else {}
	var failed_charm = _ready_q004_runtime(definition, 10)
	var failed_result: Dictionary = failed_charm.resolve_branch("QST_ECHO_004", "frog_method", "charm")
	_expect(bool(failed_result.get("ok", false)) and not bool(failed_result.get("check_passed", true)), "low-Lust charm attempt fails forward")
	_expect(failed_charm.get_objective_progress("QST_ECHO_004", "live_frogs") == 0, "failed charm grants no frogs")
	_expect(int(failed_charm.inventory.get("live_frog", 0)) == 0, "failed charm adds no frog inventory")
	_expect(failed_charm.get_flag("FLG_ECHO_004_CHARM_ATTEMPT"), "failed charm still records the branch")

	var passed_charm = _ready_q004_runtime(definition, 43)
	var passed_result: Dictionary = passed_charm.resolve_branch("QST_ECHO_004", "frog_method", "charm")
	_expect(bool(passed_result.get("ok", false)) and bool(passed_result.get("check_passed", false)), "qualified charm partially succeeds")
	_expect(passed_charm.get_objective_progress("QST_ECHO_004", "live_frogs") == 2, "charm success credits only two of six frogs")
	_expect(int(passed_charm.inventory.get("live_frog", 0)) == 2, "charm success grants matching frog inventory")

	var barter = _ready_q004_runtime(definition, 43)
	var barter_result: Dictionary = barter.resolve_branch("QST_ECHO_004", "frog_method", "barter")
	_expect(bool(barter_result.get("ok", false)), "fair barter branch resolves")
	_expect(barter.get_objective_progress("QST_ECHO_004", "live_frogs") == 2, "fair barter contributes two live frogs")
	_expect(int(barter.inventory.get("live_frog", 0)) == 2, "barter inventory matches objective contribution")
	var restored = CampaignQuestRuntimeScript.new()
	_expect(restored.configure(definition, {"lust":43}), "fresh runtime accepts campaign definition")
	_expect(restored.restore_state(barter.export_state()), "partial barter reward survives save data round-trip")
	_expect(restored.get_objective_progress("QST_ECHO_004", "live_frogs") == 2 and int(restored.inventory.get("live_frog", 0)) == 2, "restored barter reward remains internally consistent")

	if failures.is_empty():
		print("CAMPAIGN_FROG_BRANCH_TEST: PASS (15 checks)")
		quit(0)
	else:
		push_error("CAMPAIGN_FROG_BRANCH_TEST: FAIL -> %s" % ", ".join(failures))
		quit(1)

func _ready_q004_runtime(definition: Dictionary, lust_value: int):
	var runtime = CampaignQuestRuntimeScript.new()
	if not runtime.configure(definition, {"lust":lust_value}):
		_fail("runtime configures")
	runtime.quest_records["QST_ECHO_004"]["state"] = "in_progress"
	runtime.set_objective_progress("QST_ECHO_004", "speak_to_tazrima", 1)
	runtime.set_objective_progress("QST_ECHO_004", "meet_apprentice", 1)
	return runtime

func _expect(condition: bool, label: String) -> void:
	if not condition:
		_fail(label)

func _fail(label: String) -> void:
	failures.append(label)
