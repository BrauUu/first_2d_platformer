@tool
extends CharacterBody2D
class_name Goblin

const MAX_JUMPS: int = 1
const PLAYER_ATTACK_LAYER: int = GameConstants.LAYER_PLAYER_ATTACKS
const HURT_FLASH_AMOUNT: float = 1.0
const NO_FLASH_AMOUNT: float = 0.0

const ATTACK_OFFSET: Dictionary = {
	"position": Vector2(8, 0),
	"rotation": 0
	}
const GROUND_DETECTOR_OFFSET: Dictionary = {
	"position": Vector2(4, 0),
	"rotation": 0
	}
const VISION_DETECTOR_OFFSET: Dictionary = {
	"position": Vector2(0, 0),
	"rotation": 180
	}
const EXCLAMATION_OFFSET: Dictionary = {
	"position": Vector2(6, 0),
	"rotation": 180
	}
const WALL_DETECTOR_OFFSET: Dictionary = {
	"position": Vector2(0, 0),
	"rotation": 180
	}

@export_group("Combat")
@export var damage: int = 10
@export var attack_cooldown: float = 1.0
@export var health: int = 50

@export_group("Movement") 
@export var speed: int = 100
@export var jump_power: int = 400
@export var initial_direction: GameConstants.Direction = GameConstants.Direction.RIGHT: set = _set_initial_direction

@onready var animator: AnimatedSprite2D = $Animator
@onready var attack_area: Attack = $Attack
@onready var attack_shape: CollisionShape2D = $Attack/AttackShape
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var vision_detector: Area2D = $VisionDetector
@onready var exclamation: AnimatedSprite2D = $Exclamation
@onready var wall_detector: Node2D = $WallDetector
@onready var follow_movement: FollowMovement = $FollowMovement
@onready var movement_controller: MovementController = $MovementController
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var state_machine: StateMachine = $StateMachine
@onready var hitbox_component: Area2D = $HitboxComponent
@onready var audio_controller: AudioController = $AudioController

var current_direction: GameConstants.Direction
var current_attack_cooldown: float = 0.0
var jump_count: int = 0
var is_on_fake_terrain: bool = false
var available_animations: PackedStringArray
var hurt_material: ShaderMaterial

func _ready() -> void:
	if Engine.is_editor_hint():
		_setup_editor_mode()
		return
	
	_initialize_goblin()
	_setup_components()
	_connect_signals()

func _set_initial_direction(value: GameConstants.Direction) -> void:
	initial_direction = value
	if Engine.is_editor_hint():
		current_direction = initial_direction
		_update_sprite_direction_editor()

func _setup_editor_mode() -> void:
	current_direction = initial_direction
	_update_sprite_direction_editor()

func _update_sprite_direction_editor() -> void:
	var anim = get_node_or_null("Animator")
	if anim and current_direction:
		anim.flip_h = (current_direction == GameConstants.Direction.LEFT)
	_update_directional_elements_editor()

func _initialize_goblin() -> void:
	current_direction = initial_direction
	current_attack_cooldown = 0.0
	jump_count = 0

func _setup_components() -> void:
	
	available_animations = animator.sprite_frames.get_animation_names()
	
	hurt_material = animator.material.duplicate()
	animator.material = hurt_material
	
	_update_sprite_direction()

func _connect_signals() -> void:
	
	animator.animation_finished.connect(_on_animation_finished)

