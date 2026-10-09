extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed_scene: PackedScene = load("res://03_GODOT/scenes/main.tscn")
	var demo = packed_scene.instantiate()
	root.add_child(demo)
	await process_frame
	demo.campaign_mode = true
	var world_walkable: Array[Vector2] = _reachable_world_samples(demo)
	for probe in [Vector2(200.0, 150.0), Vector2(250.0, 180.0), Vector2(300.0, 220.0), Vector2(400.0, 300.0), Vector2(430.0, 320.0), Vector2(700.0, 430.0), Vector2(830.0, 400.0), Vector2(1380.0, 630.0)]:
		var nearest := Vector2.ZERO
		var distance := INF
		for candidate in world_walkable:
			var candidate_distance := candidate.distance_to(probe)
			if candidate_distance < distance:
				distance = candidate_distance
				nearest = candidate
		print("WORLD_SAMPLE | wanted=%s | nearest=%s | distance=%.1f" % [probe, nearest, distance])
	for point_value in demo.campaign_interaction_data.get("points", []):
		var point: Dictionary = point_value
		var point_scene := str(point.get("scene", "echo_isles"))
		if point_scene not in ["echo_isles", "cabin"]:
			continue
		var target_data: Array = point.get("position", [0.0, 0.0])
		var target := Vector2(float(target_data[0]), float(target_data[1]))
		demo._set_campaign_scene(point_scene)
		if demo._is_walkable_position(target):
			print("ANCHOR_OK | %s | %s" % [point.get("id", ""), target])
			continue
		var best_position := Vector2.ZERO
		var best_distance := INF
		var candidates: Array[Vector2] = world_walkable
		if str(point.get("scene", "echo_isles")) == "cabin":
			candidates = _cabin_samples(demo)
		for candidate in candidates:
			var distance := candidate.distance_to(target)
			if distance < best_distance:
				best_distance = distance
				best_position = candidate
		print("ANCHOR_RELOCATE | %s | old=%s | new=%s | delta=%.1f" % [point.get("id", ""), target, best_position, best_distance])
	demo.queue_free()
	await process_frame
	quit()

func _reachable_world_samples(demo) -> Array[Vector2]:
	const GRID_STEP := 8
	var min_cell := Vector2i(10, 16)
	var max_cell := Vector2i(int(demo.MAP_SIZE.x) / GRID_STEP - 10, int(demo.MAP_SIZE.y) / GRID_STEP - 16)
	var start_cell := Vector2i(roundi(demo.PLAYER_START.x / GRID_STEP), roundi(demo.PLAYER_START.y / GRID_STEP))
	var pending: Array[Vector2i] = [start_cell]
	var visited: Dictionary = {start_cell: true}
	var directions := [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
	var result: Array[Vector2] = []
	var cursor := 0
	while cursor < pending.size():
		var cell: Vector2i = pending[cursor]
		cursor += 1
		var position := Vector2(cell.x * GRID_STEP, cell.y * GRID_STEP)
		result.append(position)
		for direction in directions:
			var next_cell: Vector2i = cell + direction
			if next_cell.x < min_cell.x or next_cell.y < min_cell.y or next_cell.x > max_cell.x or next_cell.y > max_cell.y or visited.has(next_cell):
				continue
			var next_position := Vector2(next_cell.x * GRID_STEP, next_cell.y * GRID_STEP)
			if demo._is_walkable_position(next_position):
				visited[next_cell] = true
				pending.append(next_cell)
	return result

func _cabin_samples(demo) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var previous_scene: String = demo.campaign_scene_id
	demo.campaign_scene_id = "cabin"
	for y in range(220, 820, 8):
		for x in range(200, 1470, 8):
			var position := Vector2(x, y)
			if demo._is_walkable_position(position):
				result.append(position)
	demo.campaign_scene_id = previous_scene
	return result
