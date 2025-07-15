class_name Enemy 
extends CharacterBody2D

@export var speed : int
@export var damage : int
@export var initial_direction : int
@export var jump_power : int
@export var cooldown : float

var current_cooldown : float
var direction : int

func set_state(state) -> void:
	assert(false, "Subclasses must override set_state")

func set_animation(animation: String) -> void:
	assert(false, "Subclasses must override set_animation")
		
#func _physics_process(delta: float) -> void:
	
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
