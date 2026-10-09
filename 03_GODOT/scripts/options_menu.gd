extends CanvasLayer

signal settings_changed(settings: Dictionary)
signal closed

const SETTINGS_PATH := "user://kataklysma_settings.cfg"
const DISPLAY_FONT_PATH := "res://01_ASSETS/kataklysma/ui/fonts/cinzel/cinzel_variable.ttf"
const REMAP_ACTIONS := [&"move_left", &"move_right", &"move_up", &"move_down", &"interact", &"pause"]
const ACTION_LABELS := ["Mover para esquerda", "Mover para direita", "Mover para cima", "Mover para baixo", "Interagir / confirmar", "Pausar / voltar ao jogo"]
const DEFAULT_KEYS := [KEY_A, KEY_D, KEY_W, KEY_S, KEY_E, KEY_ESCAPE]
const ACTION_ALTERNATES := {
	&"move_left": [KEY_LEFT],
	&"move_right": [KEY_RIGHT],
	&"move_up": [KEY_UP],
	&"move_down": [KEY_DOWN],
	&"interact": [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER],
	&"pause": [],
}
const RESERVED_KEYS := [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_R, KEY_F, KEY_F10, KEY_M, KEY_S]
const RESOLUTIONS := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]

var settings := {
	"master_volume": 0.85,
	"music_volume": 0.62,
	"sfx_volume": 0.80,
	"fullscreen": false,
	"resolution_index": 0,
	"show_minimap": true,
	"camera_smoothing": true,
}
var capture_action: StringName = &""
var settings_path := SETTINGS_PATH
var key_buttons: Dictionary = {}
var key_values: Dictionary = {}
var _config := ConfigFile.new()
var _status_label: Label
var _resolution_select: OptionButton
var _fullscreen_toggle: CheckButton
var _minimap_toggle: CheckButton
var _camera_toggle: CheckButton
var _volume_sliders: Dictionary = {}

func _ready() -> void:
	layer = 35
	_load_settings()
	_configure_input_actions()
	_build_ui()
	_apply_settings(false)
	visible = false

func open_menu() -> void:
	capture_action = &""
	_sync_controls()
	visible = true
	call_deferred("_focus_first_control")

func _focus_first_control() -> void:
	for control in find_children("*", "Control", true, false):
		var candidate := control as Control
		if candidate.visible and candidate.focus_mode != Control.FOCUS_NONE and not (candidate is BaseButton and (candidate as BaseButton).disabled):
			candidate.grab_focus()
			return

func handle_key_event(event: InputEventKey) -> bool:
	if not visible:
		return false
	if capture_action != &"":
		if event.keycode == KEY_ESCAPE:
			if capture_action == &"pause" and event.pressed:
				_set_binding(capture_action, KEY_ESCAPE)
				_end_key_capture("Tecla de pausa atualizada.")
			else:
				_end_key_capture("Vínculo cancelado.")
			get_viewport().set_input_as_handled()
			return true
		if not event.pressed or event.echo:
			return true
		var code := event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
		if code == KEY_NONE:
			return true
		if _set_binding(capture_action, code):
			_end_key_capture("Tecla atualizada.")
		get_viewport().set_input_as_handled()
		return true
	if event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		visible = false
		closed.emit()
		get_viewport().set_input_as_handled()
		return true
	return false

func _load_settings() -> void:
	_config.load(settings_path)
	for setting_name in settings.keys():
		settings[setting_name] = _config.get_value("settings", setting_name, settings[setting_name])
	for index in REMAP_ACTIONS.size():
		var action: StringName = REMAP_ACTIONS[index]
		key_values[action] = int(_config.get_value("controls", String(action), DEFAULT_KEYS[index]))

func _configure_input_actions() -> void:
	for index in REMAP_ACTIONS.size():
		var action: StringName = REMAP_ACTIONS[index]
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		_set_input_events(action, int(key_values.get(action, DEFAULT_KEYS[index])))

func _set_input_events(action: StringName, primary_key: int) -> void:
	InputMap.action_erase_events(action)
	var primary := InputEventKey.new()
	primary.physical_keycode = primary_key
	InputMap.action_add_event(action, primary)
	for alternate_key in ACTION_ALTERNATES.get(action, []):
		var alternate := InputEventKey.new()
		alternate.physical_keycode = alternate_key
		InputMap.action_add_event(action, alternate)

