class_name State extends Node

signal paused
signal resumed
signal pushed (state: State, params: Dictionary)
signal popped
signal changed(new_state_name: String, params: Dictionary)

func enter(params: Dictionary = {}) -> void:
	pass
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
	
func handle_input(event: InputEvent) -> void: 
	pass
	
func pause() -> void:
	pass

func resume() -> void:
	pass
