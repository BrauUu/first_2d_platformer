extends Enemy

@onready var animator: AnimatedSprite2D = $FlippedNode/Animator
@onready var attack_area: Attack = $FlippedNode/Attack
@onready var attack_shape: CollisionShape2D = $FlippedNode/Attack/AttackShape
@onready var flipped_node: Node2D = $FlippedNode
@onready var follow_movement: FollowMovement = $FollowMovement
@onready var exclamation: AnimatedSprite2D = $FlippedNode/Exclamation
@onready var movement_controller: MovementController = $MovementController
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var state_machine: StateMachine = $StateMachine
@onready var hitbox_component: Area2D = $HitboxComponent
@onready var audio_controller: AudioController = $AudioController

const MAX_JUMPS := 1

var animations : PackedStringArray
var jump_count := 0
var is_on_fake_terrain : bool = false

func set_animation(animation: String) -> void:
	if animation in animations:
		animator.animation = animation

func _ready() -> void:
	direction = initial_direction
	flipped_node.scale.x = direction
	animations = animator.sprite_frames.get_animation_names()
	
	var original_material = animator.material
	animator.material = original_material.duplicate()
	
func _process(_delta: float) -> void:
	if current_cooldown > 0:
		current_cooldown -= _delta
	
	animator.play()
		
func _physics_process(delta: float) -> void:
	
	var combined_velocity = movement_controller.get_combined_velocity()
	velocity.x = combined_velocity.x
	
	if velocity.x and not knockback_component.is_enabled():
		direction = -1 if velocity.x < 0 else 1
		if flipped_node.scale.x!= direction:
			flipped_node.scale.x = direction
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		
		if is_on_floor():
			jump_count = 0
	else:
		move_and_slide()
	
func jump() -> void:
	if is_on_floor() and jump_count < MAX_JUMPS and not knockback_component.is_enabled() and not state_machine.get_current_state() is EnemyDeathState :
		velocity.y += -jump_power
		jump_count += 1
		
func set_invulnerability(layer: int, invulnerable: bool) -> void:
	hitbox_component.set_collision_mask_value(layer, !invulnerable)
	
func is_invunerable(layer: int = 2) -> bool:
	return !hitbox_component.get_collision_mask_value(layer)
		
func attack() -> void:
	if current_cooldown <= 0:
		set_animation('attack')
		audio_controller.play_sound("Attack")
		current_cooldown = cooldown
		state_machine.push_state("Attack")
		attack_shape.disabled = false
		
func finish_attack() -> void:
	state_machine.pop_state()
	attack_shape.disabled = true
	attack_area.reset_attacked_entities()
	
func hurt(damage_info) -> void:
	audio_controller.play_sound("Hurt")
	current_cooldown = cooldown
	look_for_player(damage_info.source)
	set_invulnerability(2, true)
	await apply_hurt_effect()
	set_invulnerability(2, false)
	
func apply_hurt_effect() -> void:
	var material : ShaderMaterial = animator.material
	material.set_shader_parameter("flash_amount", 1)
	await knockback_component.knockback_ended
	material.set_shader_parameter("flash_amount", 0.0)
	
func look_for_player(attacker: Node2D) -> void:
	if attacker.global_position > global_position:
		flipped_node.scale.x = 1
	else:
		flipped_node.scale.x = -1

func following() -> void:
	var actual_state = state_machine.get_current_state()
	if not actual_state is EnemyChaseState and not actual_state is EnemyAttackState:
		state_machine.change_state("Chase")
		audio_controller.play_sound("Yell")
		exclamation.show_warning()
		GameManager.emit_player_entered_battle()
		current_cooldown = cooldown
	
func stop_following() -> void:
	state_machine.change_state("Idle")
	GameManager.emit_player_left_battle()
	audio_controller.play_sound("GiveUp")
	exclamation.hide_warning()

func die(damage_info) -> void:
	audio_controller.play_sound("Die")
	follow_movement.enabled = false
	state_machine.change_state("Death", {"damage_info" : damage_info})
	apply_hurt_effect()
	if exclamation.visible:
		exclamation.hide_warning(false)
		
func set_direction(dir: int) -> void:
	direction = dir
	if flipped_node.scale.x!= direction:
		flipped_node.scale.x = direction
		
func set_is_on_fake_terrain(value: bool) -> void:
	is_on_fake_terrain = value

func _on_animated_sprite_2d_animation_finished() -> void:
	match animator.animation:
		"die":
			queue_free()
		"attack":
			finish_attack()
