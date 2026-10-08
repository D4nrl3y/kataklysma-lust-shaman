extends SceneTree

const OUTPUT_DIR := "res://docs/qa/screenshots"
var capture_failures: Array[String] = []

func _init() -> void:
	call_deferred("_capture_all")

func _capture_all() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var demo = load("res://03_GODOT/scenes/main.tscn").instantiate()
	root.add_child(demo)
	await process_frame
	demo.audio_manager.enabled = false
	demo.camera.position_smoothing_enabled = false
	await _save_frame("01_menu_final.png")

	demo._start_new_game()
	# Freeze the game controller so its idle-front fallback cannot overwrite
	# the explicit direction/frame selected for the sprite evidence.
	demo.set_process(false)
	demo.audio_manager.stop_ambience()
	demo._hide_tutorial()
	demo.tutorial_label.visible = false
	demo.toast_label.text = ""
	await _save_frame("18_quest_before_accept.png")

	_place_player(demo, Vector2(330.0, 190.0))
	await _save_frame("02_scale_hut.png")
	_place_player(demo, Vector2(410.0, 390.0))
	await _save_frame("03_scale_training_area.png")
	demo._toggle_walkability_debug()
	demo.toast_label.text = ""
	await _save_frame("04_walkable_debug.png")
	demo._toggle_walkability_debug()
	demo.toast_label.text = ""

	_place_player_at_blocked_edge(demo, Vector2(1000.0, 505.0), Vector2(1000.0, 535.0), "água sul")
	await _save_frame("05_blocked_water.png")
	_place_player_at_blocked_edge(demo, Vector2(580.0, 155.0), Vector2(610.0, 155.0), "cliff arena")
	await _save_frame("06_blocked_cliff.png")
	_place_player_at_blocked_edge(demo, Vector2(510.0, 380.0), Vector2(555.0, 390.0), "pedras centrais")
	await _save_frame("07_blocked_rocks.png")

	_place_player(demo, Vector2(410.0, 390.0))
	var idle_captures := [["back", "08_idle_back.png"], ["left", "09_idle_left.png"], ["right", "10_idle_right.png"]]
	for capture in idle_captures:
		var direction: String = capture[0]
		demo.player.flip_h = false
		demo.player.play("idle_%s" % direction)
		await create_timer(0.15).timeout
		await _save_frame(str(capture[1]))
	var walk_captures := [["back", "11_walk_back.png"], ["left", "12_walk_left.png"], ["right", "13_walk_right.png"]]
	for capture in walk_captures:
		var direction: String = capture[0]
		demo.player.flip_h = false
		demo.player.play("walk_%s" % direction)
		await create_timer(0.15).timeout
		await _save_frame(str(capture[1]))

	_place_player(demo, Vector2(730.0, 315.0))
	demo._show_dialogue("Zek'Ranu  •  Mentor Xamã", "A maré não está certa. Os espíritos evitam a costa.", "close")
	await _save_frame("14_dialogue_zekranu.png")
	demo.dialogue_panel.visible = false
	demo._interact_with_npc()
	await _save_frame("16_dialogue_vertical_choices.png")
	demo._apply_dialogue_choice(1)
	await _save_frame("15_dialogue_kataklysma.png")
	demo._confirm_dialogue()
	demo.toast_label.text = ""
	await _save_frame("19_quest_after_accept.png")

	_place_player(demo, demo.PLAYER_START)
	demo.toast_label.text = ""
	await _save_frame("17_minimap_final.png")
	_place_player(demo, Vector2(900.0, 500.0))
	demo.toast_label.text = ""
	await _save_frame("20_gameplay_final.png")

	_place_player(demo, demo.OBJECTIVE_POSITION)
	demo._interact_with_objective()
	demo._confirm_dialogue()
	await _save_frame("21_cg_sequence.png")
	demo.cg_active = false
	demo.cg_layer.visible = false
	demo.toast_label.text = ""
	demo._start_encounter({"type": "monster_ambush", "actors": ["makrura_corrupted"]})
	await _save_frame("22_turn_combat.png")

	demo.audio_manager.stop_ambience()
	demo.queue_free()
	await process_frame
	await create_timer(0.5).timeout
	if capture_failures.is_empty():
		print("RELEASE_QA_CAPTURE: PASS (22 imagens atuais)")
		quit(0)
	else:
		push_error("RELEASE_QA_CAPTURE: FAIL -> %s" % ", ".join(capture_failures))
		quit(1)

func _place_player(demo, target: Vector2) -> void:
	if not demo._is_walkable_position(target):
		capture_failures.append("posição de screenshot fora da walkability: %s" % target)
	demo.player.position = target
	demo.player_collision_body.position = target
	demo.camera.reset_smoothing()
	demo._update_interaction_feedback()

func _place_player_at_blocked_edge(demo, safe_position: Vector2, blocked_target: Vector2, label: String) -> void:
	if not demo._is_walkable_position(safe_position):
		capture_failures.append("borda segura inválida (%s): %s" % [label, safe_position])
	if demo._is_walkable_position(blocked_target):
		capture_failures.append("alvo de bloqueio ainda está caminhável (%s): %s" % [label, blocked_target])
	if not demo.collision_probe_for_test(safe_position, blocked_target):
		capture_failures.append("tentativa de saída não foi bloqueada (%s)" % label)
	_place_player(demo, safe_position)

func _save_frame(file_name: String) -> void:
	await process_frame
	var viewport_texture: ViewportTexture = root.get_viewport().get_texture()
	if viewport_texture == null:
		capture_failures.append("%s: viewport texture indisponível" % file_name)
		return
	var image: Image = viewport_texture.get_image()
	if image == null or image.is_empty():
		capture_failures.append("%s: renderização sem pixels; execute com display gráfico" % file_name)
		return
	var save_error := image.save_png("%s/%s" % [OUTPUT_DIR, file_name])
	if save_error != OK:
		capture_failures.append("%s: falha ao gravar PNG (%d)" % [file_name, save_error])
