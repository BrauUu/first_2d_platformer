class_name Bat
extends Enemy

@onready var awake_area: Area2D = $AwakeArea
@onready var animator: AnimatedSprite2D = $Animator
@onready var movement_controller: MovementController = $MovementController
@onready var movement_component: Node = $MovementComponent

enum BAT_STATES {FLY, SLEEPING, DEAD, ATTACK}

@export var initial_state : BAT_STATES = BAT_STATES.SLEEPING
@export var attack_speed: int = 100
@export var fly_distance: int = 100

var current_state : int
var animations: PackedStringArray
var collision : KinematicCollision2D
var initial_point : Vector2

func update_animation() -> void:
	var animation = BAT_STATES.keys()[current_state].to_lower()
	if animation in animations:
		animator.play(animation)
	
func is_valid_state(value: int) -> bool:
	return value in BAT_STATES.values()
	
func is_current_state(state: int) -> bool:
	return state == current_state
	
func get_current_state() -> int:
	return current_state
	
func set_current_state(new_state: int) -> void:
	if is_valid_state(new_state):
		current_state = new_state
		
func change_direction() -> void:
	direction = direction * -1

func _ready() -> void:
	current_state = initial_state
	animations = animator.sprite_frames.get_animation_names()
	update_animation()
	direction = initial_direction
	initial_point = Vector2(global_position.x, global_position.y + 10)
	
	if is_current_state(BAT_STATES.FLY):
		movement_component.enabled = true
	
	var original_material = animator.material
	animator.material = original_material.duplicate()
	
func _process(delta: float) -> void:
	animator.flip_h = direction == 1
	if current_cooldown > 0:
		current_cooldown -= delta

func _physics_process(delta: float) -> void:
	
	velocity = movement_controller.get_combined_velocity()
	move_and_slide()
	
func apply_hurt_effect() -> void:
	var material : ShaderMaterial = animator.material
	material.set_shader_parameter("flash_amount", 1)
	await get_tree().create_timer(0.5).timeout
	material.set_shader_parameter("flash_amount", 0.0)
	
func die(damage_info) -> void:
	set_current_state(BAT_STATES.DEAD)
	update_animation()
	apply_hurt_effect()
	
func get_damage() -> Dictionary:
	return {
		"damage": damage,
		"knockback_force": 50,
		"source": self,
		"death_cause": "A single bat, a mighty foe. Truly legendary."
	}

func _on_awake_area_player_entered(player: Player) -> void:
	if current_state == BAT_STATES.SLEEPING:
		set_current_state(BAT_STATES.FLY)
		movement_component.enabled = true
		update_animation()

func _on_animator_animation_finished() -> void:
	match animator.animation:
		"dead":
			queue_free()
