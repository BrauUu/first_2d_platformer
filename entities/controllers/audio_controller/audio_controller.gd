class_name AudioController
extends Node2D

var audios : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is AudioStreamPlayer2D or child is AudioStreamPlayer:
			audios[child.name.to_lower()] = child
			
func play_sound(sound_name: String, params: Dictionary = {}) -> void:
	if audios.get(sound_name.to_lower()):
		var sound = audios.get(sound_name.to_lower())
		
		if not sound.playing or params.get("must_stop"):
			sound.play()
			
func stop_sound(sound_name: String) -> void:
	if audios.get(sound_name.to_lower()):
		var sound = audios.get(sound_name.to_lower())
		sound.stop()
