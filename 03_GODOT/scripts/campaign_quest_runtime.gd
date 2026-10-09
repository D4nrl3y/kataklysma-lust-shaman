extends RefCounted
class_name CampaignQuestRuntime

const SAVE_SCHEMA_VERSION := 2
const QUEST_STATES := ["available", "in_progress", "complete", "turned_in"]

var definition: Dictionary = {}
var quest_records: Dictionary = {}
var story_flags: Dictionary = {}
var attributes: Dictionary = {}
var affinity: Dictionary = {}
var trust: Dictionary = {}
var desire: Dictionary = {}
var reputation: Dictionary = {}
var counters: Dictionary = {}
var inventory: Dictionary = {}
var journal_entries: Array[String] = []
var unlock_tags: Array[String] = []
var chapter_id := "ECHO_ISLES"
var region_id := "echo_isles"
var safe_position := Vector2.ZERO
var tutorial_flags: Dictionary = {"movement_seen": false}
var event_seed := 0
var event_sequence := 0
var validation_errors: Array[String] = []


func configure(campaign_definition: Dictionary, starting_attributes: Dictionary = {}) -> bool:
	validation_errors = validate_definition(campaign_definition)
	if not validation_errors.is_empty():
		return false
	definition = campaign_definition.duplicate(true)
	_reset_campaign(starting_attributes)
	return true


