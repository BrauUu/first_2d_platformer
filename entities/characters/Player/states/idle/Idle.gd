class_name PlayerIdleState
extends State

@export var player : Player

func enter(params: Dictionary = {}) -> void:
	player.velocity.x = 0
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	if player.is_on_floor():
		player.set_animation("idle")
	
func physics_update(_delta: float) -> void:
	if player.velocity.x:
		changed.emit("Move")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and player.can_execute_jump():
		pushed.emit("Jump")
	elif event.is_action_pressed("attack") and player.can_execute_attack():
		pushed.emit("Attack")

func pause() -> void:
	pass

func resume() -> void:
	player.set_animation("idle")
