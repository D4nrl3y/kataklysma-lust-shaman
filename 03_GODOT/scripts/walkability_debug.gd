extends Node2D

var walkable_polygons: Array[PackedVector2Array] = []
var blocker_rects: Array[Rect2] = []
var blocker_polygons: Array = []
var blocker_ids: Array[String] = []
var map_size := Vector2(1672.0, 941.0)

func configure(regions: Array[PackedVector2Array], rects: Array[Rect2], polygons: Array, ids: Array[String] = [], world_size := Vector2(1672.0, 941.0)) -> void:
    walkable_polygons = regions
    blocker_rects = rects
    blocker_polygons = polygons
    blocker_ids = ids
    map_size = world_size
    queue_redraw()

func _draw() -> void:
    var grid_color := Color(0.78, 0.91, 1.0, 0.24)
    for x in range(0, int(map_size.x) + 1, 200):
        draw_line(Vector2(x, 0), Vector2(x, map_size.y), grid_color, 1.0)
        draw_string(ThemeDB.fallback_font, Vector2(x + 3, 14), str(x), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, Color.WHITE)
    for y in range(0, int(map_size.y) + 1, 200):
        draw_line(Vector2(0, y), Vector2(map_size.x, y), grid_color, 1.0)
        draw_string(ThemeDB.fallback_font, Vector2(3, y + 12), str(y), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, Color.WHITE)
    for region in walkable_polygons:
        if region.size() >= 3:
            draw_colored_polygon(region, Color(0.15, 0.85, 0.52, 0.18))
            draw_polyline(region, Color(0.48, 1.0, 0.78, 0.94), 2.0, true)
    for blocker in blocker_rects:
        draw_rect(blocker, Color(0.92, 0.16, 0.25, 0.18), true)
        draw_rect(blocker, Color(1.0, 0.35, 0.42, 0.94), false, 2.0)
    for index in blocker_polygons.size():
        var blocker: PackedVector2Array = blocker_polygons[index]
        if blocker.size() >= 3:
            draw_colored_polygon(blocker, Color(0.92, 0.16, 0.25, 0.18))
            draw_polyline(blocker, Color(1.0, 0.35, 0.42, 0.94), 2.0, true)
            var camera := get_viewport().get_camera_2d()
            var labels_readable := camera == null or camera.zoom.x >= 0.9
            if labels_readable and index < blocker_ids.size() and not blocker_ids[index].begins_with("training_post"):
                var center := Vector2.ZERO
                for point in blocker:
                    center += point
                center /= float(blocker.size())
                draw_string(ThemeDB.fallback_font, center, blocker_ids[index], HORIZONTAL_ALIGNMENT_CENTER, -1.0, 10, Color.WHITE)
