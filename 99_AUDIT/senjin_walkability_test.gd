extends SceneTree

const GRID_STEP := 8
const EXPECTED_POINTS := ["q009_supply_report", "q009_depot", "q009_trail", "q009_rukka", "q009_council"]
const PASSABLE_LANDMARKS := [
	{"id":"west village southern path", "position":[410.0, 560.0]},
	{"id":"western village stairs", "position":[500.0, 260.0]},
	{"id":"north market approach", "position":[750.0, 80.0]},
	{"id":"central clearing edge", "position":[620.0, 350.0]},
	{"id":"east supply approach", "position":[1154.0, 275.0]},
	{"id":"south sand route", "position":[350.0, 540.0]},
	{"id":"dock access ramp", "position":[1200.0, 590.0]},
	{"id":"west pier", "position":[1000.0, 675.0]},
	{"id":"main pier", "position":[1330.0, 700.0]},
	{"id":"east pier", "position":[1480.0, 625.0]},
	{"id":"south pier branch", "position":[1150.0, 730.0]},
]
const BLOCKED_LANDMARKS := [
	{"id":"west waterfall/cliff edge", "position":[20.0, 170.0]},
	{"id":"water beside west coast", "position":[50.0, 260.0]},
	{"id":"north map boundary beyond market", "position":[800.0, -40.0]},
	{"id":"dense north vegetation", "position":[1500.0, 80.0]},
	{"id":"southwest shore rocks", "position":[80.0, 700.0]},
	{"id":"water below southern beach", "position":[800.0, 900.0]},
	{"id":"water beyond west pier", "position":[840.0, 700.0]},
	{"id":"water gap by south pier branch", "position":[1190.0, 825.0]},
	{"id":"east cliff/ocean edge", "position":[1655.0, 500.0]},
	{"id":"northeast sea edge", "position":[1655.0, 120.0]},
]

