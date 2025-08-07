class_name MusicController
extends AudioController

var current_song : Node

func play_sound(sound_name: String, params: Dictionary = {}) -> void:
	if audios.get(sound_name.to_lower()):
		if current_song:
			stop_sound(current_song.name)
		current_song = audios.get(sound_name.to_lower())
		current_song.play()
