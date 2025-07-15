class_name PlayerInteractState
extends State

@export var player : Player

func enter(params: Dictionary = {}) -> void:
	pass
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	var force_applied = player.interaction_direction * player.velocity.x
	if force_applied:
		if force_applied > 0:
			player.set_animation('pull')
		elif force_applied < 0:
			player.set_animation('push')
	else:
		player.set_animation('idle')
		player.direction = -player.interaction_direction 
	
func physics_update(_delta: float) -> void:
	pass
	
func handle_input(event: InputEvent) -> void: 
	pass
