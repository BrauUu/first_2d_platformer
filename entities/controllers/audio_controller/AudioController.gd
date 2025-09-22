class_name AudioController
extends Node2D

var audios : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is AudioStreamPlayer2D or child is AudioStreamPlayer:
			audios[child.name.to_lower()] = child
			
func play_sound(sound_name: String, with_fade_out: bool = false, params: Dictionary = {}) -> void:
	if audios.get(sound_name.to_lower()):
		var sound = audios.get(sound_name.to_lower())
		
		if not sound.playing or params.get("must_stop"):
			sound.play()
			
func stop_sound(sound_name: String, with_fade_out: bool = false) -> void:
	if audios.get(sound_name.to_lower()):
		var sound = audios.get(sound_name.to_lower())
		if with_fade_out:
			var tween = create_tween()
			tween.parallel().tween_property(sound, "volume_db", 0, 2)
			tween.finished.connect(func():
				sound.stop()
			)
		else:
			sound.stop()
			
func mute_sound(sound_name: String, mute: bool, with_fade_out: bool = false) -> void:
	if audios.get(sound_name.to_lower()):
		var sound = audios.get(sound_name.to_lower())
		var target_volume = -30 if mute else 0
		if with_fade_out:
			var tween = create_tween()
			tween.parallel().tween_property(sound, "volume_db", target_volume, 1)
		else:
			sound.volume_db = target_volume