func _build_ui() -> void:
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.01, 0.01, 0.04, 0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	var panel := ColorRect.new()
	panel.position = Vector2(310.0, 25.0)
	panel.size = Vector2(660.0, 670.0)
	panel.color = Color(0.035, 0.025, 0.08, 0.98)
	shade.add_child(panel)

	var title := _label("OPÇÕES", Vector2(34, 22), Vector2(590, 42), 27, Color("#ffe7a6"))
	title.add_theme_font_override("font", load(DISPLAY_FONT_PATH))
	panel.add_child(title)
	var subtitle := _label("Áudio • vídeo • interface • controles", Vector2(36, 61), Vector2(588, 25), 14, Color("#91d7ff"))
	panel.add_child(subtitle)

	_add_volume_row(panel, "Volume geral", "master_volume", 102)
	_add_volume_row(panel, "Música", "music_volume", 147)
	_add_volume_row(panel, "Efeitos", "sfx_volume", 192)

	_fullscreen_toggle = CheckButton.new()
	_fullscreen_toggle.position = Vector2(34, 235)
	_fullscreen_toggle.text = "Tela cheia"
	_fullscreen_toggle.add_theme_font_size_override("font_size", 15)
	_fullscreen_toggle.toggled.connect(func(value: bool) -> void:
		settings["fullscreen"] = value
		_apply_settings()
	)
	panel.add_child(_fullscreen_toggle)

	var resolution_label := _label("Resolução", Vector2(38, 279), Vector2(155, 34), 15, Color("#d5f4ff"))
	panel.add_child(resolution_label)
	_resolution_select = OptionButton.new()
	_resolution_select.position = Vector2(190, 278)
	_resolution_select.size = Vector2(205, 36)
	for resolution in RESOLUTIONS:
		_resolution_select.add_item("%d × %d" % [resolution.x, resolution.y])
	_resolution_select.item_selected.connect(func(index: int) -> void:
		settings["resolution_index"] = index
		_apply_settings()
	)
	panel.add_child(_resolution_select)

	_minimap_toggle = CheckButton.new()
	_minimap_toggle.position = Vector2(34, 321)
	_minimap_toggle.text = "Exibir minimapa"
	_minimap_toggle.add_theme_font_size_override("font_size", 15)
	_minimap_toggle.toggled.connect(func(value: bool) -> void:
		settings["show_minimap"] = value
		_apply_settings()
	)
	panel.add_child(_minimap_toggle)

	_camera_toggle = CheckButton.new()
	_camera_toggle.position = Vector2(300, 321)
	_camera_toggle.text = "Câmera suavizada"
	_camera_toggle.add_theme_font_size_override("font_size", 15)
	_camera_toggle.toggled.connect(func(value: bool) -> void:
		settings["camera_smoothing"] = value
		_apply_settings()
	)
	panel.add_child(_camera_toggle)

	var controls_title := _label("CONTROLES", Vector2(38, 370), Vector2(580, 30), 17, Color("#ffe7a6"))
	panel.add_child(controls_title)
	for index in REMAP_ACTIONS.size():
		var action: StringName = REMAP_ACTIONS[index]
		var column := index % 2
		var row := int(index / 2)
		var x := 38.0 + float(column) * 292.0
		var y := 402.0 + float(row) * 56.0
		panel.add_child(_label(ACTION_LABELS[index], Vector2(x, y), Vector2(280, 22), 12, Color("#d5f4ff")))
		var button := Button.new()
		button.position = Vector2(x, y + 21.0)
		button.size = Vector2(260, 31)
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(func() -> void: _begin_key_capture(action))
		key_buttons[action] = button
		panel.add_child(button)

	_status_label = _label("Setas e teclas alternativas continuam ativas. Esc fecha opções.", Vector2(38, 574), Vector2(580, 22), 12, Color("#91d7ff"))
	panel.add_child(_status_label)
	var close_button := Button.new()
	close_button.position = Vector2(225, 618)
	close_button.size = Vector2(210, 38)
	close_button.text = "VOLTAR"
	close_button.add_theme_font_size_override("font_size", 16)
	close_button.pressed.connect(func() -> void:
		visible = false
		closed.emit()
	)
	panel.add_child(close_button)
	_sync_controls()

func _add_volume_row(parent: Control, row_label: String, setting_name: String, y: int) -> void:
	parent.add_child(_label(row_label, Vector2(38, y), Vector2(145, 30), 15, Color("#d5f4ff")))
	var slider := HSlider.new()
	slider.position = Vector2(190, y + 2)
	slider.size = Vector2(300, 26)
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = float(settings[setting_name])
	slider.value_changed.connect(func(value: float) -> void:
		settings[setting_name] = value
		_apply_settings()
	)
	_volume_sliders[setting_name] = slider
	parent.add_child(slider)
	var value_label := _label("%d%%" % roundi(float(settings[setting_name]) * 100.0), Vector2(510, y), Vector2(95, 30), 14, Color("#ffe7a6"))
	value_label.name = "%sValue" % setting_name
	parent.add_child(value_label)
	slider.value_changed.connect(func(value: float) -> void: value_label.text = "%d%%" % roundi(value * 100.0))

