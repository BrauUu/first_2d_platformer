class_name AudioController
extends Node

var sfx_nodes : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is AudioStreamPlayer2D or child is AudioStreamPlayer:
			sfx_nodes[child.name.to_lower()] = child

func play_sound(sound_name: String, params: Dictionary = {}) -> void:
	if sfx_nodes.get(sound_name.to_lower()):
		var sound = sfx_nodes.get(sound_name.to_lower())
		
		if not sound.playing or params.get("must_stop"):
			sound.play()
		
