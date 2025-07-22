class_name PlayerAttackState
extends State

@export var player : Player
@export var audio_controller: AudioController

func enter(params: Dictionary = {}) -> void:
	audio_controller.play_sound("Attack")
	if params.get("play_animation") == false:
		popped.emit()
	else:
		player.on_animation = true
		player.set_animation('attack')
	
func exit() -> void:
	player.on_animation = false
	
func update(_delta: float) -> void:
	if player.direction:
		audio_controller.play_sound("Move")
	
func physics_update(_delta: float) -> void:
	pass
