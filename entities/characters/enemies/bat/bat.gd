class_name Bat
extends Enemy

@onready var awake_area: Area2D = $AwakeArea
@onready var animator: AnimatedSprite2D = $Animator
@onready var movement_controller: MovementController = $MovementController
@onready var movement_component: Node = $MovementComponent
@onready var audio_controller: AudioController = $AudioController
@onready var attack: Attack = $Attack

const BAT_DASH = preload("res://entities/effects/bat_dash/bat_dash.tscn")

enum BAT_STATES {FLY, SLEEPING, DEAD, ATTACK}

@export var initial_state: BAT_STATES = BAT_STATES.SLEEPING
@export var attack_speed: int = 100
@export var fly_distance: int = 100

var current_state: int = initial_state
var animations: PackedStringArray = PackedStringArray()
var collision: KinematicCollision2D = null
var initial_point: Vector2 = Vector2.ZERO
var attacking: bool = false
var dash_effect: AnimatedSprite2D

func update_animation() -> void:
	var animation: String = BAT_STATES.keys()[current_state].to_lower()
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
		
func is_inactive() -> bool:
	return is_current_state(BAT_STATES.DEAD) or is_current_state(BAT_STATES.SLEEPING)
		
func change_direction() -> void:
	direction = direction * -1

func _ready() -> void:
	animations = animator.sprite_frames.get_animation_names()
	direction = initial_direction
	initial_point = Vector2(global_position.x, global_position.y + 10)
	
	update_animation()
	if is_current_state(BAT_STATES.FLY):
		movement_component.enabled = true
	
	var original_material : Material = animator.material
	animator.material = original_material.duplicate()
	
func _process(delta: float) -> void:
	if is_inactive(): return
	animator.flip_h = direction == 1
	if current_cooldown > 0:
		current_cooldown -= delta
	if attacking:
		set_current_state(BAT_STATES.ATTACK)
		show_dash_effect()
	else:
		set_current_state(BAT_STATES.FLY)
	update_animation()
		

func _physics_process(delta: float) -> void:
	
	velocity = movement_controller.get_combined_velocity()
	move_and_slide()
	
func apply_hurt_effect() -> void:
	var material: ShaderMaterial = animator.material
	material.set_shader_parameter("flash_amount", 1)
	await get_tree().create_timer(0.5).timeout
	material.set_shader_parameter("flash_amount", 0.0)
	
func die(damage_info: Dictionary) -> void:
	set_current_state(BAT_STATES.DEAD)
	movement_component.enabled = false
	update_animation()
	apply_hurt_effect()
	
func show_dash_effect() -> void:
	if not dash_effect or dash_effect.position.distance_to(position) > 20:
		dash_effect = BAT_DASH.instantiate()
		get_parent().add_child(dash_effect)
		dash_effect.position = position - (Vector2(5, 0) * direction)
		
func dash_finished() -> void:
	attack.reset_attacked_entities()
	
func get_damage() -> Dictionary:
	return {
		"damage": damage,
		"knockback_force": 300,
		"source": self,
		"position": {
			"x": global_position.x,
			"y": global_position.y
		},
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

func _on_animator_frame_changed() -> void:
	if animator.animation == "fly" and animator.frame == 1:
		audio_controller.play_sound("Fly")

func _on_animator_animation_changed() -> void:
	match animator.animation:
		"attack":
			audio_controller.play_sound("Attack")
