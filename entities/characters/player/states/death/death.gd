class_name PlayerDeathState
extends State

@export var player : Player

func enter(params: Dictionary = {}) -> void:
	if params.damage_info.get("not_play_animation"):
		exit()
	player.set_animation("die")
	
func exit() -> void:
	player.queue_free()
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