var failures: Array[String] = []

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
	demo._set_campaign_scene("senjin_village", Vector2(1325.0, 690.0))
	_check(demo.active_zone_id == "senjin_village", "Sen’jin zone data and collision geometry are active")
	_check(demo.WALKABLE_POLYGONS.size() >= 8 and demo.WALKABILITY_BLOCK_POLYGONS.size() >= 20, "Sen’jin uses detailed walkable and blocker polygons")
	_check(demo._is_walkable_position(Vector2(1325.0, 690.0)), "arrival spawn on the dock is walkable")
	for sample in [Vector2(900.0, 530.0), Vector2(1140.0, 590.0), Vector2(1325.0, 690.0)]:
		_check(demo._is_walkable_position(sample), "intended sand, access ramp, or dock sample is walkable: %s" % sample)
	for sample in [Vector2(800.0, 900.0), Vector2(15.0, 500.0), Vector2(1650.0, 500.0), Vector2(300.0, 400.0), Vector2(800.0, 230.0), Vector2(120.0, 480.0), Vector2(1360.0, 350.0)]:
		_check(not demo._is_walkable_position(sample), "ocean, cliff, building, prop, or dense foliage sample is blocked: %s" % sample)
	for sample_value in PASSABLE_LANDMARKS:
		var sample: Dictionary = sample_value
		var position_data: Array = sample["position"]
		var position := Vector2(float(position_data[0]), float(position_data[1]))
		var walkable: bool = demo._is_walkable_position(position)
		if not walkable:
			print("LANDMARK_DIAGNOSTIC | %s | %s" % [sample["id"], _diagnose_walkability(demo, position)])
		_check(walkable, "visual route landmark is walkable: %s at %s" % [sample["id"], position])
	for sample_value in BLOCKED_LANDMARKS:
		var sample: Dictionary = sample_value
		var position_data: Array = sample["position"]
		var position := Vector2(float(position_data[0]), float(position_data[1]))
		var walkable: bool = demo._is_walkable_position(position)
		if walkable:
			print("LANDMARK_DIAGNOSTIC | %s | %s" % [sample["id"], _diagnose_walkability(demo, position)])
		_check(not walkable, "water/cliff/edge landmark is blocked: %s at %s" % [sample["id"], position])
	for index in demo.WALKABILITY_BLOCK_POLYGONS.size():
		var blocker_polygon: PackedVector2Array = demo.WALKABILITY_BLOCK_POLYGONS[index]
		var blocker_center := Vector2.ZERO
		for point in blocker_polygon:
			blocker_center += point
		blocker_center /= float(blocker_polygon.size())
		var foot_offset: Array = demo.CALIBRATION.get("player_foot_offset", [0.0, 40.0])
		_check(not demo._is_walkable_position(blocker_center - Vector2(float(foot_offset[0]), float(foot_offset[1]))), "named blocker rejects its center: %s" % demo.WALKABILITY_BLOCK_IDS[index])
		var expected_body_name := "WalkabilityBlocker_%s" % demo.WALKABILITY_BLOCK_IDS[index]
		var physical_shape_found := false
		for body_value in demo.collision_world_bodies:
			var body: PhysicsBody2D = body_value
			if body.name == expected_body_name and body.get_child_count() > 0 and (body.get_child(0) is CollisionPolygon2D or body.get_child(0) is CollisionShape2D):
				physical_shape_found = true
				break
		_check(physical_shape_found, "named blocker has an instantiated physics polygon: %s" % demo.WALKABILITY_BLOCK_IDS[index])
		var physical_body_blocked: bool = await _probe_named_blocker(demo, expected_body_name, blocker_center)
		_check(physical_body_blocked, "CharacterBody2D collides with named physics polygon: %s" % demo.WALKABILITY_BLOCK_IDS[index])

	var points_by_id: Dictionary = {}
	for point_value in demo.campaign_interaction_data.get("points", []):
		var point: Dictionary = point_value
		if str(point.get("scene", "")) == "senjin_village" and str(point.get("quest_id", "")) == "QST_SEN_009":
			points_by_id[str(point.get("id", ""))] = point
	for point_id in EXPECTED_POINTS:
		_check(points_by_id.has(point_id), "QST_SEN_009 interaction exists: " + point_id)
		if not points_by_id.has(point_id):
			continue
		var point: Dictionary = points_by_id[point_id]
		var position_data: Array = point.get("position", [0.0, 0.0])
		var anchor := Vector2(float(position_data[0]), float(position_data[1]))
		_check(demo._is_walkable_position(anchor), "QST_SEN_009 anchor is inside walkability: " + point_id)
		var offset_data: Array = point.get("speaker_offset", [0.0, 0.0])
		var speaker_position := anchor + Vector2(float(offset_data[0]), float(offset_data[1]))
		_check(demo._is_walkable_position(speaker_position), "QST_SEN_009 actor position is inside walkability: " + point_id)

	var reachable := _reachable_cells(demo, Vector2(1325.0, 690.0))
	_check(reachable.size() > 1000, "arrival connects to a meaningful contiguous portion of Sen’jin: %d grid cells" % reachable.size())
	var physically_reachable := _reachable_cells(demo, Vector2(1325.0, 690.0), true)
	_check(physically_reachable.size() > 1000, "CharacterBody2D traverses a contiguous Sen’jin route: %d grid cells" % physically_reachable.size())
	print("SENJIN_WALKABILITY_METRICS | whitelist_grid_cells=%d | physical_grid_cells=%d | quest_anchors=%d | named_blockers=%d" % [reachable.size(), physically_reachable.size(), EXPECTED_POINTS.size(), demo.WALKABILITY_BLOCK_IDS.size()])
	for point_id in EXPECTED_POINTS:
		if not points_by_id.has(point_id):
			continue
		var position_data: Array = points_by_id[point_id].get("position", [0.0, 0.0])
		var target := Vector2(float(position_data[0]), float(position_data[1]))
		_check(_distance_to_reachable(reachable, target) <= 48.0, "arrival can walk to interaction range of " + point_id)
		_check(_distance_to_reachable(physically_reachable, target) <= 48.0, "CharacterBody2D can physically reach interaction range of " + point_id)

	var original_body_position: Vector2 = demo.player_collision_body.position
	demo.player_collision_body.position = Vector2(220.0, 500.0)
	demo.player_collision_body.force_update_transform()
	var dense_foliage_blocked: bool = demo.player_collision_body.test_move(demo.player_collision_body.global_transform, Vector2(-100.0, -20.0))
	demo.player_collision_body.position = original_body_position
	_check(dense_foliage_blocked, "StaticBody polygon physically blocks entry into the southwest vegetation")
	_check(demo.senjin_foreground != null and demo.senjin_foreground.texture != null and demo.senjin_foreground.visible, "foreground candidate is loaded only in the Sen’jin world")

	if demo.audio_manager:
		demo.audio_manager.stop_ambience()
	demo.queue_free()
	await process_frame
	_finish()

func _reachable_cells(demo, start_position: Vector2, check_physics := false) -> Dictionary:
	var start_cell := Vector2i(roundi(start_position.x / GRID_STEP), roundi(start_position.y / GRID_STEP))
	var pending: Array[Vector2i] = []
	var visited: Dictionary = {}
	for radius in range(0, 5):
		for y in range(start_cell.y - radius, start_cell.y + radius + 1):
			for x in range(start_cell.x - radius, start_cell.x + radius + 1):
				var candidate := Vector2i(x, y)
				var world_position := Vector2(candidate.x * GRID_STEP, candidate.y * GRID_STEP)
				if demo._is_walkable_position(world_position):
					pending.append(candidate)
					visited[candidate] = true
					break
			if not pending.is_empty():
				break
		if not pending.is_empty():
			break
	var cursor := 0
	while cursor < pending.size():
		var cell: Vector2i = pending[cursor]
		cursor += 1
		var current_position := Vector2(cell.x * GRID_STEP, cell.y * GRID_STEP)
		for direction in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			var next_cell: Vector2i = cell + direction
			if visited.has(next_cell):
				continue
			var next_position := Vector2(next_cell.x * GRID_STEP, next_cell.y * GRID_STEP)
			if next_position.x < 0.0 or next_position.y < 0.0 or next_position.x > demo.MAP_SIZE.x or next_position.y > demo.MAP_SIZE.y:
				continue
			if not demo._is_walkable_position(next_position):
				continue
			if check_physics and demo.collision_probe_for_test(current_position, next_position):
				continue
			visited[next_cell] = true
			pending.append(next_cell)
	return visited

