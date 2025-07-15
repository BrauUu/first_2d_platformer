class_name EnemyHurtState
extends State

@export var enemy : Enemy

func enter(params: Dictionary = {}) -> void:
	enemy.apply_hurt_effect()
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
