class_name EnemyAttackState
extends State

@export var enemy : CharacterBody2D

func enter(params: Dictionary = {}) -> void:
	pass
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	enemy.attack()
	
func physics_update(_delta: float) -> void:
	pass
