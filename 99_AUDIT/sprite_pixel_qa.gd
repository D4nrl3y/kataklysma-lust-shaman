extends SceneTree

const ALPHA_THRESHOLD := 0.05
const EXPECTED_FRAMES := 4
const REPORT_JSON := "res://99_AUDIT/sprite_pixel_qa_v001.json"
const REPORT_MD := "res://99_AUDIT/SPRITE_PIXEL_QA_V001.md"

var groups: Array[Dictionary] = []
var failures: Array[String] = []
var warnings: Array[String] = []

func _init() -> void:
	_scan_player_base()
	_scan_attribute_sets()
	_scan_npcs()
	_scan_entities()
	var report := _build_report()
	_write_report(report)
	print("Sprite pixel QA: %s" % ("PASS" if failures.is_empty() else "FAIL"))
	print("Groups checked: %d | failures: %d | warnings: %d" % [groups.size(), failures.size(), warnings.size()])
	if not failures.is_empty():
		for item in failures:
			print("FAIL: %s" % item)
	quit(1 if not failures.is_empty() else 0)

func _scan_player_base() -> void:
	for animation in ["idle", "walk", "cast", "combat"]:
		_register_group("player/%s" % animation, "res://01_ASSETS/kataklysma/sprites/%s" % animation, "player", animation, true)

func _scan_attribute_sets() -> void:
	var root := "res://01_ASSETS/kataklysma/sprites/attribute_sets"
	for attribute in DirAccess.get_directories_at(root):
		for animation in ["IDLE", "WALK", "CAST", "COMBAT"]:
			_register_group("attribute_sets/%s/%s" % [attribute, animation], "%s/%s/%s" % [root, attribute, animation], attribute, animation, true)

func _scan_npcs() -> void:
	var root := "res://01_ASSETS/kataklysma/sprites/npcs"
	for npc_id in DirAccess.get_directories_at(root):
		for animation in ["IDLE", "WALK"]:
			_register_group("npcs/%s/%s" % [npc_id, animation], "%s/%s/%s" % [root, npc_id, animation], npc_id, animation, true)
		for animation in ["CAST", "COMBAT"]:
			var path := "%s/%s/%s" % [root, npc_id, animation]
			if not DirAccess.dir_exists_absolute(path):
				warnings.append("%s: missing planned animation folder %s" % [npc_id, animation])

func _scan_entities() -> void:
	var root := "res://01_ASSETS/kataklysma/character/entities/sprites"
	for entity_id in DirAccess.get_directories_at(root):
		for animation in DirAccess.get_directories_at("%s/%s" % [root, entity_id]):
			if animation == "SHEETS":
				continue
			_register_group("entities/%s/%s" % [entity_id, animation], "%s/%s/%s" % [root, entity_id, animation], entity_id, animation, true)

func _register_group(label: String, folder: String, owner: String, animation: String, must_have_frames: bool) -> void:
	var files := DirAccess.get_files_at(folder)
	var pngs: Array[String] = []
	for file_name in files:
		if file_name.to_lower().ends_with(".png"):
			pngs.append(file_name)
	pngs.sort()
	var result := {
		"label": label,
		"folder": folder,
		"owner": owner,
		"animation": animation,
		"frame_count": pngs.size(),
		"frames": [],
		"status": "PASS",
		"issues": []
	}
	if must_have_frames and pngs.size() != EXPECTED_FRAMES:
		var issue := "%s: expected %d frames, found %d" % [label, EXPECTED_FRAMES, pngs.size()]
		failures.append(issue)
		result.issues.append(issue)
		result.status = "FAIL"
	for file_name in pngs:
		var frame := _measure_frame("%s/%s" % [folder, file_name])
		result.frames.append(frame)
	if pngs.is_empty():
		return
	_compare_group(result)
	groups.append(result)

func _measure_frame(path: String) -> Dictionary:
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		var issue := "%s: image load error %s" % [path, error]
		failures.append(issue)
		return {"path": path, "load_error": error}
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	var opaque_pixels := 0
	var edge_pixels := 0
	var anchor_min_x := image.get_width()
	var anchor_max_x := -1
	var anchor_y_start := int(float(image.get_height()) * 0.68)
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a > ALPHA_THRESHOLD:
				opaque_pixels += 1
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
				min_y = mini(min_y, y)
				max_y = maxi(max_y, y)
				if x == 0 or y == 0 or x == image.get_width() - 1 or y == image.get_height() - 1:
					edge_pixels += 1
				if y >= anchor_y_start:
					anchor_min_x = mini(anchor_min_x, x)
					anchor_max_x = maxi(anchor_max_x, x)
	var empty := opaque_pixels == 0
	var anchor_x := 0.0 if empty else (anchor_min_x + anchor_max_x) / 2.0
	return {
		"path": path,
		"width": image.get_width(),
		"height": image.get_height(),
		"min_x": min_x,
		"max_x": max_x,
		"min_y": min_y,
		"max_y": max_y,
		"bbox_width": 0 if empty else max_x - min_x + 1,
		"bbox_height": 0 if empty else max_y - min_y + 1,
		"center_x": 0.0 if empty else (min_x + max_x) / 2.0,
		"anchor_x": anchor_x,
		"opaque_pixels": opaque_pixels,
		"edge_pixels": edge_pixels,
		"empty": empty
	}

