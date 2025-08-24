class_name EnemyIdleState
extends State

@export var enemy : Enemy

func enter(params: Dictionary = {}) -> void:
	enemy.set_animation("idle")
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func pause() -> void:
	pass

func resume() -> void:
	enemy.set_animation("idle")
