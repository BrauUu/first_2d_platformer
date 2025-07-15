class_name Player extends CharacterBody2D

const DUST_EFFECT_ON_JUMP := preload("res://entities/effects/dust_effect_on_jump/dust_effect_on_jump.tscn")
const ATTACK := preload("res://entities/actions/attack/attack.tscn")

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var hitbox_component: Area2D = $HitboxComponent

const MAX_JUMPS := 2
const DEADZONE := 0.05

@export var jump_power := 260
@export var force := 150
@export var health := 5
@export var speed := 100
@export var damage := 1
@export var cooldown := 0.2
@export var is_controllable := true

var current_cooldown : float = 0
var jump_count := 0
var direction : float = 0.0
var interaction_direction : int = 0
var is_interacting : bool = false

var can_move : bool = true

func set_animation(animation: String) -> void:
	if animation in animator.sprite_frames.get_animation_names():
		animator.animation = animation
		
func _input(event: InputEvent) -> void:
	if is_controllable:
		state_machine.handle_input(event)

func _process(delta: float) -> void:
	
	if direction:
		animator.flip_h = direction < 0

	animator.play()
	
	if current_cooldown > 0:
		current_cooldown -= delta

func _physics_process(delta: float) -> void:
	
	if can_move and is_controllable:
		direction = Input.get_axis("move_left", "move_right")
		if abs(direction) < DEADZONE:
			direction = 0.0
		else:
			direction = sign(direction)
			
		if not is_interacting:
			velocity.x = direction * speed
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		if jump_count != 2:
			if velocity.y > 0:
				set_animation("jump_down")
			else:
				set_animation("jump_up")
		else:
			set_animation("double_jump")
		move_and_slide()
		
		if is_on_floor():
			spawn_dust_effect("after_jump_dust")
			jump_count = 0

	else:
		move_and_slide()

func spawn_dust_effect(animation: String) -> void:
	var dust = DUST_EFFECT_ON_JUMP.instantiate()
	if animation in dust.sprite_frames.get_animation_names():
		dust.animation = animation
	get_parent().add_child(dust)
	dust.position = position
	
func can_execute_attack() -> bool:
	if current_cooldown > 0:
		return false
	spawn_attack_effect()
	current_cooldown = cooldown
	return true

func can_execute_jump() -> bool:
	if is_on_floor():
		spawn_dust_effect("before_jump_dust")
	return jump_count < MAX_JUMPS
	
func set_invulnerability(layer: int, invulnerable: bool) -> void:
	hitbox_component.set_collision_mask_value(layer, !invulnerable)

func hurt(damage_info: Dictionary) -> void: 
	GameManager.notify_player_hurted(damage_info)
	if not damage_info.source is DeadZone:
		set_invulnerability(4, true)
	await apply_hurt_effect()
	set_invulnerability(4, false)
		
func apply_hurt_effect() -> void:
	for i in 3:
		modulate = Color("#ffffff78")
		await get_tree().create_timer(0.25).timeout
		modulate = Color("#ffffff")
		await get_tree().create_timer(0.1).timeout

func die(damage_info: Dictionary) -> void:
	state_machine.change_state("Death", {"damage_info" : damage_info})
	GameManager.notify_player_dead(damage_info)

func spawn_attack_effect() -> void:
	var local_attack = ATTACK.instantiate()
	add_child(local_attack)
	local_attack.damage = damage
	local_attack.attack_effect.flip_h = $AnimatedSprite2D.flip_h
	local_attack.position = Vector2(-15 if $AnimatedSprite2D.flip_h else 15, -1)
	
func start_interaction() -> void:
	state_machine.push_state("Interact")
	
func finish_interaction() -> void:
	state_machine.pop_state()

func spawn(spawn_position: Vector2) -> void:
	position = spawn_position
	
func move(dir: int = 1) -> void:
	direction = dir
	velocity.x = direction * speed
	
func stop(dir: int = 0) -> void:
	direction = dir
	velocity.x = 0
	
func force_jump() -> void:
	state_machine.push_state("Jump")

func quit_game() -> void:
	direction = -1
	velocity.x = direction * speed

func _on_animated_sprite_2d_animation_finished() -> void:
	match animator.animation:
		"die":
			queue_free()
		"attack":
			state_machine.pop_state()
