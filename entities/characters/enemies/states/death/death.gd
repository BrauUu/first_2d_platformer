class_name EnemyDeathState
extends State

@export var enemy : Enemy

func enter(params: Dictionary = {}) -> void:
	if params.damage_info.get("not_play_animation"):
		exit()
	enemy.set_animation("die")
	
func exit() -> void:
	enemy.queue_free()
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
