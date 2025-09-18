class_name EnemyIdleState
extends State

@export var enemy : CharacterBody2D

func enter(params: Dictionary = {}) -> void:
	enemy.play_animation("idle")
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	if enemy.velocity.x and !enemy.is_invulnerable():
		enemy.play_animation("move")
	else:
		enemy.play_animation("idle")
	
func physics_update(_delta: float) -> void:
	pass

func pause() -> void:
	pass

func resume() -> void:
	enemy.play_animation("idle")
