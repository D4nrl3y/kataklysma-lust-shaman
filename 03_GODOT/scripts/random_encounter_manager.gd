class_name KataklysmaRandomEncounterManager
extends Node

signal encounter_triggered(table_id: String, encounter: Dictionary)

@export var encounter_data_path := "res://03_GODOT/data/encounter_tables.json"
@export var cooldown_seconds := 45.0
@export var minimum_steps_between_events := 18

var _tables: Dictionary = {}
var _steps_since_event := 0
var _cooldown_left := 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	var file := FileAccess.open(encounter_data_path, FileAccess.READ)
	if file == null:
		push_error("Encounter table data could not be opened: %s" % encounter_data_path)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("Encounter table data is not a JSON object.")
		return
	var rules: Dictionary = parsed.get("rules", {})
	cooldown_seconds = float(rules.get("cooldown_seconds", cooldown_seconds))
	minimum_steps_between_events = int(rules.get("minimum_steps_between_events", minimum_steps_between_events))
	_tables = parsed.get("tables", {})

func _process(delta: float) -> void:
	_cooldown_left = maxf(0.0, _cooldown_left - delta)

func register_step() -> void:
	_steps_since_event += 1

func is_spawn_position(table_id: String, world_position: Vector2) -> bool:
	var table: Dictionary = _tables.get(table_id, {})
	if table.is_empty() or str(table.get("zone_id", "")) == "" or table.get("spawn_regions", []).is_empty():
		return false
	for region in table.get("spawn_regions", []):
		var polygon := _points_to_polygon(region.get("points", []))
		if polygon.size() >= 3 and Geometry2D.is_point_in_polygon(world_position, polygon):
			return true
	return false

func try_roll(table_id: String, world_position: Vector2, blocked := false) -> bool:
	if blocked or _cooldown_left > 0.0 or _steps_since_event < minimum_steps_between_events:
		return false
	var table: Dictionary = _tables.get(table_id, {})
	if table.is_empty() or not is_spawn_position(table_id, world_position):
		return false
	var allowed_types: Array = table.get("allowed_event_types", [])
	var entries: Array = []
	for entry in table.get("entries", []):
		if str(entry.get("type", "")) in allowed_types:
			entries.append(entry)
	if entries.is_empty():
		return false
	var total := 0.0
	for entry in entries:
		total += maxf(0.0, float(entry.get("weight", 0.0)))
	if total <= 0.0 or _rng.randf() * 100.0 > total:
		return false
	var selected := _weighted_pick(entries, total).duplicate(true)
	selected["zone_id"] = str(table.get("zone_id", ""))
	selected["table_id"] = table_id
	_steps_since_event = 0
	_cooldown_left = cooldown_seconds
	encounter_triggered.emit(table_id, selected)
	return true

func _points_to_polygon(points: Array) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for point in points:
		if point is Array and point.size() >= 2:
			polygon.append(Vector2(float(point[0]), float(point[1])))
	return polygon

func _weighted_pick(entries: Array, total: float) -> Dictionary:
	var roll := _rng.randf() * total
	for entry in entries:
		roll -= maxf(0.0, float(entry.get("weight", 0.0)))
		if roll <= 0.0:
			return entry
	return entries.back()
