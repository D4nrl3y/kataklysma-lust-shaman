extends SceneTree

const SOURCE_ROOT := "res://01_ASSETS/kataklysma"
const BACKUP_ROOT := "res://90_SOURCE_ARCHIVE/legacy/pixel_prelock_v001"
const ALPHA_THRESHOLD := 0.05
const ANCHOR_Y_RATIO := 0.68

var changed_groups: Array[String] = []
var changed_frames := 0
var backup_files := 0
var issues: Array[String] = []

var target_groups := [
	{"label": "player/idle", "folder": "res://01_ASSETS/kataklysma/sprites/idle"},
	{"label": "player/walk", "folder": "res://01_ASSETS/kataklysma/sprites/walk"},
	{"label": "player/cast", "folder": "res://01_ASSETS/kataklysma/sprites/cast"},
	{"label": "attribute_sets/agility_max/CAST", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/agility_max/CAST"},
	{"label": "attribute_sets/corruption_max/COMBAT", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/corruption_max/COMBAT"},
	{"label": "attribute_sets/intellect_max/IDLE", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/intellect_max/IDLE"},
	{"label": "attribute_sets/intellect_max/WALK", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/intellect_max/WALK"},
	{"label": "attribute_sets/intellect_max/CAST", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/intellect_max/CAST"},
	{"label": "attribute_sets/intellect_max/COMBAT", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/intellect_max/COMBAT"},
	{"label": "attribute_sets/lust_max/IDLE", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/lust_max/IDLE"},
	{"label": "attribute_sets/lust_max/WALK", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/lust_max/WALK"},
	{"label": "attribute_sets/lust_max/CAST", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/lust_max/CAST"},
	{"label": "attribute_sets/lust_max/COMBAT", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/lust_max/COMBAT"},
	{"label": "attribute_sets/spirit_max/IDLE", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/spirit_max/IDLE"},
	{"label": "attribute_sets/spirit_max/WALK", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/spirit_max/WALK"},
	{"label": "attribute_sets/spirit_max/CAST", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/spirit_max/CAST"},
	{"label": "attribute_sets/spirit_max/COMBAT", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/spirit_max/COMBAT"},
	{"label": "attribute_sets/stamina_max/IDLE", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/stamina_max/IDLE"},
	{"label": "attribute_sets/stamina_max/WALK", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/stamina_max/WALK"},
	{"label": "attribute_sets/stamina_max/CAST", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/stamina_max/CAST"},
	{"label": "attribute_sets/stamina_max/COMBAT", "folder": "res://01_ASSETS/kataklysma/sprites/attribute_sets/stamina_max/COMBAT"},
	{"label": "npcs/korgash/IDLE", "folder": "res://01_ASSETS/kataklysma/sprites/npcs/korgash/IDLE"},
	{"label": "npcs/mokjala/WALK", "folder": "res://01_ASSETS/kataklysma/sprites/npcs/mokjala/WALK"},
	{"label": "npcs/vexa_geargrin/WALK", "folder": "res://01_ASSETS/kataklysma/sprites/npcs/vexa_geargrin/WALK"}
]

func _init() -> void:
	for group in target_groups:
		_recenter_group(group.label, group.folder)
	_rebuild_sheets()
	print("Recenter complete: %d groups, %d frames, %d backups" % [changed_groups.size(), changed_frames, backup_files])
	if not issues.is_empty():
		for issue in issues:
			print("ISSUE: %s" % issue)
	quit(1 if not issues.is_empty() else 0)

func _recenter_group(label: String, folder: String) -> void:
	var files: Array[String] = []
	for file_name in DirAccess.get_files_at(folder):
		if file_name.to_lower().ends_with(".png"):
			files.append(file_name)
	files.sort()
	if files.size() != 4:
		issues.append("%s: expected 4 frames, found %d" % [label, files.size()])
		return
	var frames: Array[Dictionary] = []
	for file_name in files:
		var path := "%s/%s" % [folder, file_name]
		var image := Image.new()
		if image.load(path) != OK:
			issues.append("%s: could not load %s" % [label, path])
			return
		frames.append(_measure(image, path))
	var width: int = frames[0].width
	var height: int = frames[0].height
	for frame in frames:
		if frame.width != width or frame.height != height:
			issues.append("%s: inconsistent frame dimensions" % label)
			return
	var target_x := _median_float(frames, "anchor_x")
	var target_y := _median_float(frames, "max_y")
	var x_range := _feasible_range(frames, "anchor_x", "min_x", "max_x", width)
	var y_range := _feasible_range(frames, "max_y", "min_y", "max_y", height)
	if x_range.x > x_range.y:
		issues.append("%s: no non-clipping horizontal alignment exists at %dx%d" % [label, width, height])
		target_x = clampf(target_x, 0.0, float(width - 1))
	else:
		target_x = clampf(target_x, x_range.x, x_range.y)
	if y_range.x > y_range.y:
		issues.append("%s: no non-clipping vertical alignment exists at %dx%d" % [label, width, height])
		target_y = clampf(target_y, 0.0, float(height - 1))
	else:
		target_y = clampf(target_y, y_range.x, y_range.y)
	var group_changed := false
	for index in frames.size():
		var frame: Dictionary = frames[index]
		var shift_x := int(round(target_x - frame.anchor_x))
		var shift_y := int(round(target_y - frame.max_y))
		if shift_x == 0 and shift_y == 0:
			continue
		var source_path: String = frame.path
		var backup_path := _backup_path(source_path)
		if not FileAccess.file_exists(backup_path):
			DirAccess.make_dir_recursive_absolute(backup_path.get_base_dir())
			if DirAccess.copy_absolute(source_path, backup_path) != OK:
				issues.append("%s: backup failed for %s" % [label, source_path])
				continue
			backup_files += 1
		var corrected := Image.create(frame.width, frame.height, false, Image.FORMAT_RGBA8)
		corrected.fill(Color(0, 0, 0, 0))
		corrected.blit_rect(frame.image, Rect2i(0, 0, frame.width, frame.height), Vector2i(shift_x, shift_y))
		if corrected.save_png(source_path) != OK:
			issues.append("%s: write failed for %s" % [label, source_path])
			continue
		changed_frames += 1
		group_changed = true
	if group_changed:
		changed_groups.append(label)

func _measure(image: Image, path: String) -> Dictionary:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	var anchor_min_x := image.get_width()
	var anchor_max_x := -1
	var anchor_y_start := int(float(image.get_height()) * ANCHOR_Y_RATIO)
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a > ALPHA_THRESHOLD:
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
				min_y = mini(min_y, y)
				max_y = maxi(max_y, y)
				if y >= anchor_y_start:
					anchor_min_x = mini(anchor_min_x, x)
					anchor_max_x = maxi(anchor_max_x, x)
	return {
		"path": path,
		"image": image,
		"width": image.get_width(),
		"height": image.get_height(),
		"min_x": min_x,
		"max_x": max_x,
		"min_y": min_y,
		"max_y": max_y,
		"anchor_x": (anchor_min_x + anchor_max_x) / 2.0 if anchor_max_x >= 0 else (min_x + max_x) / 2.0
	}

func _feasible_range(frames: Array[Dictionary], anchor_key: String, min_key: String, max_key: String, size: int) -> Vector2:
	var lower := -INF
	var upper := INF
	for frame in frames:
		var anchor: float = frame[anchor_key]
		lower = maxf(lower, anchor - float(frame[min_key]))
		upper = minf(upper, anchor + float(size - 1 - frame[max_key]))
	return Vector2(lower, upper)

func _median_float(frames: Array[Dictionary], key: String) -> float:
	var values: Array[float] = []
	for frame in frames:
		values.append(float(frame[key]))
	values.sort()
	return values[values.size() / 2] if values.size() % 2 == 1 else (values[values.size() / 2 - 1] + values[values.size() / 2]) / 2.0

func _backup_path(source_path: String) -> String:
	var relative := source_path.trim_prefix(SOURCE_ROOT + "/")
	return "%s/%s" % [BACKUP_ROOT, relative]

func _rebuild_sheets() -> void:
	_rebuild_sheet("res://01_ASSETS/kataklysma/sprites/sheets/kataklysma_sheet_idle_walk.png", ["res://01_ASSETS/kataklysma/sprites/idle", "res://01_ASSETS/kataklysma/sprites/walk"])
	_rebuild_sheet("res://01_ASSETS/kataklysma/sprites/sheets/kataklysma_sheet_cast_combat.png", ["res://01_ASSETS/kataklysma/sprites/cast", "res://01_ASSETS/kataklysma/sprites/combat"])
	for attribute in ["agility_max", "corruption_max", "intellect_max", "lust_max", "spirit_max", "stamina_max"]:
		var root := "res://01_ASSETS/kataklysma/sprites/attribute_sets/%s" % attribute
		_rebuild_sheet("%s/SHEETS/kataklysma_%s_sheet_all.png" % [root, attribute], ["%s/IDLE" % root, "%s/WALK" % root, "%s/CAST" % root, "%s/COMBAT" % root])
		_rebuild_sheet("%s/SHEETS/kataklysma_%s_sheet_idle_walk.png" % [root, attribute], ["%s/IDLE" % root, "%s/WALK" % root])
		_rebuild_sheet("%s/SHEETS/kataklysma_%s_sheet_cast_combat.png" % [root, attribute], ["%s/CAST" % root, "%s/COMBAT" % root])
	for npc_id in ["korgash", "mokjala", "vexa_geargrin"]:
		var root := "res://01_ASSETS/kataklysma/sprites/npcs/%s" % npc_id
		_rebuild_sheet("%s/SHEETS/npc_%s_sheet_idle_walk.png" % [root, npc_id], ["%s/IDLE" % root, "%s/WALK" % root])

func _rebuild_sheet(sheet_path: String, folders: Array[String]) -> void:
	var first_files := _png_files(folders[0])
	if first_files.size() != 4:
		issues.append("sheet %s: source row does not contain four frames" % sheet_path)
		return
	var first := Image.new()
	if first.load("%s/%s" % [folders[0], first_files[0]]) != OK:
		issues.append("sheet %s: first frame load failed" % sheet_path)
		return
	var width := first.get_width()
	var height := first.get_height()
	var sheet := Image.create(width * 4, height * folders.size(), false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0, 0, 0, 0))
	for row in folders.size():
		var files := _png_files(folders[row])
		if files.size() != 4:
			issues.append("sheet %s: row %d does not contain four frames" % [sheet_path, row])
			return
		for column in 4:
			var image := Image.new()
			if image.load("%s/%s" % [folders[row], files[column]]) != OK:
				issues.append("sheet %s: frame load failed" % sheet_path)
				return
			sheet.blit_rect(image, Rect2i(0, 0, image.get_width(), image.get_height()), Vector2i(column * width, row * height))
	var backup_path := _backup_path(sheet_path)
	if FileAccess.file_exists(sheet_path) and not FileAccess.file_exists(backup_path):
		DirAccess.make_dir_recursive_absolute(backup_path.get_base_dir())
		if DirAccess.copy_absolute(sheet_path, backup_path) == OK:
			backup_files += 1
	if sheet.save_png(sheet_path) != OK:
		issues.append("sheet %s: write failed" % sheet_path)

func _png_files(folder: String) -> Array[String]:
	var files: Array[String] = []
	for file_name in DirAccess.get_files_at(folder):
		if file_name.to_lower().ends_with(".png"):
			files.append(file_name)
	files.sort()
	return files
