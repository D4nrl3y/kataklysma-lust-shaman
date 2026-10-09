extends SceneTree

var failures: Array[String] = []
var checks := 0
var test_save_path := ""
var test_settings_path := ""
var demo: Variant

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var nonce := str(Time.get_ticks_usec())
	test_save_path = "user://phase1_acceptance_%s.json" % nonce
	test_settings_path = "user://phase1_options_%s.cfg" % nonce
	var packed_scene: PackedScene = load("res://03_GODOT/scenes/main.tscn")
	_check(packed_scene != null, "main scene resource")
	if packed_scene == null:
		_finish()
		return
	demo = packed_scene.instantiate()
	demo.save_path_override = test_save_path
	demo.options_settings_path_override = test_settings_path
	root.add_child(demo)
	await process_frame
	demo.audio_manager.enabled = false
	demo.audio_manager.stop_ambience()
	demo.set_process(false)

	_check(demo.quest_dialogue_data.get("status", "") == "runtime_source_for_noncanonical_prototype", "runtime PT-BR quest data loaded")
	_check(demo.quest_runtime.ordered_states.size() == 4, "quest state sequence loaded from data")
	_check(demo.quest_runtime.quest_id == "prototype_echo_isles_tide_v001", "prototype stays unmapped to canon")
	_check(demo.WALKABLE_POLYGONS.size() >= 12, "walkable polygons loaded from zone data")
	_check(demo.WALKABILITY_BLOCK_POLYGONS.size() == demo.WALKABILITY_BLOCK_IDS.size(), "all blockers have names and collision geometry")
	_check(is_equal_approx(demo.player.scale.x, 0.22) and is_equal_approx(demo.npc.scale.x, 0.22), "player and Zek'Ranu share calibrated scale")
	_check(demo.player_collision_body.get_node("PlayerFootCollider").shape.size == Vector2(20, 12), "foot collision matches calibration")
	_check(demo.player_collision_body.get_node("PlayerFootCollider").position == Vector2(0, 40), "foot collision pivot matches sprite")
	_check(demo.camera.zoom == Vector2(1.18, 1.18), "camera zoom from calibration")
	_check(demo.walkability_debug.visible == false, "walkability overlay is off by default")
	var f10_event := InputEventKey.new()
	f10_event.pressed = true
	f10_event.keycode = KEY_F10
	f10_event.physical_keycode = KEY_F10
	demo._unhandled_input(f10_event)
	_check(demo.walkability_debug.visible, "F10 key toggles debug overlay on")
	demo._unhandled_input(f10_event)
	_check(not demo.walkability_debug.visible, "F10 key toggles debug overlay off")
	_check(demo._is_walkable_position(demo.OBJECTIVE_POSITION), "quest investigation marker stands on walkable sand")
	_check_visual_sand(demo, demo.OBJECTIVE_POSITION, "quest investigation point")
	_check_visual_sand(demo, Vector2(1488.0, 464.0), "east bridge landing")
	var menu_buttons: Array = demo.menu_layer.find_children("*", "Button", true, false)
	_check(menu_buttons.size() == 5, "main menu exposes the five expected actions")
	for button_node in menu_buttons:
		var menu_button := button_node as Button
		_check(menu_button.focus_mode == Control.FOCUS_ALL, "main menu keyboard focus: %s" % menu_button.text)
		if not menu_button.disabled:
			menu_button.grab_focus()
			_check(demo.get_viewport().gui_get_focus_owner() == menu_button, "main menu button receives focus: %s" % menu_button.text)

	var blocked_positions := [
		["oceano oeste", Vector2(150, 720)], ["oceano sul", Vector2(760, 820)],
		["oceano leste", Vector2(1600, 500)], ["waterfall rock", Vector2(175, 320)],
		["cliff arena", Vector2(700, 130)], ["rochas centrais", Vector2(575, 380)],
		["vegetacao norte", Vector2(730, 110)], ["ilha rochosa", Vector2(900, 750)],
		["borda inacessivel do altar", Vector2(1050, 25)], ["canto fora do mapa", Vector2(20, 450)],
	]
	for item in blocked_positions:
		_check(not demo._is_walkable_position(item[1]), "walkability block: %s" % item[0])
	for index in demo.WALKABILITY_BLOCK_POLYGONS.size():
		var polygon: PackedVector2Array = demo.WALKABILITY_BLOCK_POLYGONS[index]
		var center := Vector2.ZERO
		for point in polygon:
			center += point
		center /= float(polygon.size())
		_check(not demo._is_walkable_position(center - Vector2(0, 48)), "solid polygon footprint: %s" % demo.WALKABILITY_BLOCK_IDS[index])
		_check(demo.get_node_or_null("WalkabilityBlocker_%s" % demo.WALKABILITY_BLOCK_IDS[index]) != null, "physical CollisionPolygon2D: %s" % demo.WALKABILITY_BLOCK_IDS[index])

	_check_reachable(Vector2(240, 178), "trilha cabana-arena")
	_check_reachable(demo.NPC_POSITION - Vector2(72.0, 0.0), "caminho de interacao ate Zek'Ranu")
	_check_reachable(Vector2(1080, 112), "trilha ate o altar")
	_check_reachable(Vector2(1370, 202), "trilha da gruta", true)
	_check_reachable(Vector2(1320, 330), "ponte leste")
	_check_reachable(demo.OBJECTIVE_POSITION, "escadas e praia sul")
	_check(demo._is_walkable_position(Vector2(1488, 464)), "east bridge exit is on walkable sand")
	_check_reachable(Vector2(1488, 464), "ponte ate a areia leste")

	var continue_control: Button = demo.continue_button
	_check(continue_control.disabled, "CONTINUAR disabled without a save")
	_check(continue_control.focus_mode == Control.FOCUS_ALL, "menu button supports keyboard focus")
	demo._start_new_game()
	demo.audio_manager.stop_ambience()
	demo.set_process(false)
	demo._save_game()
	_check(not continue_control.disabled, "CONTINUAR enabled after save")
	demo._return_to_menu()
	_check(not continue_control.disabled, "CONTINUAR remains enabled on return to menu")

	await _test_options()
	await _test_audio()
	_test_encounter_routing()
	_test_npc_route()
	_test_quest_flow()
	_test_save_load()
	_test_scale_ratio()
	await _finish()

