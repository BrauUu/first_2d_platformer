@tool
extends Enemy
class_name Goblin

const MAX_JUMPS: int = 1

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
	"rotation": 0
	}
const WALL_DETECTOR_OFFSET: Dictionary = {
	"position": Vector2(0, 0),
	"rotation": 180
	}

@onready var attack_area: Attack = $Attack
@onready var attack_shape: CollisionShape2D = $Attack/AttackShape
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var vision_detector: Area2D = $VisionDetector
@onready var exclamation: AnimatedSprite2D = $Exclamation
@onready var wall_detector: Node2D = $WallDetector
@onready var follow_movement: FollowMovement = $FollowMovement

enum GoblinState {
	IDLE,
	CHASE,
	DEATH
}

var current_state: GoblinState = GoblinState.IDLE
var previous_state: GoblinState

var jump_count: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		_setup_editor_mode()
		return
	
	super()
	_setup_components()
	_initialize_goblin()
	_connect_signals()

func _set_initial_direction(value: GameConstants.Direction) -> void:
	super(value)
	if Engine.is_editor_hint():
		current_direction = initial_direction
		_update_sprite_direction_editor()
		
func _connect_signals() -> void:
	if animator and not animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.connect(_on_animation_finished)

func _initialize_goblin() -> void:
	jump_count = 0
	
func _setup_components() -> void:
	super()
	knockback_component = $KnockbackComponent
	animator = $Animator
	audio_controller = $AudioController
	movement_controller = $MovementController
	hitbox_component = $HitboxComponent

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): 
		return
	
	super(delta)
	
	_update_state_behavior(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): 
		return
		
	_handle_movement()
	_apply_gravity(delta)
	_handle_landing()

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
	
	if is_alive():
		return false
	
	return true
	
func set_direction(new_direction: GameConstants.Direction) -> void:
	super(new_direction)
	
	_update_sprite_direction()

func _update_state_behavior(delta: float) -> void:
	match current_state:
		GoblinState.IDLE:
			_handle_idle_state(delta)
		GoblinState.CHASE:
			_handle_chase_state(delta)

func change_state(new_state: GoblinState) -> void:
	if new_state == current_state:
		return
	
	_exit_current_state()
	previous_state = current_state
	current_state = new_state
	_enter_new_state()

func _exit_current_state() -> void:
	match current_state:
		GoblinState.CHASE:
			_exit_chase_state()

func _enter_new_state() -> void:
	match current_state:
		GoblinState.CHASE:
			_enter_chase_state()
		GoblinState.DEATH:
			_enter_death_state()
	
func _enter_chase_state() -> void:
	if audio_controller:
		audio_controller.play_sound("Yell")
	
	if exclamation:
		exclamation.show_warning()
	
	if GameManager:
		GameManager.emit_player_entered_battle()
	
	current_cooldown = attack_cooldown

func _enter_death_state() -> void:
	play_animation("die")
	apply_hurt_effect()
	
	if audio_controller:
		audio_controller.play_sound("Die")
	
	if follow_movement:
		follow_movement.enabled = false
	
	if exclamation and exclamation.visible:
		exclamation.hide_warning(false)

func _handle_idle_state(delta: float) -> void:
	if on_animation: return
	if velocity.x and not is_invulnerable():
		play_animation("move")
	else:
		play_animation("idle")

func _handle_chase_state(delta: float) -> void:
	if on_animation: return
	if velocity.x and not is_invulnerable():
		play_animation("move")
	else:
		play_animation("idle")

func _exit_chase_state() -> void:
	if audio_controller:
		audio_controller.play_sound("GiveUp")
	
	if exclamation:
		exclamation.hide_warning()
	
	if GameManager:
		GameManager.emit_player_left_battle()
		
func _setup_editor_mode() -> void:
	current_direction = initial_direction
	_update_sprite_direction_editor()
		
func _update_sprite_direction() -> void:
	super()
	animator.flip_h = (current_direction == GameConstants.Direction.LEFT)
	_update_directional_elements()
		
func _update_sprite_direction_editor() -> void:
	var anim = get_node_or_null("Animator")
	if anim and current_direction:
		anim.flip_h = (current_direction == GameConstants.Direction.LEFT)
	_update_directional_elements_editor()

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

func _position_attack_area_editor() -> void:
	var attack = get_node_or_null("Attack")
	if attack:
		attack.position.x = ATTACK_OFFSET.position.x * current_direction

func _position_ground_detector_editor() -> void:
	var detector = get_node_or_null("GroundDetector")
	if detector:
		detector.position.x = GROUND_DETECTOR_OFFSET.position.x * current_direction
		_apply_rotation_to_detector(detector, GROUND_DETECTOR_OFFSET.rotation)

func _position_vision_detector_editor() -> void:
	var detector = get_node_or_null("VisionDetector")
	if detector:
		detector.position.x = VISION_DETECTOR_OFFSET.position.x * current_direction
		_apply_rotation_to_detector(detector, VISION_DETECTOR_OFFSET.rotation)

func _position_exclamation_editor() -> void:
	var excl = get_node_or_null("Exclamation")
	if excl:
		excl.position.x = EXCLAMATION_OFFSET.position.x * current_direction

func _position_wall_detector_editor() -> void:
	var detector = get_node_or_null("WallDetector")
	if detector:
		detector.position.x = WALL_DETECTOR_OFFSET.position.x * current_direction
		_apply_rotation_to_detector(detector, WALL_DETECTOR_OFFSET.rotation)

func _apply_rotation_to_detector(detector: Node2D, left_rotation: float) -> void:
	
	if current_direction == GameConstants.Direction.LEFT:
		detector.rotation = deg_to_rad(left_rotation)
	else:
		detector.rotation = 0.0
		
func attack() -> void:
	if not can_attack(): return
	start_attack()

func start_attack() -> void:
	on_animation = true
	current_cooldown = attack_cooldown
	play_animation("attack")
	
	if audio_controller:
		audio_controller.play_sound("Attack")
	
	if attack_shape:
		attack_shape.disabled = false

func finish_attack() -> void:
	
	if attack_shape:
		attack_shape.disabled = true
	
	if attack_area:
		attack_area.reset_attacked_entities()
		
	on_animation = false

func start_following() -> void:
	if current_state == GoblinState.CHASE:
		return
	
	change_state(GoblinState.CHASE)

func stop_following() -> void:
	if current_state == GoblinState.DEATH:
		return
	
	change_state(GoblinState.IDLE)

func die(damage_info: Dictionary) -> void:
	change_state(GoblinState.DEATH)

func _on_animation_finished() -> void:
	match animator.animation:
		"die":
			queue_free()
		"attack":
			finish_attack()
