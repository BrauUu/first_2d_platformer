class_name EnemyJumpState
extends State

@export var enemy : Enemy
#@export var audio_controller: AudioController

func enter(params: Dictionary = {}) -> void:
	enemy.velocity.y = -enemy.jump_power
	#audio_controller.play_sound("Jump", {"must_stop" : true})
	
func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	if enemy.is_on_floor():
		popped.emit()
