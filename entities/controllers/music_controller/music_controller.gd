class_name MusicController
extends AudioController

var current_song : Node

func _ready() -> void:
	super._ready()
	GameManager.connect("gm_music_toggle", _toggle_music)

func play_sound(sound_name: String, params: Dictionary = {}) -> void:
	if audios.get(sound_name.to_lower()):
		if current_song:
			stop_sound(current_song.name)
		current_song = audios.get(sound_name.to_lower())
		current_song.play()

func _toggle_music(toggled_on: bool) -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(music_bus, toggled_on)
