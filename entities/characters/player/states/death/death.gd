class_name PlayerDeathState
extends State

@export var player : Player

func enter(params: Dictionary = {}) -> void:
	player.velocity.x = 0
	if params.damage_info.get("not_play_animation"):
		exit()
	player.on_animation = true
	player.is_controllable = false
	player.set_animation("die")
	
func exit() -> void:
	player.queue_free()
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
