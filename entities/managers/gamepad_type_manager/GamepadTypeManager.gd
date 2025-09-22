extends Node

var current_gamepad_type : String

signal gamepad_type_changed

func _ready() -> void:
	current_gamepad_type = get_gamepad_type()
	IconsManager.update_current_icons(current_gamepad_type)

func _input(event: InputEvent):
	if not event.is_pressed(): return
	
	var new_gamepad_type
	
	if event is InputEventKey:
		new_gamepad_type = "keyboard"
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		new_gamepad_type = get_gamepad_type()
	
	if new_gamepad_type and new_gamepad_type != current_gamepad_type:
		current_gamepad_type = new_gamepad_type
		IconsManager.update_current_icons(current_gamepad_type)
		gamepad_type_changed.emit()
		
func get_gamepad_type() -> String:
	var gamepads = Input.get_connected_joypads()
	
	var ps_regex = RegEx.new()
	ps_regex.compile("ps4|ps5|dualsense|dualshock")
	
	var xbox_regex = RegEx.new()
	xbox_regex.compile("xbox|xinput")
	
	for gamepad_id in gamepads:
		var gamepad_name = Input.get_joy_name(gamepad_id).to_lower()
		if xbox_regex.search(gamepad_name):
			return "xbox"
		elif ps_regex.search(gamepad_name):
			return "ps"
	return "keyboard"
