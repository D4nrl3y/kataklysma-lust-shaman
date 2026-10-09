extends SceneTree

var failures: Array[String] = []
var checks := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene: PackedScene = load("res://03_GODOT/scenes/main.tscn")
	_check(packed_scene != null, "main scene loads")
	if packed_scene == null:
		_finish()
		return
	var demo = packed_scene.instantiate()
	root.add_child(demo)
	await process_frame
	demo.campaign_mode = true
	var points: Array = demo.campaign_interaction_data.get("points", [])
	var dialogue_interactions: Dictionary = demo.campaign_dialogue_data.get("interactions", {})
	_check(demo.campaign_world_runtime.validation_errors.is_empty(), "campaign interaction catalog validates")
	_check(points.size() == 42, "all 37 Echo Isles and five Sen’jin campaign anchors are registered")
	var prop_ids: Dictionary = {}
	for point_value in points:
		var point: Dictionary = point_value
		var point_id := str(point.get("id", ""))
		var point_scene := str(point.get("scene", "echo_isles"))
		demo._set_campaign_scene(point_scene)
		var anchor_data: Array = point.get("position", [0.0, 0.0])
		var anchor := Vector2(float(anchor_data[0]), float(anchor_data[1]))
		_check(demo._is_walkable_position(anchor), "%s interaction anchor remains on walkable ground" % point_id)
		var dialogue_key := str(point.get("dialogue_key", ""))
		_check(not dialogue_key.is_empty() and dialogue_interactions.has(dialogue_key), "%s has PT-BR dialogue data" % point_id)
		var speaker_id := str(point.get("speaker", ""))
		if not speaker_id.is_empty():
			var actors: Array = demo.campaign_actor_nodes.get(speaker_id, [])
			_check(not actors.is_empty() and is_instance_valid(actors[0]), "%s has an integrated campaign actor: %s" % [point_id, speaker_id])
			if speaker_id != "children":
				var offset_value: Variant = point.get("speaker_offset", [])
				var has_offset: bool = offset_value is Array and offset_value.size() == 2
				_check(has_offset, "%s separates its NPC from the interaction anchor" % point_id)
				if has_offset:
					var position_data: Array = point.get("position", [0.0, 0.0])
					var speaker_position := Vector2(float(position_data[0]), float(position_data[1])) + Vector2(float(offset_value[0]), float(offset_value[1]))
					demo._set_campaign_scene(point_scene)
					_check(demo._is_walkable_position(speaker_position), "%s NPC anchor remains on walkable ground" % point_id)
		var point_props: Array = point.get("prop_ids", [])
		if not point_props.is_empty():
			var nodes: Array = demo.campaign_prop_nodes.get(point_id, [])
			_check(nodes.size() == point_props.size(), "%s instantiates every quest prop" % point_id)
			for prop_value in point_props:
				prop_ids[str(prop_value)] = true
			for node_value in nodes:
				var prop_root: Node2D = node_value
				_check(is_instance_valid(prop_root) and prop_root.get_child_count() > 0 and prop_root.get_child(0) is Sprite2D and (prop_root.get_child(0) as Sprite2D).texture != null, "%s prop has a loaded atlas texture" % point_id)
	_check(prop_ids.size() == 20, "all 20 unique Phase 2 quest props remain referenced")
	if demo.audio_manager:
		demo.audio_manager.stop_ambience()
	demo.queue_free()
	await process_frame
	_finish()


func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		push_error("CAMPAIGN_CONTENT_INTEGRITY_TEST: FAIL | %s" % label)


func _finish() -> void:
	if failures.is_empty():
		print("CAMPAIGN_CONTENT_INTEGRITY_TEST: PASS (%d checks; 42 points, 20 quest props)" % checks)
		quit(0)
	else:
		push_error("CAMPAIGN_CONTENT_INTEGRITY_TEST: %d/%d checks failed: %s" % [failures.size(), checks, ", ".join(failures)])
		quit(1)