func _test_options() -> void:
	var menu: Variant = demo.options_menu
	menu.open_menu()
	await process_frame
	var focus_owner: Control = menu.get_viewport().gui_get_focus_owner()
	_check(focus_owner != null and menu.is_ancestor_of(focus_owner), "options keyboard focus enters the panel")
	_check(menu._volume_sliders.size() == 3 and menu._resolution_select.item_count == 3, "all audio and resolution controls exist")
	_check(menu.key_buttons.size() == 6, "all six actions can be remapped")
	for action in menu.key_buttons:
		_check((menu.key_buttons[action] as Control).focus_mode != Control.FOCUS_NONE, "keyboard focus enabled: %s" % action)
	(menu._volume_sliders["master_volume"] as HSlider).value = 0.47
	(menu._volume_sliders["music_volume"] as HSlider).value = 0.35
	(menu._volume_sliders["sfx_volume"] as HSlider).value = 0.72
	menu._resolution_select.item_selected.emit(1)
	menu._fullscreen_toggle.button_pressed = true
	menu._minimap_toggle.button_pressed = false
	menu._camera_toggle.button_pressed = false
	menu._apply_settings()
	_check(is_equal_approx(float(menu.settings["master_volume"]), 0.47), "master volume slider applies")
	_check(is_equal_approx(float(menu.settings["music_volume"]), 0.35), "music volume slider applies")
	_check(is_equal_approx(float(menu.settings["sfx_volume"]), 0.72), "SFX volume slider applies")
	_check(int(menu.settings["resolution_index"]) == 1 and bool(menu.settings["fullscreen"]), "resolution and fullscreen selections apply")
	_check(not demo.minimap_panel.visible and not demo.camera.position_smoothing_enabled, "minimap and camera options apply")
	_check(is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")), linear_to_db(0.47)), "master bus volume set")
	_check(is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")), linear_to_db(0.35)), "music bus volume set")
	_check(is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")), linear_to_db(0.72)), "SFX bus volume set")
	if DisplayServer.get_name() != "headless":
		menu.settings["fullscreen"] = false
		menu.settings["resolution_index"] = 1
		menu._apply_settings(false)
		await process_frame
		_check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED, "windowed mode readback before resolution change")
		_check(DisplayServer.window_get_size() == Vector2i(1600, 900), "1600×900 resolution readback")
		menu.settings["fullscreen"] = true
		menu._apply_settings(false)
		await process_frame
		_check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN, "fullscreen window mode readback")
		await process_frame
		menu.settings["fullscreen"] = false
		menu.settings["resolution_index"] = 0
		menu._apply_settings(false)
		await process_frame
		_check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED, "windowed mode readback")
		_check(DisplayServer.window_get_size() == Vector2i(1280, 720), "window resolution readback")
	menu._begin_key_capture(&"move_left")
	var remap_event := InputEventKey.new()
	remap_event.pressed = true
	remap_event.keycode = KEY_J
	remap_event.physical_keycode = KEY_J
	menu.handle_key_event(remap_event)
	_check(int(menu.key_values[&"move_left"]) == KEY_J, "key remapping updates the selected action")
	_check(InputMap.event_is_action(remap_event, &"move_left"), "remapped action is active in InputMap")
	_check(InputMap.action_get_events(&"move_left").size() == 2, "arrow-key alternate remains available")
	menu._begin_key_capture(&"interact")
	menu.handle_key_event(remap_event)
	_check(int(menu.key_values[&"interact"]) != KEY_J, "duplicate binding is rejected")
	var cancel_event := InputEventKey.new()
	cancel_event.pressed = true
	cancel_event.keycode = KEY_ESCAPE
	cancel_event.physical_keycode = KEY_ESCAPE
	menu.handle_key_event(cancel_event)
	menu._apply_settings()
	var saved_config := ConfigFile.new()
	_check(saved_config.load(test_settings_path) == OK, "settings config persisted")
	_check(int(saved_config.get_value("controls", "move_left", -1)) == KEY_J, "remapping persisted")
	_check(is_equal_approx(float(saved_config.get_value("settings", "music_volume", 0.0)), 0.35), "audio settings persisted")
	var old_volume: float = float(menu.settings["music_volume"])
	menu.settings["music_volume"] = 0.01
	menu._load_settings()
	_check(is_equal_approx(float(menu.settings["music_volume"]), old_volume), "settings reload restores saved value")
	menu.visible = false
	menu._apply_settings(false)

