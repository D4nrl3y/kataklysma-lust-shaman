class_name KataklysmaRandomEncounterManager
extends Node

signal encounter_triggered(zone_id: String, encounter: Dictionary)

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
    if file:
        var parsed = JSON.parse_string(file.get_as_text())
        if parsed is Dictionary:
            var rules: Dictionary = parsed.get("rules", {})
            cooldown_seconds = float(rules.get("cooldown_seconds", cooldown_seconds))
            minimum_steps_between_events = int(rules.get("minimum_steps_between_events", minimum_steps_between_events))
            _tables = parsed.get("tables", {})

func _process(delta: float) -> void:
    _cooldown_left = maxf(0.0, _cooldown_left - delta)

func register_step() -> void:
    _steps_since_event += 1

func try_roll(zone_id: String, blocked := false) -> bool:
    if blocked or _cooldown_left > 0.0 or _steps_since_event < minimum_steps_between_events:
        return false
    var entries: Array = _tables.get(zone_id, [])
    if entries.is_empty():
        return false
    var total := 0.0
    for entry in entries:
        total += float(entry.get("weight", 0.0))
    if total <= 0.0 or _rng.randf() * 100.0 > total:
        return false
    var selected := _weighted_pick(entries, total)
    _steps_since_event = 0
    _cooldown_left = cooldown_seconds
    encounter_triggered.emit(zone_id, selected)
    return true

func _weighted_pick(entries: Array, total: float) -> Dictionary:
    var roll := _rng.randf() * total
    for entry in entries:
        roll -= float(entry.get("weight", 0.0))
        if roll <= 0.0:
            return entry
    return entries.back()
