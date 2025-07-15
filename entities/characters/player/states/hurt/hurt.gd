class_name PlayerHurtState
extends State

@export var player : Player

func enter(params: Dictionary = {}) -> void:
	player.set_animation("hurt")
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")	
	player.velocity.x = direction * player.speed
	player.direction = direction

func handle_input(event: InputEvent) -> void:
	pass
