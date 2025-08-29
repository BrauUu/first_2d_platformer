class_name EnemyIdleState
extends State

@export var enemy : Enemy

func enter(params: Dictionary = {}) -> void:
	enemy.set_animation("idle")
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	if enemy.velocity.x and !enemy.is_invunerable():
		enemy.set_animation("move")
	else:
		enemy.set_animation("idle")
	
func physics_update(_delta: float) -> void:
	pass

func pause() -> void:
	pass

func resume() -> void:
	enemy.set_animation("idle")
