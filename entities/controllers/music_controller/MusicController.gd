class_name MusicController
extends AudioController

var current_song : AudioStreamPlayer
var next_song: AudioStreamPlayer
var last_song : Node

func _ready() -> void:
	super._ready()
	GameManager.connect("gm_music_toggle", _toggle_music)
	GameManager.connect("gm_music_mute", mute_current_music)

func play_sound(sound_name: String, with_fade_out: bool = false, params: Dictionary = {}) -> void:
	if audios.get(sound_name.to_lower()):
		if current_song:
			last_song = current_song
			if with_fade_out:
				next_song = audios.get(sound_name.to_lower())
				next_song.volume_db = -30
				next_song.play()
				
				var tween = create_tween()
				tween.parallel().tween_property(current_song, "volume_db", -30, 1)
				tween.parallel().tween_property(next_song, "volume_db", 0, 1)
				tween.finished.connect(func():
					stop_sound(current_song.name)
				)
			else:
				stop_sound(current_song.name)
		current_song = audios.get(sound_name.to_lower())
		current_song.play()
		
func mute_current_music(mute: bool, with_fade_out: bool = false, params: Dictionary = {}) -> void:
	mute_sound(current_song.name, mute, with_fade_out)

func _toggle_music(toggled_on: bool) -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(music_bus, toggled_on)
	
func play_last_song() -> void:
	play_sound(last_song.name)