func validate_definition(campaign_definition: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if int(campaign_definition.get("schema_version", -1)) != 1:
		errors.append("schema_version must be 1")
	if str(campaign_definition.get("campaign_id", "")).is_empty():
		errors.append("campaign_id is required")
	var quest_order: Array = campaign_definition.get("quest_order", [])
	var quests: Dictionary = campaign_definition.get("quests", {})
	if quest_order.is_empty():
		errors.append("quest_order is empty")
	if quests.is_empty():
		errors.append("quests is empty")
	var seen_quests: Dictionary = {}
	var quest_positions: Dictionary = {}
	for index in range(quest_order.size()):
		quest_positions[str(quest_order[index])] = index
	var known_flags: Dictionary = {}
	var pending_flags: Array[String] = []
	for quest_index in range(quest_order.size()):
		var quest_id_value: Variant = quest_order[quest_index]
		var quest_id := str(quest_id_value)
		if seen_quests.has(quest_id):
			errors.append("duplicate quest in order: %s" % quest_id)
			continue
		seen_quests[quest_id] = true
		if not quests.has(quest_id):
			errors.append("ordered quest definition missing: %s" % quest_id)
			continue
		var quest: Dictionary = quests[quest_id]
		if str(quest.get("id", "")) != quest_id:
			errors.append("quest id mismatch: %s" % quest_id)
		var objective_ids: Dictionary = {}
		for objective_value in quest.get("objectives", []):
			if typeof(objective_value) != TYPE_DICTIONARY:
				errors.append("invalid objective in %s" % quest_id)
				continue
			var objective: Dictionary = objective_value
			var objective_id := str(objective.get("id", ""))
			if objective_id.is_empty() or objective_ids.has(objective_id):
				errors.append("empty or duplicate objective in %s: %s" % [quest_id, objective_id])
			else:
				objective_ids[objective_id] = true
			if int(objective.get("target", 0)) < 1:
				errors.append("objective target must be positive: %s/%s" % [quest_id, objective_id])
		var group_ids: Dictionary = {}
		var branch_catalog: Dictionary = {}
		for group_value in quest.get("branch_groups", []):
			if typeof(group_value) != TYPE_DICTIONARY:
				errors.append("invalid branch group in %s" % quest_id)
				continue
			var group: Dictionary = group_value
			var group_id := str(group.get("id", ""))
			if group_id.is_empty() or group_ids.has(group_id):
				errors.append("empty or duplicate branch group in %s: %s" % [quest_id, group_id])
			else:
				group_ids[group_id] = true
			var branch_ids: Dictionary = {}
			for branch_value in group.get("branches", []):
				if typeof(branch_value) != TYPE_DICTIONARY:
					errors.append("invalid branch in %s/%s" % [quest_id, group_id])
					continue
				var branch: Dictionary = branch_value
				var branch_id := str(branch.get("id", ""))
				if branch_id.is_empty() or branch_ids.has(branch_id):
					errors.append("empty or duplicate branch in %s/%s: %s" % [quest_id, group_id, branch_id])
				else:
					branch_ids[branch_id] = true
				if not str(branch.get("flag", "")).begins_with("FLG_"):
					errors.append("branch flag must use FLG_ prefix: %s/%s/%s" % [quest_id, group_id, branch_id])
				else:
					known_flags[str(branch.get("flag", ""))] = true
				for required_flag_value in branch.get("requires_flags", []):
					pending_flags.append(str(required_flag_value))
				for progress_key in ["progress_on_branch", "progress_on_check_pass"]:
					var branch_progress: Dictionary = branch.get(progress_key, {})
					for objective_id_value in branch_progress:
						var progress_objective_id := str(objective_id_value)
						if not objective_ids.has(progress_objective_id):
							errors.append("branch progress references unknown objective: %s/%s/%s" % [quest_id, branch_id, progress_objective_id])
						if int(branch_progress[objective_id_value]) < 0:
							errors.append("branch progress must not be negative: %s/%s/%s" % [quest_id, branch_id, progress_objective_id])
			for objective_id_value in group.get("requires_objectives_completed", []):
				if not objective_ids.has(str(objective_id_value)):
					errors.append("branch group references unknown objective: %s/%s/%s" % [quest_id, group_id, objective_id_value])
			branch_catalog[group_id] = branch_ids
		for group_value in quest.get("branch_groups", []):
			var group: Dictionary = group_value
			var group_id := str(group.get("id", ""))
			var available_if: Dictionary = group.get("available_if_branch", {})
			if not available_if.is_empty():
				var parent_group_id := str(available_if.get("group_id", ""))
				var parent_branch_id := str(available_if.get("branch_id", ""))
				if not branch_catalog.has(parent_group_id) or not branch_catalog[parent_group_id].has(parent_branch_id):
					errors.append("conditional branch group references unknown branch: %s/%s -> %s/%s" % [quest_id, group_id, parent_group_id, parent_branch_id])
		for required_group_value in quest.get("required_branch_groups", []):
			if not group_ids.has(str(required_group_value)):
				errors.append("required branch group missing: %s/%s" % [quest_id, required_group_value])
		var completion: Dictionary = quest.get("completion", {})
		for requirement_value in completion.get("all", []):
			var requirement: Dictionary = requirement_value
			if not objective_ids.has(str(requirement.get("objective_id", ""))):
				errors.append("completion rule references unknown objective: %s/%s" % [quest_id, requirement.get("objective_id", "")])
		for path_value in completion.get("any_paths", []):
			var path: Dictionary = path_value
			var branch_requirement: Dictionary = path.get("branch", {})
			if not branch_requirement.is_empty():
				var path_group_id := str(branch_requirement.get("group_id", ""))
				var path_branch_id := str(branch_requirement.get("branch_id", ""))
				if not branch_catalog.has(path_group_id) or not branch_catalog[path_group_id].has(path_branch_id):
					errors.append("completion path references unknown branch: %s/%s -> %s/%s" % [quest_id, path.get("id", ""), path_group_id, path_branch_id])
			for requirement_value in path.get("objectives", []):
				var requirement: Dictionary = requirement_value
				if not objective_ids.has(str(requirement.get("objective_id", ""))):
					errors.append("completion path references unknown objective: %s/%s/%s" % [quest_id, path.get("id", ""), requirement.get("objective_id", "")])
		for prerequisite_value in quest.get("prerequisites", []):
			var prerequisite_id := str(prerequisite_value)
			if not quests.has(prerequisite_id):
				errors.append("unknown prerequisite in %s: %s" % [quest_id, prerequisite_value])
			elif int(quest_positions.get(prerequisite_id, quest_index)) >= quest_index:
				errors.append("prerequisite must appear earlier in quest_order: %s -> %s" % [quest_id, prerequisite_id])
	for quest_id in quests:
		if not seen_quests.has(str(quest_id)):
			errors.append("quest omitted from order: %s" % quest_id)
	for required_flag in pending_flags:
		if not known_flags.has(required_flag):
			errors.append("conditional branch requires unknown story flag: %s" % required_flag)
	return errors


func _reset_campaign(starting_attributes: Dictionary) -> void:
	quest_records.clear()
	var quests: Dictionary = definition.get("quests", {})
	for quest_id_value in definition.get("quest_order", []):
		var quest_id := str(quest_id_value)
		var quest: Dictionary = quests.get(quest_id, {})
		quest_records[quest_id] = _make_empty_quest_record(quest)
	story_flags.clear()
	attributes = starting_attributes.duplicate(true)
	affinity.clear()
	trust.clear()
	desire.clear()
	reputation.clear()
	counters.clear()
	inventory = {"gold": 100}
	journal_entries.clear()
	unlock_tags.clear()
	chapter_id = "ECHO_ISLES"
	region_id = "echo_isles"
	safe_position = Vector2.ZERO
	tutorial_flags = {"movement_seen": false}
	event_seed = 0
	event_sequence = 0


func get_quest_state(quest_id: String) -> String:
	if not quest_records.has(quest_id):
		return ""
	return str(quest_records[quest_id].get("state", "available"))


func get_active_quest_id() -> String:
	for quest_id_value in definition.get("quest_order", []):
		var quest_id := str(quest_id_value)
		if get_quest_state(quest_id) == "in_progress":
			return quest_id
	for quest_id_value in definition.get("quest_order", []):
		var quest_id := str(quest_id_value)
		if is_quest_unlocked(quest_id):
			return quest_id
	return ""


func get_quest_definition(quest_id: String) -> Dictionary:
	return (definition.get("quests", {}).get(quest_id, {}) as Dictionary).duplicate(true)


func get_objective_definitions(quest_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for objective_value in definition.get("quests", {}).get(quest_id, {}).get("objectives", []):
		if typeof(objective_value) == TYPE_DICTIONARY:
			result.append((objective_value as Dictionary).duplicate(true))
	return result


func is_quest_unlocked(quest_id: String) -> bool:
	if not quest_records.has(quest_id) or get_quest_state(quest_id) != "available":
		return false
	var quest: Dictionary = definition.get("quests", {}).get(quest_id, {})
	for prerequisite_value in quest.get("prerequisites", []):
		if get_quest_state(str(prerequisite_value)) != "turned_in":
			return false
	return true


func _make_empty_quest_record(quest: Dictionary) -> Dictionary:
	var objectives: Dictionary = {}
	for objective_value in quest.get("objectives", []):
		var objective: Dictionary = objective_value
		objectives[str(objective.get("id", ""))] = 0
	var groups: Dictionary = {}
	for group_value in quest.get("branch_groups", []):
		var group: Dictionary = group_value
		groups[str(group.get("id", ""))] = ""
	return {
		"state": "available",
		"objectives": objectives,
		"branch_groups": groups,
		"branch_results": {},
		"completion_path": ""
	}


func accept_quest(quest_id: String) -> bool:
	if not is_quest_unlocked(quest_id):
		return false
	quest_records[quest_id]["state"] = "in_progress"
	return true


func increment_objective(quest_id: String, objective_id: String, amount: int = 1) -> bool:
	if amount <= 0 or get_quest_state(quest_id) != "in_progress":
		return false
	var quest: Dictionary = definition.get("quests", {}).get(quest_id, {})
	var objective_definition: Dictionary = {}
	for objective_value in quest.get("objectives", []):
		var candidate: Dictionary = objective_value
		if str(candidate.get("id", "")) == objective_id:
			objective_definition = candidate
			break
	if objective_definition.is_empty():
		return false
	var progress: Dictionary = quest_records[quest_id]["objectives"]
	var previous_progress := int(progress.get(objective_id, 0))
	var target := int(objective_definition.get("target", 1))
	progress[objective_id] = mini(target, previous_progress + amount)
	if previous_progress < target and int(progress[objective_id]) >= target:
		_apply_effect_dictionary(objective_definition.get("on_complete_effects", {}))
	return true


func set_objective_progress(quest_id: String, objective_id: String, value: int) -> bool:
	if get_quest_state(quest_id) != "in_progress" or value < 0:
		return false
	var quest: Dictionary = definition.get("quests", {}).get(quest_id, {})
	for objective_value in quest.get("objectives", []):
		var objective: Dictionary = objective_value
		if str(objective.get("id", "")) == objective_id:
			var progress: Dictionary = quest_records[quest_id]["objectives"]
			var previous_progress := int(progress.get(objective_id, 0))
			var target := int(objective.get("target", 1))
			progress[objective_id] = mini(value, target)
			if previous_progress < target and int(progress[objective_id]) >= target:
				_apply_effect_dictionary(objective.get("on_complete_effects", {}))
			return true
	return false


func get_objective_progress(quest_id: String, objective_id: String) -> int:
	if not quest_records.has(quest_id):
		return 0
	return int(quest_records[quest_id].get("objectives", {}).get(objective_id, 0))


func get_available_branches(quest_id: String, group_id: String) -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	if get_quest_state(quest_id) != "in_progress":
		return available
	var quest: Dictionary = definition.get("quests", {}).get(quest_id, {})
	var group: Dictionary = _find_branch_group(quest, group_id)
	if group.is_empty() or not _branch_group_available(quest_id, group):
		return available
	if not str(quest_records[quest_id]["branch_groups"].get(group_id, "")).is_empty():
		return available
	for branch_value in group.get("branches", []):
		var branch: Dictionary = branch_value
		if _branch_available(quest_id, branch):
			available.append(branch.duplicate(true))
	return available


func resolve_branch(quest_id: String, group_id: String, branch_id: String) -> Dictionary:
	var result := {"ok": false, "check_passed": true, "result": "", "branch_id": branch_id}
	var available := get_available_branches(quest_id, group_id)
	var chosen: Dictionary = {}
	for branch in available:
		if str(branch.get("id", "")) == branch_id:
			chosen = branch
			break
	if chosen.is_empty():
		result["error"] = "branch unavailable or already resolved"
		return result
	var check_passed := true
	var branch_result := "success"
	var check: Dictionary = chosen.get("check", {})
	if not check.is_empty():
		var attribute_name := str(check.get("attribute", ""))
		check_passed = int(attributes.get(attribute_name, 0)) >= int(check.get("minimum", 0))
		branch_result = str(check.get("pass_result", "success") if check_passed else check.get("fail_result", "fail_forward"))
	if not _can_pay_percentage_costs(chosen):
		result["error"] = "insufficient inventory for branch costs"
		return result
	_apply_percentage_costs(chosen)
	_apply_branch_effects(chosen)
	_apply_branch_objective_progress(quest_id, chosen.get("progress_on_branch", {}))
	if check_passed:
		_apply_effect_dictionary(chosen.get("effects_on_check_pass", {}))
		_apply_branch_objective_progress(quest_id, chosen.get("progress_on_check_pass", {}))
	else:
		_apply_effect_dictionary(chosen.get("effects_on_check_fail", {}))
	story_flags[str(chosen.get("flag", ""))] = true
	quest_records[quest_id]["branch_groups"][group_id] = branch_id
	quest_records[quest_id]["branch_results"][group_id] = {
		"branch_id": branch_id,
		"check_passed": check_passed,
		"result": branch_result
	}
	result["ok"] = true
	result["check_passed"] = check_passed
	result["result"] = branch_result
	return result


func _branch_group_available(quest_id: String, group: Dictionary) -> bool:
	var quest_record: Dictionary = quest_records.get(quest_id, {})
	var selected_if: Dictionary = group.get("available_if_branch", {})
	if not selected_if.is_empty():
		var selected_groups: Dictionary = quest_record.get("branch_groups", {})
		if str(selected_groups.get(str(selected_if.get("group_id", "")), "")) != str(selected_if.get("branch_id", "")):
			return false
	for objective_id_value in group.get("requires_objectives_completed", []):
		var objective_id := str(objective_id_value)
		if not _objective_is_complete(quest_id, objective_id):
			return false
	return true


func _branch_available(quest_id: String, branch: Dictionary) -> bool:
	for required_flag_value in branch.get("requires_flags", []):
		if not bool(story_flags.get(str(required_flag_value), false)):
			return false
	return _can_pay_percentage_costs(branch)


func _can_pay_percentage_costs(branch: Dictionary) -> bool:
	var costs: Dictionary = branch.get("percentage_costs", {})
	for item_id in costs:
		var percentage := int(costs[item_id])
		if percentage < 0 or percentage > 100:
			return false
		var balance := int(inventory.get(str(item_id), 0))
		if percentage > 0 and balance <= 0:
			return false
		var amount := int(ceil(float(balance) * float(percentage) / 100.0))
		if balance < amount:
			return false
	return true


func _apply_percentage_costs(branch: Dictionary) -> void:
	var costs: Dictionary = branch.get("percentage_costs", {})
	for item_id in costs:
		var key := str(item_id)
		var amount := int(ceil(float(inventory.get(key, 0)) * float(int(costs[item_id])) / 100.0))
		inventory[key] = maxi(0, int(inventory.get(key, 0)) - amount)


func _find_branch_group(quest: Dictionary, group_id: String) -> Dictionary:
	for group_value in quest.get("branch_groups", []):
		var group: Dictionary = group_value
		if str(group.get("id", "")) == group_id:
			return group
	return {}


func can_complete_quest(quest_id: String) -> bool:
	if get_quest_state(quest_id) != "in_progress":
		return false
	var quest: Dictionary = definition.get("quests", {}).get(quest_id, {})
	var record: Dictionary = quest_records.get(quest_id, {})
	for requirement_value in quest.get("completion", {}).get("all", []):
		var requirement: Dictionary = requirement_value
		if get_objective_progress(quest_id, str(requirement.get("objective_id", ""))) < int(requirement.get("target", 1)):
			return false
	for group_id_value in quest.get("required_branch_groups", []):
		if str(record.get("branch_groups", {}).get(str(group_id_value), "")).is_empty():
			return false
	var any_paths: Array = quest.get("completion", {}).get("any_paths", [])
	if not any_paths.is_empty():
		var any_path_complete := false
		for path_value in any_paths:
			if _completion_path_is_met(quest_id, path_value):
				any_path_complete = true
				break
		if not any_path_complete:
			return false
	return true


func _completion_path_is_met(quest_id: String, path_value: Variant) -> bool:
	if typeof(path_value) != TYPE_DICTIONARY:
		return false
	var path: Dictionary = path_value
	var branch_requirement: Dictionary = path.get("branch", {})
	if not branch_requirement.is_empty():
		var selected: String = str(quest_records[quest_id]["branch_groups"].get(str(branch_requirement.get("group_id", "")), ""))
		if selected != str(branch_requirement.get("branch_id", "")):
			return false
	for requirement_value in path.get("objectives", []):
		var requirement: Dictionary = requirement_value
		if get_objective_progress(quest_id, str(requirement.get("objective_id", ""))) < int(requirement.get("target", 1)):
			return false
	return true


func complete_quest(quest_id: String) -> bool:
	if not can_complete_quest(quest_id):
		return false
	var quest: Dictionary = definition.get("quests", {}).get(quest_id, {})
	for path_value in quest.get("completion", {}).get("any_paths", []):
		if _completion_path_is_met(quest_id, path_value):
			quest_records[quest_id]["completion_path"] = str(path_value.get("id", ""))
			break
	quest_records[quest_id]["state"] = "complete"
	return true


func turn_in_quest(quest_id: String) -> bool:
	if get_quest_state(quest_id) != "complete":
		return false
	quest_records[quest_id]["state"] = "turned_in"
	return true


func _objective_is_complete(quest_id: String, objective_id: String) -> bool:
	var quest: Dictionary = definition.get("quests", {}).get(quest_id, {})
	for objective_value in quest.get("objectives", []):
		var objective: Dictionary = objective_value
		if str(objective.get("id", "")) == objective_id:
			return get_objective_progress(quest_id, objective_id) >= int(objective.get("target", 1))
	return false


func _apply_branch_effects(branch: Dictionary) -> void:
	_apply_effect_dictionary(branch.get("effects", {}))


func _apply_branch_objective_progress(quest_id: String, progress: Dictionary) -> void:
	for objective_id_value in progress:
		var amount := int(progress[objective_id_value])
		if amount > 0:
			increment_objective(quest_id, str(objective_id_value), amount)


func _apply_effect_dictionary(effects: Dictionary) -> void:
	_apply_numeric_effects(attributes, effects.get("attributes", {}), 0, 100)
	_apply_numeric_effects(affinity, effects.get("affinity", {}))
	_apply_numeric_effects(trust, effects.get("trust", {}))
	_apply_numeric_effects(desire, effects.get("desire", {}))
	_apply_numeric_effects(reputation, effects.get("reputation", {}))
	_apply_numeric_effects(counters, effects.get("counters", {}))
	_apply_numeric_effects(inventory, effects.get("inventory", {}), 0)
	for entry_value in effects.get("journal_entries", []):
		var entry := str(entry_value)
		if not journal_entries.has(entry):
			journal_entries.append(entry)
	for tag_value in effects.get("unlock_tags", []):
		var tag := str(tag_value)
		if not unlock_tags.has(tag):
			unlock_tags.append(tag)
	var flag_effects: Dictionary = effects.get("flags", {})
	for flag_name in flag_effects:
		story_flags[str(flag_name)] = flag_effects[flag_name]


func _apply_numeric_effects(target: Dictionary, deltas: Dictionary, minimum: int = -2147483648, maximum: int = 2147483647) -> void:
	for key in deltas:
		var updated := int(target.get(str(key), 0)) + int(deltas[key])
		if minimum != -2147483648:
			updated = maxi(minimum, updated)
		if maximum != 2147483647:
			updated = mini(maximum, updated)
		target[str(key)] = updated


func get_flag(flag_name: String) -> bool:
	return bool(story_flags.get(flag_name, false))


func set_flag(flag_name: String, value: bool = true) -> void:
	if flag_name.is_empty():
		return
	story_flags[flag_name] = value


func set_checkpoint(new_chapter: String, new_region: String, position: Vector2) -> void:
	chapter_id = new_chapter
	region_id = new_region
	safe_position = position


func set_tutorial_seen(tutorial_id: String, seen: bool = true) -> void:
	tutorial_flags[tutorial_id] = seen


func export_state() -> Dictionary:
	return {
		"save_schema_version": SAVE_SCHEMA_VERSION,
		"campaign_id": str(definition.get("campaign_id", "")),
		"quests": quest_records.duplicate(true),
		"story_flags": story_flags.duplicate(true),
		"attributes": attributes.duplicate(true),
		"affinity": affinity.duplicate(true),
		"trust": trust.duplicate(true),
		"desire": desire.duplicate(true),
		"reputation": reputation.duplicate(true),
		"counters": counters.duplicate(true),
		"inventory": inventory.duplicate(true),
		"journal_entries": journal_entries.duplicate(),
		"unlock_tags": unlock_tags.duplicate(),
		"chapter_id": chapter_id,
		"region_id": region_id,
		"safe_position": [safe_position.x, safe_position.y],
		"tutorial_flags": tutorial_flags.duplicate(true),
		"event_seed": event_seed,
		"event_sequence": event_sequence
	}


func restore_state(saved_state: Dictionary) -> bool:
	var saved_schema := int(saved_state.get("save_schema_version", -1))
	if saved_schema not in [1, SAVE_SCHEMA_VERSION]:
		return false
	if str(saved_state.get("campaign_id", "")) != str(definition.get("campaign_id", "")):
		return false
	var saved_quests: Dictionary = saved_state.get("quests", {})
	var restored_records: Dictionary = {}
	for quest_id_value in definition.get("quest_order", []):
		var quest_id := str(quest_id_value)
		var saved_record: Dictionary = saved_quests.get(quest_id, {})
		var quest: Dictionary = definition["quests"][quest_id]
		if saved_record.is_empty():
			if saved_schema == 1 and quest_id == "QST_SEN_009":
				restored_records[quest_id] = _make_empty_quest_record(quest)
				continue
			return false
		if not QUEST_STATES.has(str(saved_record.get("state", ""))):
			return false
		var objective_values: Dictionary = saved_record.get("objectives", {})
		var restored_objectives: Dictionary = {}
		for objective_value in quest.get("objectives", []):
			var objective: Dictionary = objective_value
			var objective_id := str(objective.get("id", ""))
			var progress := int(objective_values.get(objective_id, -1))
			if progress < 0 or progress > int(objective.get("target", 1)):
				return false
			restored_objectives[objective_id] = progress
		var group_values: Dictionary = saved_record.get("branch_groups", {})
		var restored_groups: Dictionary = {}
		for group_value in quest.get("branch_groups", []):
			var group: Dictionary = group_value
			var group_id := str(group.get("id", ""))
			var selected := str(group_values.get(group_id, ""))
			if not selected.is_empty() and _find_branch(group, selected).is_empty():
				return false
			restored_groups[group_id] = selected
		var saved_branch_results: Dictionary = saved_record.get("branch_results", {})
		restored_records[quest_id] = {
			"state": str(saved_record.get("state", "available")),
			"objectives": restored_objectives,
			"branch_groups": restored_groups,
			"branch_results": saved_branch_results.duplicate(true),
			"completion_path": str(saved_record.get("completion_path", ""))
		}
	var saved_position: Array = saved_state.get("safe_position", [])
	if saved_position.size() != 2:
		return false
	quest_records = restored_records
	story_flags = (saved_state.get("story_flags", {}) as Dictionary).duplicate(true)
	attributes = (saved_state.get("attributes", {}) as Dictionary).duplicate(true)
	affinity = (saved_state.get("affinity", {}) as Dictionary).duplicate(true)
	trust = (saved_state.get("trust", {}) as Dictionary).duplicate(true)
	desire = (saved_state.get("desire", {}) as Dictionary).duplicate(true)
	reputation = (saved_state.get("reputation", {}) as Dictionary).duplicate(true)
	counters = (saved_state.get("counters", {}) as Dictionary).duplicate(true)
	inventory = (saved_state.get("inventory", {}) as Dictionary).duplicate(true)
	if not inventory.has("gold"):
		inventory["gold"] = 100
	journal_entries.assign(saved_state.get("journal_entries", []))
	unlock_tags.assign(saved_state.get("unlock_tags", []))
	chapter_id = str(saved_state.get("chapter_id", "ECHO_ISLES"))
	region_id = str(saved_state.get("region_id", "echo_isles"))
	safe_position = Vector2(float(saved_position[0]), float(saved_position[1]))
	tutorial_flags = (saved_state.get("tutorial_flags", {}) as Dictionary).duplicate(true)
	event_seed = int(saved_state.get("event_seed", 0))
	event_sequence = int(saved_state.get("event_sequence", 0))
	return true


func _find_branch(group: Dictionary, branch_id: String) -> Dictionary:
	for branch_value in group.get("branches", []):
		var branch: Dictionary = branch_value
		if str(branch.get("id", "")) == branch_id:
			return branch
	return {}