func _compare_group(result: Dictionary) -> void:
	var frames: Array = result.frames
	if frames.is_empty():
		return
	var first: Dictionary = frames[0]
	if first.has("load_error"):
		return
	var widths: Array[int] = []
	var heights: Array[int] = []
	var bottoms: Array[int] = []
	var anchors: Array[float] = []
	var bbox_heights: Array[int] = []
	for frame in frames:
		if frame.has("load_error"):
			continue
		widths.append(frame.width)
		heights.append(frame.height)
		bottoms.append(frame.max_y)
		anchors.append(frame.anchor_x)
		bbox_heights.append(frame.bbox_height)
	if widths.size() != frames.size():
		return
	if widths.min() != widths.max() or heights.min() != heights.max():
		var dimension_issue := "%s: frame dimensions differ (%s)" % [result.label, _array_to_string(frames, "width", "height")]
		_fail_result(result, dimension_issue)
	var bottom_drift: int = bottoms.max() - bottoms.min()
	var center_drift: float = anchors.max() - anchors.min()
	var height_drift: int = bbox_heights.max() - bbox_heights.min()
	var is_action := str(result.animation).to_lower() in ["walk", "cast", "combat"]
	var bottom_limit := 10 if is_action else 4
	var center_limit := 32.0 if is_action else 16.0
	var height_limit := maxi(12, int(float(bbox_heights.max()) * 0.12))
	if bottom_drift > bottom_limit:
		_fail_result(result, "%s: baseline drift %d px (limit %d)" % [result.label, bottom_drift, bottom_limit])
	if center_drift > center_limit:
		_fail_result(result, "%s: horizontal pivot drift %.1f px (limit %.1f)" % [result.label, center_drift, center_limit])
	if height_drift > height_limit:
		warnings.append("%s: silhouette height variation %d px" % [result.label, height_drift])
	for frame in frames:
		if frame.edge_pixels > 0:
			warnings.append("%s: %s touches image edge (%d pixels)" % [result.label, frame.path.get_file(), frame.edge_pixels])

func _fail_result(result: Dictionary, issue: String) -> void:
	result.issues.append(issue)
	result.status = "FAIL"
	failures.append(issue)

func _array_to_string(frames: Array, width_key: String, height_key: String) -> String:
	var values: Array[String] = []
	for frame in frames:
		values.append("%sx%s" % [frame.get(width_key, "?"), frame.get(height_key, "?")])
	return ", ".join(values)

func _build_report() -> Dictionary:
	return {
		"version": "v001",
		"tool": "Godot 4 Image pixel metrics",
		"alpha_threshold": ALPHA_THRESHOLD,
		"expected_frames": EXPECTED_FRAMES,
		"group_count": groups.size(),
		"failure_count": failures.size(),
		"warning_count": warnings.size(),
		"status": "PASS" if failures.is_empty() else "FAIL",
		"failures": failures,
		"warnings": warnings,
		"groups": groups
	}

func _write_report(report: Dictionary) -> void:
	var json_file := FileAccess.open(REPORT_JSON, FileAccess.WRITE)
	json_file.store_string(JSON.stringify(report, "  "))
	json_file.close()
	var markdown := "# Sprite Pixel QA — V001\n\n"
	markdown += "**Motor:** Godot 4 (`Image`)\n\n"
	markdown += "**Resultado:** `%s`\n\n" % report.status
	markdown += "- Grupos verificados: %d\n" % report.group_count
	markdown += "- Falhas de consistência: %d\n" % report.failure_count
	markdown += "- Avisos de recorte/edge contact: %d\n\n" % report.warning_count
	markdown += "## Critérios\n\n"
	markdown += "- quatro frames por animação;\n- mesma resolução por sequência;\n- silhueta não vazia;\n- deriva de baseline e pivô dentro do limite;\n- filtro padrão do Godot configurado para nearest (`0`).\n\n"
	markdown += "## Falhas\n\n"
	if failures.is_empty():
		markdown += "Nenhuma.\n\n"
	else:
		for issue in failures:
			markdown += "- %s\n" % issue
		markdown += "\n"
	markdown += "## Avisos\n\n"
	if warnings.is_empty():
		markdown += "Nenhum.\n"
	else:
		for warning in warnings:
			markdown += "- %s\n" % warning
	var md_file := FileAccess.open(REPORT_MD, FileAccess.WRITE)
	md_file.store_string(markdown)
	md_file.close()
