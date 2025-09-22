class_name Enemy
extends CharacterBody2D

const PLAYER_ATTACK_LAYER: int = GameConstants.LAYER_PLAYER_ATTACKS
const HURT_FLASH_AMOUNT: float = 1.0
const NO_FLASH_AMOUNT: float = 0.0

@export_group("Combat")
@export var damage: int = 10
@export var health: int = 50
@export var attack_cooldown: float = 1.0

@export_group("Movement")
@export var speed: int = 100
@export var jump_power: int = 400
@export var initial_direction: GameConstants.Direction = GameConstants.Direction.RIGHT : set = _set_initial_direction

var current_direction: GameConstants.Direction
var current_cooldown: float = 0.0
var available_animations: PackedStringArray
var hurt_material: ShaderMaterial
var is_on_fake_terrain: bool = false
var on_animation: bool = false

var animator: AnimatedSprite2D
var audio_controller: AudioController
var movement_controller: MovementController
var hitbox_component: Area2D
var knockback_component: KnockbackComponent

func attack() -> void:
	push_warning("Enemy: attack() should be overridden by subclass")
	
func die(damage_info: Dictionary) -> void:
	push_warning("Enemy: attack() should be overridden by subclass")
	
func _set_initial_direction(value: GameConstants.Direction) -> void:
	initial_direction = value

func _ready() -> void:
	_initialize_enemy()
	_setup_components()

func _initialize_enemy() -> void:
	current_direction = initial_direction
	current_cooldown = 0.0

func _setup_components() -> void:
	if animator and animator.sprite_frames:
		available_animations = animator.sprite_frames.get_animation_names()
	
	if animator and animator.material:
		hurt_material = animator.material.duplicate()
		animator.material = hurt_material

func _process(delta: float) -> void:
	_update_cooldown(delta)

func _update_cooldown(delta: float) -> void:
	if current_cooldown > 0:
		current_cooldown -= delta

func play_animation(animation_name: String) -> bool:
	if not animator:
		push_warning("Enemy: No animator found")
		return false
	
	if not has_animation(animation_name):
		push_warning("Enemy: Animation '%s' not found" % animation_name)
		return false
	
	animator.animation = animation_name
	animator.play()
	return true

func has_animation(animation_name: String) -> bool:
	return animation_name in available_animations

func set_direction(new_direction: GameConstants.Direction) -> void:
	if new_direction == current_direction:
		return
	
	current_direction = new_direction


func _update_sprite_direction() -> void:
	if animator:
		animator.flip_h = (current_direction == GameConstants.Direction.LEFT)

func get_direction() -> GameConstants.Direction:
	return current_direction

func face_towards_position(target_position: Vector2) -> void:
	var direction_to_target = GameConstants.position_to_direction(global_position, target_position)
	set_direction(direction_to_target)

func can_attack() -> bool:
	if current_cooldown > 0:
		return false
	
	if not is_alive():
		return false
	
	return true

func get_damage() -> Dictionary:
	return {
		"amount": damage,
		"source": self,
		"type": get_enemy_type()
	}

func get_enemy_type() -> String:
	return get_script().get_global_name().to_lower() + "_attack"

func hurt(damage_info: Dictionary) -> void:
	if not damage_info:
		return
		
	current_cooldown = attack_cooldown
	
	play_animation("hurt")
	
	var attacker = damage_info.get("source")
	if attacker and attacker is Node2D:
		face_towards_position(attacker.global_position)
	
	if audio_controller:
		audio_controller.play_sound("Hurt")
	
	set_invulnerability(GameConstants.LAYER_PLAYER_ATTACKS, true)
	await apply_hurt_effect()
	set_invulnerability(GameConstants.LAYER_PLAYER_ATTACKS, false)

func apply_hurt_effect() -> void:
	if not hurt_material:
		return
	
	hurt_material.set_shader_parameter("flash_amount", HURT_FLASH_AMOUNT)
	await await knockback_component.knockback_ended
	hurt_material.set_shader_parameter("flash_amount", NO_FLASH_AMOUNT)

func set_invulnerability(layer: int, invulnerable: bool) -> void:
	hitbox_component.set_collision_mask_value(layer, not invulnerable)

func is_invulnerable(layer: int = PLAYER_ATTACK_LAYER) -> bool:
	return not hitbox_component.get_collision_mask_value(layer)
	
func set_is_on_fake_terrain(value: bool) -> void:
	is_on_fake_terrain = value

func is_alive() -> bool:
	return health > 0

func get_health() -> int:
	return health

func set_health(new_health: int) -> void:
	health = max(0, new_health)
