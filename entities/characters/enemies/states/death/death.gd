class_name EnemyDeathState
extends State

@export var enemy : CharacterBody2D

func enter(params: Dictionary = {}) -> void:
	if params.damage_info.get("not_play_animation"):
		exit()
	enemy.play_animation("die")
	
func exit() -> void:
	enemy.queue_free()
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
