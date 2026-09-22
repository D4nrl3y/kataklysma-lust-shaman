class_name KataklysmaInteractionMarker
extends Area2D

signal interaction_requested(interaction_id: String, interaction_type: String)

@export var interaction_id: String = ""
@export_enum("dialogue", "quest", "quest_turn_in", "collect", "inspect", "craft", "shop", "travel", "arena", "ritual", "random_encounter_spawn") var interaction_type: String = "inspect"
@export var enabled: bool = true

func interact() -> void:
    if enabled:
        interaction_requested.emit(interaction_id, interaction_type)

func set_enabled(value: bool) -> void:
    enabled = value
    monitoring = value
    monitorable = value
