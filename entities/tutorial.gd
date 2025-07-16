extends Control

var icons : Dictionary
var instructions : Array

func _ready() -> void:
	instructions = get_children()
	icons = IconsManager.get_current_icons()
	GamepadTypeManager.connect("gamepad_type_changed", on_gamepad_type_changed)
	update_instructions_icons()
	
func update_instructions_icons() -> void:
	for instruction in instructions:
		var instruction_name = instruction.instruction_name
		for child in instruction.get_children():
			if child.is_class("TextureRect"):
				child.texture.atlas = load(icons["path"])
				child.texture.region = icons[instruction_name]
				
func on_gamepad_type_changed() -> void:
	icons = IconsManager.get_current_icons()
	update_instructions_icons()
