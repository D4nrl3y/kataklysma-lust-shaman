extends RefCounted

var quest_id := "prototype_echo_isles_tide_v001"
var state: StringName = &"available"
var ordered_states: Array[StringName] = [&"available", &"in_progress", &"complete", &"turned_in"]

func configure(definitions: Dictionary, transitions: Array, target_quest_id: String) -> void:
	quest_id = target_quest_id
	ordered_states.clear()
	for state_name in transitions:
		var normalized := StringName(str(state_name))
		if definitions.has(String(normalized)):
			ordered_states.append(normalized)
	if ordered_states.is_empty():
		ordered_states = [&"available", &"in_progress", &"complete", &"turned_in"]
	if state not in ordered_states:
		state = ordered_states.front()

func transition(target: String) -> bool:
	var target_name := StringName(target)
	if target_name not in ordered_states:
		return false
	if target_name == state:
		return true
	var current_index := ordered_states.find(state)
	if current_index < 0 or current_index + 1 >= ordered_states.size() or ordered_states[current_index + 1] != target_name:
		return false
	state = target_name
	return true

func restore(target: String) -> bool:
	var target_name := StringName(target)
	if target_name not in ordered_states:
		return false
	state = target_name
	return true

func reset() -> void:
	state = &"available"

func get_state() -> String:
	return String(state)
