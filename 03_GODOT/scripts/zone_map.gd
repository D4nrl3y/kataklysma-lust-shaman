class_name KataklysmaZoneMap
extends Node2D

@export var zone_id := "echo_isles"
@export var zone_data_path := "res://03_GODOT/data/zones.json"
@export var walkability_root_path := "res://03_GODOT/data/walkability"

var zone_data: Dictionary = {}
var walkability_data: Dictionary = {}

func _ready() -> void:
    set_zone_id(zone_id)

func set_zone_id(target_id: String) -> bool:
    var next_zone := _load_zone(target_id)
    if next_zone.is_empty():
        push_error("Zone data is missing: %s" % target_id)
        return false
    var next_walkability := _load_walkability(target_id)
    if next_walkability.is_empty():
        return false
    zone_id = target_id
    zone_data = next_zone
    walkability_data = next_walkability
    return true

func get_interaction_types() -> Array:
    return zone_data.get("interactions", [])

func get_monster_ids() -> Array:
    return zone_data.get("monsters", [])

func get_random_encounter_table() -> String:
    return zone_data.get("random_encounter_table", "")

func get_walkability_data() -> Dictionary:
    return walkability_data.duplicate(true)

func get_background_asset() -> String:
    return str(zone_data.get("background_asset", ""))

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

func _load_walkability(target_id: String) -> Dictionary:
    var path := "%s/%s.json" % [walkability_root_path.trim_suffix("/"), target_id]
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Walkability data could not be opened: %s" % path)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary or str(parsed.get("zone_id", "")) != target_id:
        push_error("Walkability data is invalid or does not match zone %s." % target_id)
        return {}
    return parsed
