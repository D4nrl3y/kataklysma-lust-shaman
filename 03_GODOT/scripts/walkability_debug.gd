extends Node2D

var walkable_polygons: Array[PackedVector2Array] = []
var blocker_rects: Array[Rect2] = []
var blocker_polygons: Array = []

func configure(regions: Array[PackedVector2Array], rects: Array[Rect2], polygons: Array) -> void:
    walkable_polygons = regions
    blocker_rects = rects
    blocker_polygons = polygons
    queue_redraw()

func _draw() -> void:
    for region in walkable_polygons:
        if region.size() >= 3:
            draw_colored_polygon(region, Color(0.15, 0.85, 0.52, 0.24))
            draw_polyline(region, Color(0.40, 1.0, 0.75, 0.92), 3.0, true)
    for blocker in blocker_rects:
        draw_rect(blocker, Color(0.92, 0.16, 0.25, 0.22), true)
        draw_rect(blocker, Color(1.0, 0.35, 0.42, 0.92), false, 3.0)
    for blocker in blocker_polygons:
        if blocker.size() >= 3:
            draw_colored_polygon(blocker, Color(0.92, 0.16, 0.25, 0.22))
            draw_polyline(blocker, Color(1.0, 0.35, 0.42, 0.92), 3.0, true)
