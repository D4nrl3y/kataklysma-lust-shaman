extends RefCounted
class_name CampaignWorldRuntime

const VALID_ACTIONS := [
	"objective", "branch", "branch_finish", "objective_then_branch", "finish",
	"exit_cabin", "boar_hunt", "trap", "capture_frog", "makrura_boss", "depart"
]

var definition: Dictionary = {}
var points_by_id: Dictionary = {}
var validation_errors: Array[String] = []


func configure(interaction_data: Dictionary, campaign_runtime: Variant) -> bool:
	validation_errors = validate_definition(interaction_data, campaign_runtime)
	if not validation_errors.is_empty():
		return false
	definition = interaction_data.duplicate(true)
	points_by_id.clear()
	for point_value in definition.get("points", []):
		var point: Dictionary = point_value
		points_by_id[str(point.get("id", ""))] = point
	return true


func validate_definition(interaction_data: Dictionary, campaign_runtime: Variant) -> Array[String]:
	var errors: Array[String] = []
	if int(interaction_data.get("schema_version", -1)) != 1:
		errors.append("schema_version must be 1")
	if campaign_runtime == null:
		errors.append("campaign runtime is required")
	var seen: Dictionary = {}
	for point_value in interaction_data.get("points", []):
		if typeof(point_value) != TYPE_DICTIONARY:
			errors.append("interaction point must be a dictionary")
			continue
		var point: Dictionary = point_value
		var point_id := str(point.get("id", ""))
		var quest_id := str(point.get("quest_id", ""))
		var action := str(point.get("action", ""))
		if point_id.is_empty() or seen.has(point_id):
			errors.append("empty or duplicate point id: %s" % point_id)
		else:
			seen[point_id] = true
		if campaign_runtime != null and campaign_runtime.get_quest_definition(quest_id).is_empty():
			errors.append("point references unknown quest: %s/%s" % [point_id, quest_id])
		if not VALID_ACTIONS.has(action):
			errors.append("unknown action: %s/%s" % [point_id, action])
		var position: Array = point.get("position", [])
		if position.size() != 2:
			errors.append("point position must be [x,y]: %s" % point_id)
		var marker_position: Array = point.get("marker_position", [])
		if not marker_position.is_empty() and marker_position.size() != 2:
			errors.append("marker_position must be [x,y]: %s" % point_id)
		if point.has("radius") and float(point.get("radius", 0.0)) <= 0.0:
			errors.append("interaction radius must be positive: %s" % point_id)
		if action in ["branch", "branch_finish", "objective_then_branch"] and str(point.get("group_id", "")).is_empty():
			errors.append("branch interaction needs group_id: %s" % point_id)
		var required_group_id := str(point.get("requires_branch_group", ""))
		if not required_group_id.is_empty() and not _quest_has_branch_group(campaign_runtime, quest_id, required_group_id):
			errors.append("point references unknown prerequisite branch group: %s/%s" % [point_id, required_group_id])
		var required_branch: Dictionary = point.get("requires_branch", {})
		if not required_branch.is_empty() and not _quest_has_branch(campaign_runtime, quest_id, str(required_branch.get("group_id", "")), str(required_branch.get("branch_id", ""))):
			errors.append("point references unknown prerequisite branch: %s/%s/%s" % [point_id, required_branch.get("group_id", ""), required_branch.get("branch_id", "")])
		for required_objective_id in point.get("requires_objectives", []):
			if not _quest_has_objective(campaign_runtime, quest_id, str(required_objective_id)):
				errors.append("point references unknown prerequisite objective: %s/%s" % [point_id, required_objective_id])
		for objective_value in point.get("objectives", []):
			var objective: Dictionary = objective_value
			var found := false
			for definition_value in campaign_runtime.get_objective_definitions(quest_id):
				if str(definition_value.get("id", "")) == str(objective.get("id", "")):
					found = true
					break
			if not found:
				errors.append("point references unknown objective: %s/%s" % [point_id, objective.get("id", "")])
		if action == "boar_hunt" and not _quest_has_objective(campaign_runtime, quest_id, "boar_meat"):
			errors.append("boar_hunt requires boar_meat objective: %s" % point_id)
		if action == "trap" and not _quest_has_objective(campaign_runtime, quest_id, "trap_meat"):
			errors.append("trap requires trap_meat objective: %s" % point_id)
		if action == "capture_frog" and not _quest_has_objective(campaign_runtime, quest_id, "live_frogs"):
			errors.append("capture_frog requires live_frogs objective: %s" % point_id)
	return errors


func get_point(point_id: String) -> Dictionary:
	return (points_by_id.get(point_id, {}) as Dictionary).duplicate(true)