func play_animation(animation_name: String) -> bool:
	
	if animation_name not in available_animations:
		push_warning("Goblin: Animation '%s' not found" % animation_name)
		return false
	
	animator.animation = animation_name
	animator.play()
	return true
	
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_update_attack_cooldown(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_handle_movement()
	_apply_gravity(delta)
	_handle_landing()

func _update_attack_cooldown(delta: float) -> void:
	if current_attack_cooldown > 0:
		current_attack_cooldown -= delta

func _handle_movement() -> void:
	if not movement_controller:
		return
	
	var combined_velocity = movement_controller.get_combined_velocity()
	velocity.x = combined_velocity.x
	
	if velocity.x != 0 and not _is_being_knocked_back():
		var new_direction = GameConstants.velocity_to_direction(velocity.x)
		set_direction(new_direction)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()

func _handle_landing() -> void:
	if is_on_floor() and jump_count > 0:
		jump_count = 0

func _is_being_knocked_back() -> bool:
	return knockback_component and knockback_component.is_enabled()
	
func jump() -> bool:
	if not _can_jump():
		return false
	
	velocity.y = -jump_power
	jump_count += 1
	play_animation("jump")
	return true

func _can_jump() -> bool:
	if not is_on_floor():
		return false
	
	if jump_count >= MAX_JUMPS:
		return false
	
	if _is_being_knocked_back():
		return false
	
	if _is_in_death_state():
		return false
	
	return true

func _is_in_death_state() -> bool:
		
	var current_state = state_machine.get_current_state()
	return current_state and current_state is EnemyDeathState

func set_direction(new_direction: GameConstants.Direction) -> void:
	if new_direction == current_direction:
		return
	
	current_direction = new_direction
	_update_sprite_direction()

func _update_sprite_direction() -> void:
	if animator:
		animator.flip_h = (current_direction == GameConstants.Direction.LEFT)
	_update_directional_elements()

func get_direction() -> GameConstants.Direction:
	return current_direction

func _update_directional_elements() -> void:
	_position_attack_area()
	_position_ground_detector()
	_position_vision_detector()
	_position_exclamation()
	_position_wall_detector()

func _update_directional_elements_editor() -> void:
	_position_attack_area_editor()
	_position_ground_detector_editor()
	_position_vision_detector_editor()
	_position_exclamation_editor()
	_position_wall_detector_editor()

func _position_attack_area() -> void:
	if attack_area:
		attack_area.position.x = ATTACK_OFFSET.position.x * current_direction

func _position_ground_detector() -> void:
	if ground_detector:
		ground_detector.position.x = GROUND_DETECTOR_OFFSET.position.x * current_direction
		_apply_rotation_to_detector(ground_detector, GROUND_DETECTOR_OFFSET.rotation)

func _position_vision_detector() -> void:
	if vision_detector:
		vision_detector.position.x = VISION_DETECTOR_OFFSET.position.x * current_direction
		_apply_rotation_to_detector(vision_detector, VISION_DETECTOR_OFFSET.rotation)

func _position_exclamation() -> void:
	if exclamation:
		exclamation.position.x = EXCLAMATION_OFFSET.position.x * current_direction

func _position_wall_detector() -> void:
	if wall_detector:
		wall_detector.position.x = WALL_DETECTOR_OFFSET.position.x * current_direction
		_apply_rotation_to_detector(wall_detector, WALL_DETECTOR_OFFSET.rotation)

# Editor-safe versions (using get_node_or_null)
func _position_attack_area_editor() -> void:
	var attack = get_node_or_null("Attack")
	if attack:
		attack.position.x = ATTACK_OFFSET.position.x * current_direction

func _position_ground_detector_editor() -> void:
	var detector = get_node_or_null("GroundDetector")
	if detector:
		detector.position.x = GROUND_DETECTOR_OFFSET.position.x * current_direction
		_apply_rotation_to_detector_editor(detector, GROUND_DETECTOR_OFFSET.rotation)

func _position_vision_detector_editor() -> void:
	var detector = get_node_or_null("VisionDetector")
	if detector:
		detector.position.x = VISION_DETECTOR_OFFSET.position.x * current_direction
		_apply_rotation_to_detector_editor(detector, VISION_DETECTOR_OFFSET.rotation)

func _position_exclamation_editor() -> void:
	var excl = get_node_or_null("Exclamation")
	if excl:
		excl.position.x = EXCLAMATION_OFFSET.position.x * current_direction

func _position_wall_detector_editor() -> void:
	var detector = get_node_or_null("WallDetector")
	if detector:
		detector.position.x = WALL_DETECTOR_OFFSET.position.x * current_direction
		_apply_rotation_to_detector_editor(detector, WALL_DETECTOR_OFFSET.rotation)

func _apply_rotation_to_detector(detector: Node2D, left_rotation: float) -> void:
	
	if current_direction == GameConstants.Direction.LEFT:
		detector.rotation = deg_to_rad(left_rotation)
	else:
		detector.rotation = 0.0


func _apply_rotation_to_detector_editor(detector: Node2D, left_rotation: float) -> void:
	
	if current_direction == GameConstants.Direction.LEFT:
		detector.rotation = deg_to_rad(left_rotation)
	else:
		detector.rotation = 0.0

func set_invulnerability(layer: int, invulnerable: bool) -> void:
	if not hitbox_component:
		push_warning("Goblin: No hitbox component found")
		return
	
	hitbox_component.set_collision_mask_value(layer, not invulnerable)

func is_invulnerable(layer: int = PLAYER_ATTACK_LAYER) -> bool:
	if not hitbox_component:
		return false
	
	return not hitbox_component.get_collision_mask_value(layer)
		
func attack() -> bool:
	if not _can_attack():
		return false
	
	current_attack_cooldown = attack_cooldown
	play_animation("attack")
	
	if audio_controller:
		audio_controller.play_sound("Attack")
	
	if attack_shape:
		attack_shape.disabled = false
	
	if state_machine:
		state_machine.push_state("Attack")
	
	return true

func _can_attack() -> bool:
	if current_attack_cooldown > 0:
		return false
	
	if _is_in_death_state():
		return false
	
	return true

func finish_attack() -> void:
	if state_machine:
		state_machine.pop_state()
	
	if attack_shape:
		attack_shape.disabled = true
	
	if attack_area:
		attack_area.reset_attacked_entities()

func get_damage() -> Dictionary:
	return {
		"amount": damage,
		"source": self,
		"type": "goblin_attack"
	}
	
func hurt(damage_info: Dictionary) -> void:
	if not damage_info:
		return
	
	if audio_controller:
		audio_controller.play_sound("Hurt")
	
	current_attack_cooldown = attack_cooldown
	
	var attacker = damage_info.get("source")
	if attacker:
		_face_towards_attacker(attacker)
	
	set_invulnerability(PLAYER_ATTACK_LAYER, true)
	await _apply_hurt_visual_effect()
	set_invulnerability(PLAYER_ATTACK_LAYER, false)

func _apply_hurt_visual_effect() -> void:
	
	hurt_material.set_shader_parameter("flash_amount", HURT_FLASH_AMOUNT)
	
	if knockback_component:
		await knockback_component.knockback_ended
	
	hurt_material.set_shader_parameter("flash_amount", NO_FLASH_AMOUNT)

func _face_towards_attacker(attacker: Node2D) -> void:
	if not attacker:
		return
	
	var direction_to_attacker = GameConstants.position_to_direction(global_position, attacker.global_position)
	set_direction(direction_to_attacker)

func start_following() -> void:
	if not state_machine:
		return
	
	var current_state = state_machine.get_current_state()
	
	if current_state and (current_state is EnemyChaseState or current_state is EnemyAttackState):
		return
	
	state_machine.change_state("Chase")
	
	if audio_controller:
		audio_controller.play_sound("Yell")
	
	if exclamation:
		exclamation.show_warning()
	
	if GameManager:
		GameManager.emit_player_entered_battle()
	
	current_attack_cooldown = attack_cooldown

func stop_following() -> void:
	if not state_machine:
		return
	
	state_machine.change_state("Idle")
	
	if audio_controller:
		audio_controller.play_sound("GiveUp")
	
	if exclamation:
		exclamation.hide_warning()
	
	GameManager.emit_player_left_battle()

func die(damage_info: Dictionary) -> void:

	if audio_controller:
		audio_controller.play_sound("Die")
	
	if follow_movement:
		follow_movement.enabled = false
	
	state_machine.change_state("Death", {"damage_info": damage_info})
	
	_apply_hurt_visual_effect()
	
	if exclamation and exclamation.visible:
		exclamation.hide_warning(false)
		

func set_is_on_fake_terrain(value: bool) -> void:
	is_on_fake_terrain = value

func get_health() -> int:
	return health

func is_alive() -> bool:
	return get_health() > 0 and not _is_in_death_state()

func _on_animation_finished() -> void:
	
	match animator.animation:
		"die":
			_handle_death_animation_finished()
		"attack":
			_handle_attack_animation_finished()

func _handle_death_animation_finished() -> void:
	queue_free()

func _handle_attack_animation_finished() -> void:
	finish_attack()