func _label(text_value: String, position_value: Vector2, size_value: Vector2, font_size: int, color_value: Color) -> Label:
	var label := Label.new()
	label.position = position_value
	label.size = size_value
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color_value)
	return label

func _sync_controls() -> void:
	if not is_instance_valid(_fullscreen_toggle):
		return
	_fullscreen_toggle.set_pressed_no_signal(bool(settings["fullscreen"]))
	_resolution_select.select(clampi(int(settings["resolution_index"]), 0, RESOLUTIONS.size() - 1))
	_minimap_toggle.set_pressed_no_signal(bool(settings["show_minimap"]))
	_camera_toggle.set_pressed_no_signal(bool(settings["camera_smoothing"]))
	for setting_name in _volume_sliders:
		(_volume_sliders[setting_name] as HSlider).set_value_no_signal(float(settings[setting_name]))
	_refresh_key_buttons()

func _begin_key_capture(action: StringName) -> void:
	capture_action = action
	(key_buttons[action] as Button).text = "Pressione uma tecla…"
	_status_label.text = "Aguardando nova tecla para %s." % ACTION_LABELS[REMAP_ACTIONS.find(action)].to_lower()

func _set_binding(action: StringName, key_code: int) -> bool:
	if key_code in RESERVED_KEYS and int(key_values.get(action, -1)) != key_code:
		_status_label.text = "Essa tecla já é usada por uma ação do jogo."
		return false
	for other_action in REMAP_ACTIONS:
		var other_keys: Array = ACTION_ALTERNATES.get(other_action, []).duplicate()
		other_keys.append(int(key_values.get(other_action, -1)))
		if other_action != action and key_code in other_keys:
			_status_label.text = "Essa tecla já está atribuída a outro controle."
			return false
	key_values[action] = key_code
	_config.set_value("controls", String(action), key_code)
	_set_input_events(action, key_code)
	_save_config()
	_refresh_key_buttons()
	settings_changed.emit(settings.duplicate(true))
	return true

func _end_key_capture(status: String) -> void:
	capture_action = &""
	_status_label.text = status
	_refresh_key_buttons()

func _refresh_key_buttons() -> void:
	for index in REMAP_ACTIONS.size():
		var action: StringName = REMAP_ACTIONS[index]
		if not key_buttons.has(action):
			continue
		var primary := _key_label(int(key_values.get(action, DEFAULT_KEYS[index])))
		var alternatives: Array = ACTION_ALTERNATES.get(action, [])
		var alternative_labels: PackedStringArray = []
		for alternative_key in alternatives:
			alternative_labels.append(_key_label(alternative_key))
		var suffix := "  +  %s" % " / ".join(alternative_labels) if not alternative_labels.is_empty() else ""
		(key_buttons[action] as Button).text = "%s%s" % [primary, suffix]

func _key_label(physical_code: int) -> String:
	# Keyboard layout translation is unavailable on Godot's headless display server.
	return OS.get_keycode_string(physical_code)

func _apply_settings(save: bool = true) -> void:
	settings["master_volume"] = clampf(float(settings.get("master_volume", 0.85)), 0.0, 1.0)
	settings["music_volume"] = clampf(float(settings.get("music_volume", 0.62)), 0.0, 1.0)
	settings["sfx_volume"] = clampf(float(settings.get("sfx_volume", 0.80)), 0.0, 1.0)
	settings["resolution_index"] = clampi(int(settings.get("resolution_index", 0)), 0, RESOLUTIONS.size() - 1)
	_ensure_audio_bus("Music")
	_ensure_audio_bus("SFX")
	_set_bus_volume("Master", float(settings["master_volume"]))
	_set_bus_volume("Music", float(settings["music_volume"]))
	_set_bus_volume("SFX", float(settings["sfx_volume"]))
	if DisplayServer.get_name() != "headless":
		if bool(settings["fullscreen"]):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			var resolution: Vector2i = RESOLUTIONS[int(settings["resolution_index"])]
			DisplayServer.window_set_size(resolution)
	settings_changed.emit(settings.duplicate(true))
	if save:
		for setting_name in settings:
			_config.set_value("settings", setting_name, settings[setting_name])
		_save_config()

func _ensure_audio_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	var bus_index := AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bus_index, bus_name)
	AudioServer.set_bus_send(bus_index, "Master")

func _set_bus_volume(bus_name: String, linear_value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(linear_value, 0.0001)))

func _save_config() -> void:
	var error := _config.save(settings_path)
	if error != OK:
		push_error("Could not persist game settings (error %d)." % error)
