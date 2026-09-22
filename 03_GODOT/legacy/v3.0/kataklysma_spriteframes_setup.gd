class_name KataklysmaSpriteLibrary
extends RefCounted

const DEFAULT_BASE := "res://Kataklysma_Production_Asset_Pack_FINAL_v3.0/02_SPRITES"

static func build(base_path: String = DEFAULT_BASE) -> SpriteFrames:
    var frames := SpriteFrames.new()
    if frames.has_animation("default"):
        frames.remove_animation("default")

    _add_animation(frames, base_path, "idle", "Idle", 4, 4.0, true)
    _add_animation(frames, base_path, "walk", "Walk", 4, 8.0, true)
    _add_animation(frames, base_path, "cast", "Cast", 4, 6.0, false)
    _add_animation(frames, base_path, "combat", "Combat", 4, 10.0, false)
    return frames

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
