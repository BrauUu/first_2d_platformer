class_name PlayerJumpState
extends State

@export var player : Player
@export var audio_controller: AudioController

func enter(params: Dictionary = {}) -> void:
	player.velocity.y = -player.jump_power
	player.jump_count += 1
	audio_controller.play_sound("Jump", {"must_stop" : true})
	
func exit() -> void:
	pass

func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	if player.is_on_floor():
		popped.emit()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and player.can_execute_jump():
		pushed.emit("Jump")
	elif event.is_action_pressed("attack") and player.can_execute_attack():
		pushed.emit("Attack", {"play_animation": false})