func _test_audio() -> void:
	var manager: Variant = demo.audio_manager
	_check(manager.music_player != null and manager.music_player.bus == "Music", "Echo Isles music stream is integrated on the Music bus")
	manager.start_ambience()
	await process_frame
	_check(manager.music_player.playing, "gameplay ambience starts")
	manager.stop_ambience()
	_check(not manager.music_player.playing, "ambience stops when returning to menu")
	manager.enabled = true
	if DisplayServer.get_name() == "headless":
		_check(AudioServer.get_bus_index("SFX") >= 0, "SFX output bus is configured (headless audio output is disabled)")
		manager.enabled = false
		return
	manager.play_ui("quest_accept")
	var generated_sfx: AudioStreamPlayer
	for child in manager.get_children():
		if child is AudioStreamPlayer and child.stream is AudioStreamGenerator:
			generated_sfx = child as AudioStreamPlayer
			break
	_check(generated_sfx != null and generated_sfx.playing and generated_sfx.bus == "SFX", "procedural UI fallback routes to the SFX bus")
	manager.enabled = false
	manager.stop_ambience()

func _test_encounter_routing() -> void:
	var manager: Variant = demo.encounter_manager
	var valid_foot_position := Vector2(450, 398)
	_check(manager.is_spawn_position("echo_isles_day", valid_foot_position), "Echo Isles encounter spawn region")
	_check(not manager.is_spawn_position("echo_isles_day", Vector2(150, 720)), "water excluded from encounter spawn regions")
	var senjin_only_position := Vector2(950.0, 300.0)
	_check(manager.is_spawn_position("senjin_village_day", senjin_only_position), "Sen’jin event table recognizes its own plaza")
	_check(not manager.is_spawn_position("echo_isles_day", senjin_only_position), "Echo Isles table rejects the Sen’jin plaza")
	_check(not manager.is_spawn_position("senjin_village_day", Vector2(600.0, 580.0)), "Sen’jin event table rejects the Echo Isles beach")
	manager._steps_since_event = manager.minimum_steps_between_events
	manager._cooldown_left = 0.0
	manager._rng.seed = 71204
	var triggered: Array = []
	manager.encounter_triggered.connect(func(table_id: String, event: Dictionary) -> void: triggered.append([table_id, event]))
	_check(not manager.try_roll("echo_isles_day", valid_foot_position, true), "blocked state suppresses random encounter")
	_check(manager.try_roll("echo_isles_day", valid_foot_position), "Echo Isles table dispatches only in its allowed region")
	_check(triggered.size() == 1 and triggered[0][1].zone_id == "echo_isles", "event includes validated zone identity")
	var before_combat: bool = demo.encounter_active
	demo.player.position = Vector2(450, 350)
	demo._handle_noncombat_encounter({"type":"npc_walkby", "actors":["zalkiri"]})
	_check(is_instance_valid(demo.random_event_npc), "NPC walk-by spawns an integrated sprite")
	_check(not demo.encounter_active and before_combat == demo.encounter_active, "NPC walk-by never opens combat")
	demo._handle_noncombat_encounter({"type":"resource_find", "actors":["herb_patch"]})
	_check(not demo.random_resource_data.is_empty() and demo.random_resource_marker.visible, "resource event creates a collectable POI")
	demo._try_interact()
	_check(demo.resources_collected == 1 and demo.random_resource_data.is_empty(), "resource POI can be collected")
	var spirit_before := int(demo.attributes["spirit"])
	demo._handle_noncombat_encounter({"type":"spirit_omen", "actors":["spirit_elemental"]})
	_check(int(demo.attributes["spirit"]) == mini(100, spirit_before + 1), "spirit omen has a bounded gameplay effect")
	_check(not demo.encounter_active, "non-combat handlers do not start battle")
	demo.random_event_npc.queue_free()
	demo.random_event_npc = null

