class_name EnemyMoveState
extends State

@export var enemy : Enemy
#@export var audio_controller: AudioController

func enter(params: Dictionary = {}) -> void:
	enemy.set_animation("move")
	
func exit() -> void:
	pass
	
func update(delta: float) -> void:
	#audio_controller.play_sound("Move")
	pass
	
func physics_update(delta: float) -> void:
	if enemy.direction == 0:
		changed.emit("Idle")
		
func resume() -> void:
	enemy.set_animation("move")
