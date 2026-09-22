class_name KataklysmaQuestMarker
extends Node2D

enum QuestState { AVAILABLE, IN_PROGRESS, COMPLETE, TURNED_IN }

@export var quest_id: String = ""
@export var state: QuestState = QuestState.AVAILABLE:
    set(value):
        state = value
        _refresh_marker()

@onready var icon: Sprite2D = get_node_or_null("Icon")

const ICONS := {
    QuestState.AVAILABLE: "res://01_ASSETS/kataklysma/ui/markers/quest_available.svg",
    QuestState.IN_PROGRESS: "res://01_ASSETS/kataklysma/ui/markers/quest_in_progress.svg",
    QuestState.COMPLETE: "res://01_ASSETS/kataklysma/ui/markers/quest_complete.svg"
}

func _ready() -> void:
    _refresh_marker()

func set_state(next_state: QuestState) -> void:
    state = next_state

func _refresh_marker() -> void:
    if not is_inside_tree() or icon == null:
        return
    var path: String = ICONS.get(state, "")
    icon.texture = load(path) if path != "" else null
    icon.visible = state != QuestState.TURNED_IN