func _test_npc_route() -> void:
	demo.player.position = demo.PLAYER_START
	demo.npc.position = demo.NPC_POSITION
	demo.npc_routine_wait = 0.0
	var start_index: int = demo.npc_routine_index
	var visited := false
	var last_position: Vector2 = demo.npc.position
	for tick in 400:
		demo._update_npc_routine(0.05)
		demo._sync_npc_anchors()
		if demo.npc.position != last_position:
			visited = true
			_check(demo._is_walkable_position(demo.npc.position), "Zek'Ranu route stays on walkable ground")
			last_position = demo.npc.position
	_check(visited, "Zek'Ranu routine advances during exploration")
	_check(demo.npc_routine_index != start_index, "Zek'Ranu reaches a route waypoint")
	_check(demo.npc_interaction_area.position == demo.npc.position, "NPC interaction anchor follows route")
	_check(demo.npc_collision_body.position == demo.npc.position + Vector2(0, 30), "NPC blocker follows route")

func _test_quest_flow() -> void:
	var active_npc_position: Vector2 = demo.npc.position
	demo.player.position = active_npc_position + Vector2(110.0, 0.0)
	demo._try_interact()
	_check(not demo.dialogue_panel.visible, "NPC interaction is ignored outside the calibrated range")
	demo.player.position = active_npc_position - Vector2(72.0, 0.0)
	demo._try_interact()
	_check(demo.dialogue_panel.visible, "NPC interaction works inside the calibrated range")
	_check(demo.dialogue_body.text == demo.quest_dialogue_data["npc_intro"], "intro dialogue comes from pt_BR data")
	_check(demo.dialogue_choices.text.split("\n").size() == 5, "five localized vertical choices render")
	var spirit_before := int(demo.attributes["spirit"])
	demo._apply_dialogue_choice(1)
	_check(int(demo.attributes["spirit"]) == spirit_before + 2, "choice changes selected attribute")
	demo._confirm_dialogue()
	_check(demo.quest_state == "in_progress", "accept transition updates quest")
	_check(demo.quest_state_label.text.contains("Investigue a maré corrompida"), "quest tracker refreshes objective")
	demo.player.position = demo.OBJECTIVE_POSITION
	demo._try_interact()
	_check(demo.dialogue_panel.visible, "investigation POI opens its dialogue")
	demo._confirm_dialogue()
	_check(demo.quest_state == "complete" and demo.cg_active, "objective completes and launches CG")
	_check(demo.cg_frames.size() == 4 and demo.cg_image.texture != null, "all CG frames load")
	for index in 4:
		demo._process_cg(2.5)
	_check(not demo.cg_active, "CG sequence returns to gameplay")
	demo.player.position = demo.NPC_POSITION
	demo._interact_with_npc()
	demo._confirm_dialogue()
	_check(demo.quest_state == "turned_in", "quest can be turned in")
	_check(not demo.minimap_quest_dot.visible, "quest marker clears after turn-in")
	_check(not demo.quest_runtime.transition("available"), "quest runtime rejects invalid reverse transition")

