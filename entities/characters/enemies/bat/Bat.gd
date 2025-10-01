class_name Bat
extends Enemy

@onready var awake_area: Area2D = $AwakeArea
@onready var movement_component: Node = $MovementComponent
@onready var attack_area: Attack = $Attack

const BAT_DASH = preload("res://entities/effects/bat_dash/BatDash.tscn")

enum BatStates {FLY, SLEEP, DEAD, ATTACK}

@export var initial_state: BatStates = BatStates.SLEEP
@export var attack_speed: int = 100
@export var fly_distance: int = 100

var current_state: BatStates = initial_state
var animations: PackedStringArray = PackedStringArray()
var collision: KinematicCollision2D = null
var initial_point: Vector2 = Vector2.ZERO
var attacking: bool = false
var dash_effect: AnimatedSprite2D
	
func is_valid_state(value: int) -> bool:
	return value in BatStates.values()
	
func is_current_state(state: int) -> bool:
	return state == current_state
	
func get_current_state() -> int:
	return current_state
	
func set_current_state(new_state: int) -> void:
	if is_valid_state(new_state):
		current_state = new_state
		
func is_inactive() -> bool:
	return is_current_state(BatStates.DEAD) or is_current_state(BatStates.SLEEP)
		
func change_direction() -> void:
	current_direction = current_direction * -1
	
func _ready() -> void:
	super._ready()
	_setup_components()
	_initialize_bat()

func _setup_components() -> void:
	super._setup_components()
	knockback_component = $KnockbackComponent
	animator = $Animator
	audio_controller = $AudioController
	movement_controller = $MovementController
	hitbox_component = $HitboxComponent
	
	animations = animator.sprite_frames.get_animation_names()
	
	var original_material : Material = animator.material
	animator.material = original_material.duplicate()

func _initialize_bat() -> void:
	initial_point = Vector2(global_position.x, global_position.y + 10)
	play_animation(BatStates.keys()[current_state].to_lower())
	if current_state == BatStates.FLY:
		movement_component.enabled = true
	
func _process(delta: float) -> void:
	if is_inactive(): return
	super._process(delta)
	animator.flip_h = current_direction == 1
	if current_cooldown > 0:
		current_cooldown -= delta
	if attacking:
		set_current_state(BatStates.ATTACK)
		show_dash_effect()
	else:
		set_current_state(BatStates.FLY)
	_update_state_behavior(delta)

func _physics_process(delta: float) -> void:
	_handle_movement()

func _handle_movement() -> void:
	if not movement_controller:
		return
	
	velocity = movement_controller.get_combined_velocity()
	
	if velocity.x != 0 and not _is_being_knocked_back():
		var new_direction = GameConstants.velocity_to_direction(velocity.x)
		set_direction(new_direction)
	
	move_and_slide()

func _is_being_knocked_back() -> bool:
	return knockback_component and knockback_component.is_enabled()
	
func apply_hurt_effect() -> void:
	var material: ShaderMaterial = animator.material
	material.set_shader_parameter("flash_amount", 1)
	await get_tree().create_timer(0.5).timeout
	material.set_shader_parameter("flash_amount", 0.0)
	
func die(damage_info: Dictionary) -> void:
	set_current_state(BatStates.DEAD)
	movement_component.enabled = false
	play_animation("die")
	apply_hurt_effect()
	
func show_dash_effect() -> void:
	if not dash_effect or dash_effect.position.distance_to(position) > 20:
		dash_effect = BAT_DASH.instantiate()
		get_parent().add_child(dash_effect)
		dash_effect.position = position - (Vector2(5, 0) * current_direction)
		
func dash_finished() -> void:
	attack_area.reset_attacked_entities()
	
func play_attack_sound() -> void:
	audio_controller.play_sound("Scream")
	
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
	if current_state == BatStates.SLEEP:
		set_current_state(BatStates.FLY)
		movement_component.enabled = true
		play_animation("fly")
	
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
