class_name Mushroom
extends CharacterBody2D

@onready var animator: AnimatedSprite2D = $Animator
@onready var sleeping_onomatopoeia: AnimatedSprite2D = $SleepingOnomatopoeia
@onready var audio_controller: AudioController = $AudioController
@onready var knockback_component: Node = $KnockbackComponent
@onready var movement_controller: MovementController = $MovementController
@onready var movement_component: Node = $MovementComponent
@onready var player_detector_raycast: RayCast2D = $PlayerDetectorRaycast

enum MUSHROOM_STATES {WALK, SLEEP, DEAD, SMASH, AWAKE}

@export var initial_state: MUSHROOM_STATES = MUSHROOM_STATES.SLEEP
@export var health := 2

var initial_position : Vector2 = Vector2.ZERO
var current_state: int = initial_state
var animations: PackedStringArray = PackedStringArray()
var current_health : int = 0
var was_sleeping : bool = false
var player : Player = null

func update_animation(animation: String = '') -> void:
	if not animation:
		animation = MUSHROOM_STATES.keys()[current_state].to_lower()
	if animation in animations:
		animator.play(animation)
	
func is_valid_state(value: int) -> bool:
	return value in MUSHROOM_STATES.values()
	
func is_current_state(state: int) -> bool:
	return state == current_state
	
func get_current_state() -> int:
	return current_state
	
func set_current_state(new_state: int) -> void:
	if is_valid_state(new_state):
		current_state = new_state

func _ready() -> void:
	initial_position = global_position
	animations = animator.sprite_frames.get_animation_names()
	set_current_state(initial_state)
	update_animation()
	current_health = health
	if is_current_state(MUSHROOM_STATES.SLEEP):
		change_onomatopoeia_visibility(true)

func _process(delta: float) -> void:
	animator.flip_h = velocity.x < 0
	player_detector_raycast.rotation_degrees = 180 if velocity.x < 0 else 0
	
func _physics_process(delta: float) -> void:
	if is_current_state(MUSHROOM_STATES.WALK):
		velocity.x = movement_controller.get_combined_velocity().x
	else:
		velocity.x = 0
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	
func change_onomatopoeia_visibility(visible: bool) -> void:
	sleeping_onomatopoeia.play("enabled" if visible else "disabled")

func bounce(player: Player) -> void:
	var knockback_info = {
	"knockback_force": 600,
		"position": {
			"x": null,
			"y": global_position.y
		}
	}
	player.apply_knockback(knockback_info)
	audio_controller.play_sound("Bounce")
	set_current_state(MUSHROOM_STATES.SMASH)
	update_animation()

func is_above(pos: Vector2) -> bool:
	return pos.y <= (global_position.y - $BounceArea/CollisionShape2D.shape.size.y / 2)

func _on_bounce_area_player_entered(player: Player) -> void:
	self.player = player
	if is_above(player.global_position):
		if is_current_state(MUSHROOM_STATES.SLEEP):
			change_onomatopoeia_visibility(false)
			was_sleeping = true
		bounce(player)

func _on_animator_animation_finished() -> void:
	match animator.animation:
		"smash":
			set_current_state(MUSHROOM_STATES.AWAKE if was_sleeping else MUSHROOM_STATES.WALK)
		"awake":
			movement_component.was_awakened(player)
			set_current_state(MUSHROOM_STATES.WALK)
	update_animation()