func _test_save_load() -> void:
	demo.player.position = demo.NPC_POSITION
	demo._save_game()
	var stored_position: Vector2 = demo.player.position
	var stored_quest: String = demo.quest_state
	var stored_spirit := int(demo.attributes["spirit"])
	var stored_resources: int = demo.resources_collected
	demo.player.position = demo.PLAYER_START
	demo.quest_runtime.reset()
	demo.attributes["spirit"] = 0
	demo.resources_collected = 0
	demo._load_game()
	_check(demo.player.position == stored_position, "save/load restores player position")
	_check(demo.quest_state == stored_quest, "save/load restores quest state")
	_check(int(demo.attributes["spirit"]) == stored_spirit, "save/load restores attributes")
	_check(demo.resources_collected == stored_resources, "save/load restores random event rewards")

func _test_scale_ratio() -> void:
	var texture: Texture2D = demo.player.sprite_frames.get_frame_texture("idle_front", 0)
	var image := texture.get_image()
	image.convert(Image.FORMAT_RGBA8)
	var bounds := Rect2i(image.get_size(), Vector2i.ZERO)
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a > 0.05:
				bounds.position.x = mini(bounds.position.x, x)
				bounds.position.y = mini(bounds.position.y, y)
				bounds.end.x = maxi(bounds.end.x, x + 1)
				bounds.end.y = maxi(bounds.end.y, y + 1)
	var sprite_width: float = float(bounds.size.x) * demo.player.scale.x
	var road_width := 95.0
	var ratio := road_width / maxf(1.0, sprite_width)
	var foot_offset_y: float = (float(bounds.position.y + bounds.size.y) - float(image.get_height()) * 0.5) * demo.player.scale.y
	print("SCALE_METRIC | frame=%s | alpha_bounds=%s | sprite_width=%0.2f world_px | sprite_foot_offset=%0.2f world_px | road_width=%0.2f world_px | ratio=%0.2f:1" % [image.get_size(), bounds, sprite_width, foot_offset_y, road_width, ratio])
	_check(ratio >= 2.5 and ratio <= 3.5, "road width is close to 2.5-3 character widths")

func _check_route(points: Array, label: String) -> void:
	var foot_offset: Array = demo.CALIBRATION.get("player_foot_offset", [0, 48])
	for segment in range(points.size() - 1):
		var start := Vector2(points[segment][0], points[segment][1])
		var finish := Vector2(points[segment + 1][0], points[segment + 1][1])
		var count := maxi(1, int(ceil(start.distance_to(finish) / 4.0)))
		for step in count + 1:
			var pivot := start.lerp(finish, float(step) / float(count))
			var feet := pivot + Vector2(float(foot_offset[0]), float(foot_offset[1]))
			_check(demo._is_walkable_position(pivot), "walk route %s at %s" % [label, feet])

func _check_visual_sand(target_demo: Variant, actor_position: Vector2, label: String) -> void:
	var texture := load(target_demo.MAP_TEXTURE) as Texture2D
	if texture == null:
		_check(false, "%s background texture can be sampled" % label)
		return
	var image := texture.get_image()
	var foot_offset: Array = target_demo.CALIBRATION.get("player_foot_offset", [0.0, 40.0])
	var foot_point := actor_position + Vector2(float(foot_offset[0]), float(foot_offset[1]))
	var sand_pixels := 0
	for y in range(roundi(foot_point.y) - 6, roundi(foot_point.y) + 7):
		for x in range(roundi(foot_point.x) - 10, roundi(foot_point.x) + 11):
			var color := image.get_pixel(x, y)
			if color.r > color.g * 1.08 and color.g > color.b * 1.05 and color.r > 55.0 / 255.0:
				sand_pixels += 1
	print("VISUAL_GROUND_SAMPLE | %s | sand_pixels=%d/273" % [label, sand_pixels])
	_check(sand_pixels >= 70, "%s stands on visible beach sand (not the cliff/rocks/water)" % label)

