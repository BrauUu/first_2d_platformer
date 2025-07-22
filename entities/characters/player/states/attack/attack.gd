class_name PlayerAttackState
extends State

@export var player : Player

func enter(params: Dictionary = {}) -> void:
	if params.get("play_animation") == false:
		popped.emit()
	else:
		player.velocity.x = 0
		player.on_animation = true
		player.set_animation('attack')
	
func exit() -> void:
	player.on_animation = false
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
