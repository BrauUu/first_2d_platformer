class_name PlayerMoveState
extends State

@export var player : Player
@export var audio_controller: AudioController

func enter(params: Dictionary = {}) -> void:
	pass
	
func exit() -> void:
	pass
	
func update(delta: float) -> void:
	if player.is_on_floor():
		player.set_animation("move")
		audio_controller.play_sound("Move")
	
func physics_update(delta: float) -> void:
	if !player.velocity.x:
		changed.emit("Idle")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and player.can_execute_jump():
		pushed.emit("Jump")
	elif event.is_action_pressed("attack") and player.can_execute_attack():
		pushed.emit("Attack")
		
func resume() -> void:
	player.set_animation("move")
