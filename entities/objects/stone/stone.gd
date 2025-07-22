extends CharacterBody2D

@onready var floating_key: Control = $FloatingKey
@onready var audio_controller: AudioController = $AudioController

@export var weight : int

var can_be_interacted := false
var is_being_interacted := false

var player : Player

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_being_interacted:
		var new_velocity = player.direction * (player.force / weight) * 30
		velocity.x = new_velocity
		player.velocity.x = new_velocity
		if new_velocity:
			audio_controller.play_sound("Push")
		else:
			audio_controller.stop_sound("Push")
	else:
		velocity.x = 0
		
	move_and_slide()

func _on_interactive_zone_body_entered(body: Node2D, side: int) -> void:
	floating_key.player_on_interactive_zone()
	can_be_interacted = true
	player = body
	player.interaction_direction = side

func _on_interactive_zone_body_exited(body: Node2D) -> void:
	floating_key.player_out_interactive_zone()
	if is_being_interacted: 
		finish_interaction()
	can_be_interacted = false
	player = null

func _input(event):
	if not can_be_interacted or player.on_animation: return
	if event.is_action_pressed("interact"):
		if not is_being_interacted:
			player.start_interaction()
			is_being_interacted = true
			player.is_interacting = true
			floating_key.key_pressed()
		else:
			finish_interaction() 
			
func finish_interaction() -> void:
	player.finish_interaction()
	is_being_interacted = false
	player.is_interacting = false
	floating_key.key_released()

func _on_interactive_zone_left_body_entered(body: Node2D) -> void:
	_on_interactive_zone_body_entered(body, -1)

func _on_interactive_zone_right_body_entered(body: Node2D) -> void:
	_on_interactive_zone_body_entered(body, 1)