func _check_reachable(target: Vector2, label: String, advance_npc_during_traversal := false) -> void:
	const GRID_STEP := 8.0
	var start_cell := Vector2i(roundi(demo.PLAYER_START.x / GRID_STEP), roundi(demo.PLAYER_START.y / GRID_STEP))
	var goal_cell := Vector2i(roundi(target.x / GRID_STEP), roundi(target.y / GRID_STEP))
	var queue: Array[Vector2i] = [start_cell]
	var visited := {start_cell: true}
	var parents: Dictionary = {}
	var directions := [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),Vector2i(1,1),Vector2i(1,-1),Vector2i(-1,1),Vector2i(-1,-1)]
	var reached := false
	var reached_cell := start_cell
	var min_x := start_cell.x
	var max_x := start_cell.x
	var min_y := start_cell.y
	var max_y := start_cell.y
	var nearest_position := Vector2.ZERO
	var nearest_distance := INF
	var head := 0
	while head < queue.size():
		var cell := queue[head]
		head += 1
		var current := Vector2(cell) * GRID_STEP
		min_x = mini(min_x, cell.x)
		max_x = maxi(max_x, cell.x)
		min_y = mini(min_y, cell.y)
		max_y = maxi(max_y, cell.y)
		if current.distance_to(target) < nearest_distance:
			nearest_distance = current.distance_to(target)
			nearest_position = current
		if current.distance_to(target) <= GRID_STEP * 1.5:
			reached = true
			reached_cell = cell
			break
		for direction in directions:
			var next_cell: Vector2i = cell + direction
			if visited.has(next_cell):
				continue
			var next_position := Vector2(next_cell) * GRID_STEP
			if not demo._is_walkable_position(next_position):
				continue
			if direction.x != 0 and direction.y != 0:
				if not demo._is_walkable_position(current + Vector2(direction.x * GRID_STEP, 0)) or not demo._is_walkable_position(current + Vector2(0, direction.y * GRID_STEP)):
					continue
			visited[next_cell] = true
			parents[next_cell] = cell
			queue.append(next_cell)
	if not reached:
		print("REACHABILITY_TRACE | %s | bounds=(%d,%d)-(%d,%d) | nearest=%s distance=%0.1f" % [label, min_x * int(GRID_STEP), min_y * int(GRID_STEP), max_x * int(GRID_STEP), max_y * int(GRID_STEP), nearest_position, nearest_distance])
	_check(reached, "continuous path exists from spawn to %s (visited %d cells)" % [label, visited.size()])
	if reached:
		var route: Array[Vector2i] = [reached_cell]
		var cursor := reached_cell
		while cursor != start_cell and parents.has(cursor):
			cursor = parents[cursor]
			route.append(cursor)
		route.reverse()
		var old_body_position: Vector2 = demo.player_collision_body.position
		var old_player_position: Vector2 = demo.player.position
		var npc_start_index: int = demo.npc_routine_index
		var npc_stayed_walkable := true
		demo.player_collision_body.position = Vector2(route[0]) * GRID_STEP
		var collision_free := true
		for route_index in range(1, route.size()):
			var destination := Vector2(route[route_index]) * GRID_STEP
			var collision: KinematicCollision2D = demo.player_collision_body.move_and_collide(destination - demo.player_collision_body.position)
			if collision != null:
				collision_free = false
				print("PHYSICS_ROUTE_COLLISION | %s | position=%s | collider=%s" % [label, demo.player_collision_body.position, collision.get_collider()])
				break
			if advance_npc_during_traversal:
				demo.player.position = demo.player_collision_body.position
				demo._update_npc_routine(GRID_STEP / demo.MOVE_SPEED)
				demo._sync_npc_anchors()
				npc_stayed_walkable = npc_stayed_walkable and demo._is_walkable_position(demo.npc.position)
		demo.player_collision_body.position = old_body_position
		demo.player.position = old_player_position
		_check(collision_free, "physical CharacterBody2D traversal reaches %s (%d steps)" % [label, route.size() - 1])
		if advance_npc_during_traversal:
			_check(demo.npc_routine_index != npc_start_index, "Zek'Ranu routine advances during physical player traversal")
			_check(npc_stayed_walkable, "Zek'Ranu stays on whitelist during player traversal")
			_check(demo.npc_collision_body.position == demo.npc.position + Vector2(0, 30), "NPC collision anchor remains synced during player traversal")

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)

func _finish() -> void:
	if demo and is_instance_valid(demo):
		demo.audio_manager.stop_ambience()
		demo.queue_free()
	if test_save_path != "":
		var absolute_save := ProjectSettings.globalize_path(test_save_path)
		if FileAccess.file_exists(absolute_save):
			DirAccess.remove_absolute(absolute_save)
	if test_settings_path != "":
		var absolute_settings := ProjectSettings.globalize_path(test_settings_path)
		if FileAccess.file_exists(absolute_settings):
			DirAccess.remove_absolute(absolute_settings)
	await process_frame
	await create_timer(0.2).timeout
	if failures.is_empty():
		print("PHASE1_ACCEPTANCE_TEST: PASS (%d checks)" % checks)
		quit(0)
	else:
		push_error("PHASE1_ACCEPTANCE_TEST: FAIL (%d/%d): %s" % [failures.size(), checks, " | ".join(failures)])
		quit(1)
