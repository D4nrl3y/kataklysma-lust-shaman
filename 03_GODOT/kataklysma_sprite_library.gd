class_name KataklysmaSpriteLibrary
extends RefCounted

const DEFAULT_BASE := "res://01_ASSETS/kataklysma/sprites"
const NPC_BASE := "res://01_ASSETS/kataklysma/sprites/npcs"
const ENTITY_BASE := "res://01_ASSETS/kataklysma/character/entities/sprites"

static func build(base_path: String = DEFAULT_BASE) -> SpriteFrames:
    var frames := SpriteFrames.new()
    if frames.has_animation("default"):
        frames.remove_animation("default")

    _add_animation(frames, base_path, "idle", "idle", 4, 4.0, true)
    _add_animation(frames, base_path, "walk", "walk", 4, 8.0, true)
    _add_animation(frames, base_path, "cast", "cast", 4, 6.0, false)
    _add_animation(frames, base_path, "combat", "combat", 4, 10.0, false)
    return frames

static func build_npc(npc_id: String, base_path: String = NPC_BASE) -> SpriteFrames:
    var frames := SpriteFrames.new()
    _remove_default(frames)
    var root := "%s/%s" % [base_path, npc_id]
    _add_character_animation(frames, root, npc_id, "idle", 4, 4.0, true)
    _add_character_animation(frames, root, npc_id, "walk", 4, 8.0, true)
    _add_character_animation(frames, root, npc_id, "cast", 4, 6.0, false)
    _add_character_animation(frames, root, npc_id, "combat", 4, 10.0, false)
    return frames

static func build_entity(entity_id: String, second_animation: String, base_path: String = ENTITY_BASE) -> SpriteFrames:
    var frames := SpriteFrames.new()
    _remove_default(frames)
    var root := "%s/%s" % [base_path, entity_id]
    _add_character_animation(frames, root, "entity_%s" % entity_id, "idle", 4, 4.0, true)
    _add_character_animation(frames, root, "entity_%s" % entity_id, second_animation.to_lower(), 4, 8.0, false)
    return frames

static func _remove_default(frames: SpriteFrames) -> void:
    if frames.has_animation("default"):
        frames.remove_animation("default")

static func _add_character_animation(
    frames: SpriteFrames,
    root: String,
    file_prefix: String,
    animation_name: String,
    frame_count: int,
    fps: float,
    looped: bool
) -> void:
    frames.add_animation(animation_name)
    frames.set_animation_speed(animation_name, fps)
    frames.set_animation_loop(animation_name, looped)
    for i in range(1, frame_count + 1):
        var filename := "%s_%s_%03d.png" % [file_prefix, animation_name, i]
        var texture: Texture2D = load("%s/%s/%s" % [root, animation_name.to_upper(), filename])
        if texture:
            frames.add_frame(animation_name, texture)

static func _add_animation(
    frames: SpriteFrames,
    base_path: String,
    anim_name: String,
    folder_name: String,
    frame_count: int,
    fps: float,
    looped: bool
) -> void:
    frames.add_animation(anim_name)
    frames.set_animation_speed(anim_name, fps)
    frames.set_animation_loop(anim_name, looped)

    for i in range(1, frame_count + 1):
        var filename := "chr_kataklysma_spr_%s_f%03d_v001.png" % [anim_name, i]
        var texture: Texture2D = load("%s/%s/%s" % [base_path, folder_name, filename])
        if texture:
            frames.add_frame(anim_name, texture)
