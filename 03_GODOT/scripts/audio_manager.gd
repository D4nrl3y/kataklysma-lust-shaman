class_name KataklysmaAudioManager
extends Node

## Temporary procedural audio layer for the vertical slice.
## It provides functional feedback now and can be replaced by authored WAV/OGG
## tracks without changing callers.

var enabled := true
var volume_db := -10.0

func play_ui(event_name: String) -> void:
    if not enabled:
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
