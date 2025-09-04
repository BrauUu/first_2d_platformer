extends Enemy

@onready var animator: AnimatedSprite2D = $FlippedNode/Animator
@onready var flipped_node: Node2D = $FlippedNode
@onready var exclamation: AnimatedSprite2D = $FlippedNode/Exclamation
@onready var movement_controller: MovementController = $MovementController
@onready var state_machine: StateMachine = $StateMachine
@onready var hitbox_component: Area2D = $HitboxComponent
@onready var audio_controller: AudioController = $AudioController
@onready var player_detector: Area2D = $PlayerDetector
@onready var give_up_countdown: Timer = $GiveUpCountdown

const BOMB_ENTITY = preload("res://entities/itens/bomb/bomb.tscn")

var animations : PackedStringArray
var target : Player

func set_animation(animation: String) -> void:
	if animation in animations:
		animator.animation = animation
		
func _ready() -> void:
	direction = initial_direction
	flipped_node.scale.x = direction
	animations = animator.sprite_frames.get_animation_names()
	
	var original_material = animator.material
	animator.material = original_material.duplicate()
	
	player_detector.connect("body_detected", _on_player_detected)
	player_detector.connect("body_lost_detection", _on_player_lost_detection)
	player_detector.connect("body_out_of_sight", _on_player_out_of_sight)
	
func _process(delta: float) -> void:
	
	var combined_velocity = movement_controller.get_combined_velocity()
	velocity.x = combined_velocity.x
	
	if current_cooldown > 0:
		current_cooldown -= delta
	
	if target:
		look_for_player(target)
	
	animator.play()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	
func set_invulnerability(layer: int, invulnerable: bool) -> void:
	hitbox_component.set_collision_mask_value(layer, !invulnerable)
	
func is_invunerable(layer: int = 2) -> bool:
	return !hitbox_component.get_collision_mask_value(layer)

func attack() -> void:
	if current_cooldown <= 0 and target:
		set_animation("attack")
		audio_controller.play_sound("Yell")
		current_cooldown = cooldown
		
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
	if player.global_position > global_position:
		flipped_node.scale.x = 1
	else:
		flipped_node.scale.x = -1
		
func die(damage_info) -> void:
	audio_controller.play_sound("Die")
	state_machine.change_state("Death", {"damage_info" : damage_info})
	apply_hurt_effect()
	if exclamation.visible:
		exclamation.hide_warning(false)
		
		
func _on_player_detected(player: Player) -> void:
	give_up_countdown.stop()
	state_machine.change_state("Attack")
	audio_controller.play_sound("Yell")
	target = player
	GameManager.emit_player_entered_battle()
	
func _on_player_lost_detection(player: Player) -> void:
	state_machine.change_state("Idle")
	audio_controller.play_sound("GiveUp")
	target = null
	flipped_node.scale.x = initial_direction
	GameManager.emit_player_left_battle()
	
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
