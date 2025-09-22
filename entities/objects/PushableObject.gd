class_name PushableObject
extends InteractableObject

@export var interactive_zone_left: Area2D
@export var interactive_zone_right: Area2D
@export var audio_controller: AudioController
@export var floating_key: Control

@export var weight : int

var was_on_floor: bool = true
var interaction_direction: int = 0
var player : Player

func _ready() -> void:
	if interactive_zone_left:
		interactive_zone_left.connect("body_entered",_on_interactive_zone_left_body_entered)
		interactive_zone_left.connect("body_exited",_on_interactive_zone_body_exited)
	if interactive_zone_right:
		interactive_zone_right.connect("body_exited",_on_interactive_zone_body_exited)
		interactive_zone_right.connect("body_entered",_on_interactive_zone_right_body_entered)

func _process(delta: float) -> void:
	super(delta)
	if not can_reach: return
	if active and can_be_interacted:
		floating_key.player_on_interactive_zone()
	else:
		floating_key.player_out_interactive_zone()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if not was_on_floor and is_on_floor():
		_on_drop()
		
	if is_being_interacted:
		player.interaction_direction = interaction_direction
		var new_velocity = player.direction * (player.force / weight) * 30
		velocity.x = new_velocity
		player.velocity.x = new_velocity
		if get_last_motion():
			_on_push()
		else:
			_on_stop_push()
	elif velocity.x != 0:
		velocity.x = 0
		_on_stop_push()
		
	was_on_floor = is_on_floor()
	move_and_slide()

func _on_interactive_zone_body_entered(body: Node2D, side: int) -> void:
	can_reach = true
	player = body
	interaction_direction = side

func _on_interactive_zone_body_exited(body: Node2D) -> void:
	if floating_key:
		floating_key.player_out_interactive_zone()
	if is_being_interacted: 
		finish_interaction()
	can_reach = false
	can_be_interacted = false
	player = null

func _input(event):
	if not can_be_interacted or player.on_animation: return
	if active and event.is_action_pressed("interact"):
		_on_interact()
		if not is_being_interacted:
			player.start_interaction()
			is_being_interacted = true
			if floating_key:
				floating_key.key_pressed()
		else:
			finish_interaction() 
			
func finish_interaction() -> void:
	player.finish_interaction()
	is_being_interacted = false
	player.is_interacting = false
	if floating_key:
		floating_key.key_released()
	
func _on_drop() -> void:
	if audio_controller:
		audio_controller.play_sound("Drop")
		
func _on_push() -> void:
	if audio_controller:
		audio_controller.play_sound("Push")
		
func _on_stop_push() -> void:
	if audio_controller:
		audio_controller.stop_sound("Push")
		
func _on_interact() -> void:
	if audio_controller:
		audio_controller.play_sound("Interact")

func _on_interactive_zone_left_body_entered(body: Node2D) -> void:
	_on_interactive_zone_body_entered(body, -1)

func _on_interactive_zone_right_body_entered(body: Node2D) -> void:
	_on_interactive_zone_body_entered(body, 1)
