class_name EnemyAttackState
extends State

@export var enemy : Enemy

func enter(params: Dictionary = {}) -> void:
	enemy.set_animation("attack")
	enemy.velocity.x = 0
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