func _distance_to_reachable(reachable: Dictionary, target: Vector2) -> float:
	var best_distance := INF
	for cell_value in reachable.keys():
		var cell: Vector2i = cell_value
		best_distance = minf(best_distance, Vector2(cell.x * GRID_STEP, cell.y * GRID_STEP).distance_to(target))
	return best_distance

func _diagnose_walkability(demo, world_position: Vector2) -> String:
	var foot_offset: Array = demo.CALIBRATION.get("player_foot_offset", [0.0, 40.0])
	var foot_shape: Array = demo.CALIBRATION.get("player_foot_shape", [18.0, 11.0])
	var feet := world_position + Vector2(float(foot_offset[0]), float(foot_offset[1]))
	var half := Vector2(float(foot_shape[0]) * 0.5, float(foot_shape[1]) * 0.5)
	var details: Array[String] = []
	for point in [feet, feet + Vector2(-half.x, -half.y), feet + Vector2(half.x, -half.y), feet + Vector2(-half.x, half.y), feet + Vector2(half.x, half.y)]:
		var walkable_ids: Array[String] = []
		var blocker_ids: Array[String] = []
		for index in demo.WALKABLE_POLYGONS.size():
			if Geometry2D.is_point_in_polygon(point, demo.WALKABLE_POLYGONS[index]):
				walkable_ids.append("region_%d" % index)
		for index in demo.WALKABILITY_BLOCK_POLYGONS.size():
			if Geometry2D.is_point_in_polygon(point, demo.WALKABILITY_BLOCK_POLYGONS[index]):
				blocker_ids.append(str(demo.WALKABILITY_BLOCK_IDS[index]))
		details.append("%s walk=%s block=%s" % [point, walkable_ids, blocker_ids])
	return " ; ".join(details)

func _probe_named_blocker(demo, expected_body_name: String, blocker_center: Vector2) -> bool:
	var blocker_body: StaticBody2D
	for body_value in demo.collision_world_bodies:
		var body: PhysicsBody2D = body_value
		if body.name == expected_body_name:
			blocker_body = body as StaticBody2D
			break
	if blocker_body == null:
		return false
	var foot_offset: Array = demo.CALIBRATION.get("player_foot_offset", [0.0, 40.0])
	var foot_delta := Vector2(float(foot_offset[0]), float(foot_offset[1]))
	var target_player_position := blocker_center - foot_delta
	var start_position := _nearest_walkable_player_position(demo, target_player_position)
	if start_position == Vector2(INF, INF):
		return false
	var saved_masks: Array[Dictionary] = []
	for body_value in demo.collision_world_bodies:
		var body: PhysicsBody2D = body_value
		saved_masks.append({"body":body, "layer":body.collision_layer, "mask":body.collision_mask})
		body.collision_layer = 0
		body.collision_mask = 0
	blocker_body.collision_layer = 1
	blocker_body.collision_mask = 1
	await physics_frame
	var player_body: CharacterBody2D = demo.player_collision_body
	var old_position := player_body.position
	player_body.position = start_position
	player_body.force_update_transform()
	var blocked: bool = player_body.test_move(player_body.global_transform, target_player_position - start_position)
	player_body.position = old_position
	player_body.force_update_transform()
	for saved_value in saved_masks:
		var saved: Dictionary = saved_value
		var body: PhysicsBody2D = saved["body"]
		body.collision_layer = int(saved["layer"])
		body.collision_mask = int(saved["mask"])
	await physics_frame
	return blocked

func _nearest_walkable_player_position(demo, target_player_position: Vector2) -> Vector2:
	for radius in range(24, 401, 8):
		for y in range(-radius, radius + 1, GRID_STEP):
			for x in range(-radius, radius + 1, GRID_STEP):
				if maxi(absi(x), absi(y)) < radius - GRID_STEP:
					continue
				var candidate := target_player_position + Vector2(float(x), float(y))
				if demo._is_walkable_position(candidate):
					return candidate
	return Vector2(INF, INF)

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
		push_error("SENJIN_WALKABILITY_TEST: " + label)

func _finish() -> void:
	if failures.is_empty():
		print("SENJIN_WALKABILITY_TEST: PASS")
		quit(0)
	else:
		push_error("SENJIN_WALKABILITY_TEST: FAIL (%d issues)" % failures.size())
		quit(1)
