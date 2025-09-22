extends Enemy

@onready var exclamation: AnimatedSprite2D = $Exclamation
@onready var player_detector: Area2D = $PlayerDetector
@onready var give_up_countdown: Timer = $GiveUpCountdown
@onready var vision_detector: Area2D = $VisionDetector

const BOMB_ENTITY = preload("res://entities/itens/bomb/Bomb.tscn")

const VISION_DETECTOR_OFFSET: Dictionary = {
	"position": Vector2(0, 0),
	"rotation": 180
}
const EXCLAMATION_OFFSET: Dictionary = {
	"position": Vector2(6, 0),
	"rotation": 0
}

enum BomberGoblinState {
	IDLE,
	ATTACK,
	DEATH
}

var current_state: BomberGoblinState = BomberGoblinState.IDLE
var previous_state: BomberGoblinState

var animations : PackedStringArray
var target : Player

func set_animation(animation: String) -> void:
	if animation in animations:
		animator.animation = animation
		
func _ready() -> void:
	super()
	_setup_components()
	_connect_signals()

func _setup_components() -> void:
	super()
	animator = $Animator
	audio_controller = $AudioController
	movement_controller = $MovementController
	hitbox_component = $HitboxComponent
	
	var original_material = animator.material
	animator.material = original_material.duplicate()
	
	animations = animator.sprite_frames.get_animation_names()
	
func _connect_signals() -> void:
	player_detector.connect("body_detected", _on_player_detected)
	player_detector.connect("body_lost_detection", _on_player_lost_detection)
	player_detector.connect("body_out_of_sight", _on_player_out_of_sight)
	
func _process(delta: float) -> void:
	super(delta)
	
	if target:
		look_for_player(target)
	
	_update_state_behavior(delta)
	animator.play()

func _physics_process(delta: float) -> void:
	_handle_movement()
	_apply_gravity(delta)

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

func _is_being_knocked_back() -> bool:
	return knockback_component and knockback_component.is_enabled()
	
func set_invulnerability(layer: int, invulnerable: bool) -> void:
	hitbox_component.set_collision_mask_value(layer, !invulnerable)
	
func is_invunerable(layer: int = 2) -> bool:
	return !hitbox_component.get_collision_mask_value(layer)

func attack() -> void:
	if current_cooldown <= 0 and target:
		set_animation("attack")
		audio_controller.play_sound("Yell")
		current_cooldown = attack_cooldown
		
func throw_bomb() -> void:
	var bomb = BOMB_ENTITY.instantiate()
	bomb.velocity = get_bomb_arch(position, target.position, 0.4)
	bomb.explosion_area = 30
	bomb.damage = damage
	bomb.position = position
	get_parent().add_child(bomb)
	
func get_bomb_arch(start: Vector2, target: Vector2, time: float = 0.5):
	var displacement = target - start
	return Vector2(
		displacement.x / time, 
		(displacement.y - 0.5 * get_gravity().y * time ** 2) / time
	)
	
func hurt(damage_info) -> void:
	audio_controller.play_sound("Hurt")
	set_invulnerability(2, true)
	if damage_info.source is Player:
		look_for_player(damage_info.source)
	await apply_hurt_effect()
	set_invulnerability(2, false)
	
func apply_hurt_effect() -> void:
	var material : ShaderMaterial = animator.material
	material.set_shader_parameter("flash_amount", 1)
	await get_tree().create_timer(0.5).timeout
	material.set_shader_parameter("flash_amount", 0.0)
	
func look_for_player(player: Player) -> void:
	if player.global_position.x > global_position.x:
		set_direction(GameConstants.Direction.RIGHT)
	else:
		set_direction(GameConstants.Direction.LEFT)

func set_direction(new_direction: GameConstants.Direction) -> void:
	super(new_direction)
	_update_sprite_direction()

func _update_sprite_direction() -> void:
	super()
	animator.flip_h = (current_direction == GameConstants.Direction.LEFT)
	_update_directional_elements()

func _update_directional_elements() -> void:
	_position_vision_detector()
	_position_exclamation()

func _position_vision_detector() -> void:
	if vision_detector:
		vision_detector.position.x = VISION_DETECTOR_OFFSET.position.x * current_direction
		_apply_rotation_to_detector(vision_detector, VISION_DETECTOR_OFFSET.rotation)

func _position_exclamation() -> void:
	if exclamation:
		exclamation.position.x = EXCLAMATION_OFFSET.position.x * current_direction

func _apply_rotation_to_detector(detector: Node2D, left_rotation: float) -> void:
	if current_direction == GameConstants.Direction.LEFT:
		detector.rotation = deg_to_rad(left_rotation)
	else:
		detector.rotation = 0.0
		
func die(damage_info) -> void:
	change_state(BomberGoblinState.DEATH)

func _update_state_behavior(delta: float) -> void:
	match current_state:
		BomberGoblinState.IDLE:
			_handle_idle_state(delta)
		BomberGoblinState.ATTACK:
			_handle_attack_state(delta)

func change_state(new_state: BomberGoblinState) -> void:
	if new_state == current_state:
		return
	
	_exit_current_state()
	previous_state = current_state
	current_state = new_state
	_enter_new_state()

func _exit_current_state() -> void:
	match current_state:
		BomberGoblinState.ATTACK:
			_exit_attack_state()

func _enter_new_state() -> void:
	match current_state:
		BomberGoblinState.ATTACK:
			_enter_attack_state()
		BomberGoblinState.DEATH:
			_enter_death_state()

func _enter_attack_state() -> void:
	audio_controller.play_sound("Yell")
	
	if exclamation:
		exclamation.show_warning()
	
	if GameManager:
		GameManager.emit_player_entered_battle()
		
func _handle_attack_state(delta: float) -> void:
	attack()

func _enter_death_state() -> void:
	set_animation("die")
	apply_hurt_effect()
	
	if audio_controller:
		audio_controller.play_sound("Die")
	
	if exclamation and exclamation.visible:
		exclamation.hide_warning(false)

func _handle_idle_state(delta: float) -> void:
	set_animation("idle")

func _exit_attack_state() -> void:
	if audio_controller:
		audio_controller.play_sound("GiveUp")
	
	if exclamation:
		exclamation.hide_warning()
	
	if GameManager:
		GameManager.emit_player_left_battle()
		
func _on_player_detected(player: Player) -> void:
	give_up_countdown.stop()
	target = player
	change_state(BomberGoblinState.ATTACK)
	
func _on_player_lost_detection(player: Player) -> void:
	target = null
	set_direction(initial_direction)
	change_state(BomberGoblinState.IDLE)
	
func _on_player_out_of_sight() -> void:
	give_up_countdown.start()

func _on_animator_animation_finished() -> void:
	match animator.animation:
		"die":
			queue_free()
		"attack":
			set_animation("idle")

func _on_animator_frame_changed() -> void:
	if animator.animation == "attack" and animator.frame == 4:
		throw_bomb()

func _on_give_up_countdown_timeout() -> void:
	_on_player_lost_detection(target)