func get_points_for_scene(scene_id: String, campaign_runtime: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var quest_id := str(campaign_runtime.get_active_quest_id())
	if quest_id.is_empty() or campaign_runtime.get_quest_state(quest_id) != "in_progress":
		return result
	for point_value in definition.get("points", []):
		var point: Dictionary = point_value
		if str(point.get("quest_id", "")) != quest_id or str(point.get("scene", "echo_isles")) != scene_id:
			continue
		if _point_is_available(point, campaign_runtime):
			result.append(point.duplicate(true))
	return result


func _point_is_available(point: Dictionary, campaign_runtime: Variant) -> bool:
	var quest_id := str(point.get("quest_id", ""))
	var action := str(point.get("action", ""))
	for required_objective_id in point.get("requires_objectives", []):
		var objective_id := str(required_objective_id)
		if campaign_runtime.get_objective_progress(quest_id, objective_id) < _objective_target(quest_id, objective_id, campaign_runtime):
			return false
	var required_branch_group := str(point.get("requires_branch_group", ""))
	if not required_branch_group.is_empty() and str(campaign_runtime.quest_records[quest_id]["branch_groups"].get(required_branch_group, "")).is_empty():
		return false
	var required_branch: Dictionary = point.get("requires_branch", {})
	if not required_branch.is_empty():
		if str(campaign_runtime.quest_records[quest_id]["branch_groups"].get(str(required_branch.get("group_id", "")), "")) != str(required_branch.get("branch_id", "")):
			return false
	if action in ["branch", "branch_finish"]:
		return not campaign_runtime.get_available_branches(quest_id, str(point.get("group_id", ""))).is_empty()
	if action == "objective_then_branch":
		if not campaign_runtime.get_available_branches(quest_id, str(point.get("group_id", ""))).is_empty():
			return true
		return _has_incomplete_objective(point, campaign_runtime)
	if action == "exit_cabin":
		return campaign_runtime.get_quest_state(quest_id) == "in_progress" and not str(campaign_runtime.quest_records[quest_id]["branch_groups"].get("awakening_choice", "")).is_empty()
	if action == "boar_hunt":
		return str(campaign_runtime.quest_records[quest_id]["branch_groups"].get("food_method", "")) == "hunt" and campaign_runtime.get_objective_progress(quest_id, "boar_meat") < 4
	if action == "trap":
		return str(campaign_runtime.quest_records[quest_id]["branch_groups"].get("food_method", "")) == "trap" and _has_incomplete_objective(point, campaign_runtime)
	if action == "capture_frog":
		return campaign_runtime.get_objective_progress(quest_id, "live_frogs") < 6
	if action == "makrura_boss":
		return campaign_runtime.get_quest_state(quest_id) == "in_progress" and campaign_runtime.get_objective_progress(quest_id, "makrura_defeated") == 0
	if action == "depart":
		return campaign_runtime.get_quest_state(quest_id) == "in_progress" and _requirements_met_except_point(quest_id, point, campaign_runtime)
	if action == "finish":
		if not _has_incomplete_objective(point, campaign_runtime):
			return false
		if quest_id == "QST_ECHO_001":
			return campaign_runtime.get_flag("FLG_ECHO_001_CABIN_EXITED")
		return _requirements_met_except_point(quest_id, point, campaign_runtime)
	return _has_incomplete_objective(point, campaign_runtime)


func _has_incomplete_objective(point: Dictionary, campaign_runtime: Variant) -> bool:
	var quest_id := str(point.get("quest_id", ""))
	for objective_value in point.get("objectives", []):
		var objective: Dictionary = objective_value
		var objective_id := str(objective.get("id", ""))
		var target := _objective_target(quest_id, objective_id, campaign_runtime)
		if campaign_runtime.get_objective_progress(quest_id, objective_id) < target:
			return true
	return false


func _requirements_met_except_point(quest_id: String, point: Dictionary, campaign_runtime: Variant) -> bool:
	var excluded: Dictionary = {}
	for objective_value in point.get("objectives", []):
		excluded[str(objective_value.get("id", ""))] = true
	var quest: Dictionary = campaign_runtime.get_quest_definition(quest_id)
	for requirement_value in quest.get("completion", {}).get("all", []):
		var requirement: Dictionary = requirement_value
		var objective_id := str(requirement.get("objective_id", ""))
		if excluded.has(objective_id):
			continue
		if campaign_runtime.get_objective_progress(quest_id, objective_id) < int(requirement.get("target", 1)):
			return false
	for group_id_value in quest.get("required_branch_groups", []):
		if str(campaign_runtime.quest_records[quest_id]["branch_groups"].get(str(group_id_value), "")).is_empty():
			return false
	var any_paths: Array = quest.get("completion", {}).get("any_paths", [])
	if not any_paths.is_empty():
		var selected_record: Dictionary = campaign_runtime.quest_records[quest_id]
		var path_met := false
		for path_value in any_paths:
			var path: Dictionary = path_value
			var branch: Dictionary = path.get("branch", {})
			if not branch.is_empty() and str(selected_record["branch_groups"].get(str(branch.get("group_id", "")), "")) != str(branch.get("branch_id", "")):
				continue
			var complete := true
			for requirement_value in path.get("objectives", []):
				var requirement: Dictionary = requirement_value
				var objective_id := str(requirement.get("objective_id", ""))
				if excluded.has(objective_id):
					continue
				if campaign_runtime.get_objective_progress(quest_id, objective_id) < int(requirement.get("target", 1)):
					complete = false
					break
			if complete:
				path_met = true
				break
		if not path_met:
			return false
	return true


func _objective_target(quest_id: String, objective_id: String, campaign_runtime: Variant) -> int:
	for objective_value in campaign_runtime.get_objective_definitions(quest_id):
		if str(objective_value.get("id", "")) == objective_id:
			return int(objective_value.get("target", 1))
	return 1


func _quest_has_objective(campaign_runtime: Variant, quest_id: String, objective_id: String) -> bool:
	for objective_value in campaign_runtime.get_objective_definitions(quest_id):
		if str(objective_value.get("id", "")) == objective_id:
			return true
	return false


func _quest_has_branch_group(campaign_runtime: Variant, quest_id: String, group_id: String) -> bool:
	for group_value in campaign_runtime.get_quest_definition(quest_id).get("branch_groups", []):
		if str(group_value.get("id", "")) == group_id:
			return true
	return false


func _quest_has_branch(campaign_runtime: Variant, quest_id: String, group_id: String, branch_id: String) -> bool:
	for group_value in campaign_runtime.get_quest_definition(quest_id).get("branch_groups", []):
		var group: Dictionary = group_value
		if str(group.get("id", "")) != group_id:
			continue
		for branch_value in group.get("branches", []):
			if str(branch_value.get("id", "")) == branch_id:
				return true
	return false
