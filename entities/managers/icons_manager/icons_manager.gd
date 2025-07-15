extends Node

var current_icons : Dictionary = {}

func get_current_icons():
	return current_icons
	
func update_current_icons(gamepad_type: String) -> void:
	if gamepad_type in GamepadsIcons.icons_paths:
		current_icons = GamepadsIcons.icons_paths[gamepad_type]
