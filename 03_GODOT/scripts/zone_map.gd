class_name KataklysmaZoneMap
extends Node2D

@export var zone_id := "echo_isles"
@export var zone_data_path := "res://03_GODOT/data/zones.json"

var zone_data: Dictionary = {}

func _ready() -> void:
    zone_data = _load_zone(zone_id)

func get_interaction_types() -> Array:
    return zone_data.get("interactions", [])

func get_monster_ids() -> Array:
    return zone_data.get("monsters", [])

func get_random_encounter_table() -> String:
    return zone_data.get("random_encounter_table", "")

func _load_zone(target_id: String) -> Dictionary:
    var file := FileAccess.open(zone_data_path, FileAccess.READ)
    if file == null:
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary:
        return {}
    for zone in parsed.get("zones", []):
        if zone.get("id", "") == target_id:
            return zone
    return {}
