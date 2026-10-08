class_name KataklysmaAudioManager
extends Node

## Echo Isles audio routing. A generated music candidate is used when present;
## procedural one-shot tones remain a temporary fallback for unfinished SFX.

const AMBIENCE_PATH := "res://01_ASSETS/kataklysma/audio/music/echo_isles_field_ambience_ai_v001.mp3"
const SFX_DIR := "res://01_ASSETS/kataklysma/audio/sfx"

var enabled := true
var volume_db := -3.0
var music_player: AudioStreamPlayer

func _ready() -> void:
	_ensure_bus("Music")
	_ensure_bus("SFX")
	if ResourceLoader.exists(AMBIENCE_PATH):
		var stream := load(AMBIENCE_PATH) as AudioStreamMP3
		if stream:
			stream.loop = true
			music_player = AudioStreamPlayer.new()
			music_player.name = "EchoIslesAmbientMusic"
			music_player.bus = "Music"
			music_player.stream = stream
			music_player.volume_db = volume_db
			add_child(music_player)

func start_ambience() -> void:
	if music_player and not music_player.playing:
		music_player.play()

func stop_ambience() -> void:
	if music_player and music_player.playing:
		music_player.stop()

func play_ui(event_name: String) -> void:
	if not enabled:
		return
	var authored_path := "%s/%s.ogg" % [SFX_DIR, event_name]
	if ResourceLoader.exists(authored_path):
		var authored_player := AudioStreamPlayer.new()
		authored_player.bus = "SFX"
		authored_player.stream = load(authored_path)
		authored_player.finished.connect(authored_player.queue_free)
		add_child(authored_player)
		authored_player.play()
		return
	var frequencies := {
		"menu_select": 440.0,
		"quest_accept": 523.25,
		"quest_complete": 659.25,
		"combat": 146.83,
		"error": 110.0,
	}
	var frequency: float = float(frequencies.get(event_name, 330.0))
	_play_tone(frequency, 0.16 if event_name != "combat" else 0.28)

func _play_tone(frequency: float, duration: float) -> void:
	var player := AudioStreamPlayer.new()
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = maxf(0.2, duration + 0.05)
	player.stream = generator
	player.bus = "SFX"
	player.volume_db = volume_db
	add_child(player)
	player.play()
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback:
		var frame_count: int = int(generator.mix_rate * duration)
		for frame in range(frame_count):
			var time: float = float(frame) / generator.mix_rate
			var envelope: float = 1.0 - (time / duration)
			var sample: float = sin(TAU * frequency * time) * envelope * 0.22
			playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(duration + 0.15).timeout.connect(player.queue_free)

func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	var bus_index := AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bus_index, bus_name)
	AudioServer.set_bus_send(bus_index, "Master")
