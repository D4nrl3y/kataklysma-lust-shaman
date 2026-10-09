extends SceneTree

const RuntimeScript = preload("res://03_GODOT/scripts/campaign_quest_runtime.gd")
const CAMPAIGN_PATH := "res://03_GODOT/data/campaign/echo_isles.json"

var failures: Array[String] = []
var checks := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var file := FileAccess.open(CAMPAIGN_PATH, FileAccess.READ)
	_check(file != null, "campaign definition opens")
	if file == null:
		_finish()
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	_check(parsed is Dictionary, "campaign definition parses")
	if not parsed is Dictionary:
		_finish()
		return
	var campaign: Dictionary = parsed
	var branch_count := 0
	for quest_id_value in campaign.get("quest_order", []):
		var quest_id := str(quest_id_value)
		if not quest_id.begins_with("QST_ECHO_"):
			continue
		var quest: Dictionary = campaign.get("quests", {}).get(quest_id, {})
		for group_value in quest.get("branch_groups", []):
			var group: Dictionary = group_value
			for branch_value in group.get("branches", []):
				var branch: Dictionary = branch_value
				branch_count += 1
				_test_branch(campaign, quest_id, quest, group, branch)
	_check(branch_count == 32, "all 32 authored Echo Isles choices are covered")
	_finish()


func _test_branch(campaign: Dictionary, quest_id: String, quest: Dictionary, group: Dictionary, branch: Dictionary) -> void:
	var attributes := {
		"agility": 50, "stamina": 50, "intellect": 50,
		"spirit": 50, "corruption": 50, "lust": 50,
	}
	var runtime = RuntimeScript.new()
	_check(runtime.configure(campaign, attributes), "%s runtime configures for %s/%s" % [quest_id, group.id, branch.id])
	for quest_id_value in campaign.get("quest_order", []):
		var ordered_quest_id := str(quest_id_value)
		if ordered_quest_id == quest_id:
			runtime.quest_records[ordered_quest_id]["state"] = "in_progress"
			break
		runtime.quest_records[ordered_quest_id]["state"] = "turned_in"

	var parent_condition: Dictionary = group.get("available_if_branch", {})
	if not parent_condition.is_empty():
		runtime.quest_records[quest_id]["branch_groups"][str(parent_condition.group_id)] = str(parent_condition.branch_id)
	for objective_id_value in group.get("requires_objectives_completed", []):
		var objective_id := str(objective_id_value)
		var target := _objective_target(quest, objective_id)
		_check(target > 0, "%s/%s objective prerequisite exists: %s" % [quest_id, group.id, objective_id])
		if target > 0:
			runtime.set_objective_progress(quest_id, objective_id, target)
	for flag_value in branch.get("requires_flags", []):
		runtime.set_flag(str(flag_value), true)

	var available: Array[Dictionary] = runtime.get_available_branches(quest_id, str(group.id))
	var branch_available := false
	for available_branch in available:
		if str(available_branch.get("id", "")) == str(branch.id):
			branch_available = true
			break
	_check(branch_available, "%s/%s branch is reachable" % [quest_id, branch.id])
	if not branch_available:
		return

	var before := {
		"attributes": runtime.attributes.duplicate(true),
		"affinity": runtime.affinity.duplicate(true),
		"trust": runtime.trust.duplicate(true),
		"reputation": runtime.reputation.duplicate(true),
		"counters": runtime.counters.duplicate(true),
		"inventory": runtime.inventory.duplicate(true),
		"objectives": runtime.quest_records[quest_id]["objectives"].duplicate(true),
	}
	var result: Dictionary = runtime.resolve_branch(quest_id, str(group.id), str(branch.id))
	_check(bool(result.get("ok", false)), "%s/%s branch resolves" % [quest_id, branch.id])
	if not bool(result.get("ok", false)):
		return
	_check(runtime.get_flag(str(branch.get("flag", ""))), "%s/%s records its branch flag" % [quest_id, branch.id])
	_check(str(runtime.quest_records[quest_id]["branch_groups"].get(str(group.id), "")) == str(branch.id), "%s/%s stores its selected branch" % [quest_id, branch.id])

	var expected_effects: Dictionary = branch.get("effects", {}).duplicate(true)
	var check_pass_effects: Dictionary = branch.get("effects_on_check_pass", {})
	for category in check_pass_effects:
		var category_values: Dictionary = expected_effects.get(str(category), {}).duplicate(true)
		for key in check_pass_effects[category]:
			category_values[key] = int(category_values.get(key, 0)) + int(check_pass_effects[category][key])
		expected_effects[str(category)] = category_values
	for category in ["attributes", "affinity", "trust", "reputation", "counters", "inventory"]:
		_assert_numeric_effects(runtime.get(str(category)), before[str(category)], expected_effects.get(category, {}), category, quest_id, str(branch.id))
	for entry_value in expected_effects.get("journal_entries", []):
		_check(runtime.journal_entries.has(str(entry_value)), "%s/%s grants journal entry %s" % [quest_id, branch.id, entry_value])
	for tag_value in expected_effects.get("unlock_tags", []):
		_check(runtime.unlock_tags.has(str(tag_value)), "%s/%s grants unlock tag %s" % [quest_id, branch.id, tag_value])
	for flag_name in expected_effects.get("flags", {}):
		_check(runtime.get_flag(str(flag_name)) == bool(expected_effects.flags[flag_name]), "%s/%s applies effect flag %s" % [quest_id, branch.id, flag_name])

	var expected_progress: Dictionary = branch.get("progress_on_branch", {}).duplicate(true)
	if bool(result.get("check_passed", false)):
		for objective_id in branch.get("progress_on_check_pass", {}):
			expected_progress[objective_id] = int(expected_progress.get(objective_id, 0)) + int(branch.progress_on_check_pass[objective_id])
	for objective_id in expected_progress:
		var target := _objective_target(quest, str(objective_id))
		var expected_value := mini(target, int(before.objectives.get(objective_id, 0)) + int(expected_progress[objective_id]))
		_check(runtime.get_objective_progress(quest_id, str(objective_id)) == expected_value, "%s/%s applies objective progress for %s" % [quest_id, branch.id, objective_id])


func _assert_numeric_effects(actual: Dictionary, before: Dictionary, deltas: Dictionary, category: String, quest_id: String, branch_id: String) -> void:
	for key in deltas:
		var expected := int(before.get(str(key), 0)) + int(deltas[key])
		if category == "attributes":
			expected = clampi(expected, 0, 100)
		elif category == "inventory":
			expected = maxi(expected, 0)
		_check(int(actual.get(str(key), 0)) == expected, "%s/%s applies %s.%s delta" % [quest_id, branch_id, category, key])


func _objective_target(quest: Dictionary, objective_id: String) -> int:
	for objective_value in quest.get("objectives", []):
		var objective: Dictionary = objective_value
		if str(objective.get("id", "")) == objective_id:
			return int(objective.get("target", 0))
	return 0


func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		push_error("CAMPAIGN_BRANCH_MATRIX_TEST: FAIL | %s" % label)


func _finish() -> void:
	if failures.is_empty():
		print("CAMPAIGN_BRANCH_MATRIX_TEST: PASS (%d checks; all 32 choices)" % checks)
		quit(0)
	else:
		push_error("CAMPAIGN_BRANCH_MATRIX_TEST: %d/%d checks failed: %s" % [failures.size(), checks, ", ".join(failures)])
		quit(1)
