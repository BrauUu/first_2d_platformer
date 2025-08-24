class_name Bomb
extends CharacterBody2D

@onready var animator: AnimatedSprite2D = $Animator
@onready var preview_area_shape: CollisionShape2D = $PreviewArea/PreviewAreaShape

const EXPLOSION = preload("res://entities/actions/explosion/explosion.tscn")

@export var explosion_area : int
var damage : int

enum BOMB_STATES {THROWN, DROPPED}

var current_state : int
var animations: PackedStringArray

func update_animation() -> void:
	var animation = BOMB_STATES.keys()[current_state].to_lower()
	if animation in animations:
		animator.play(animation)
	
func is_valid_state(value: int) -> bool:
	return value in BOMB_STATES.values()
	
func is_current_state(state: int) -> bool:
	return state == current_state
	
func get_current_state() -> int:
	return current_state
	
func set_current_state(new_state: int) -> void:
	if is_valid_state(new_state):
		current_state = new_state
		update_animation()
		
func _ready() -> void:
	set_current_state(BOMB_STATES.THROWN)
	animations = animator.sprite_frames.get_animation_names()
	update_animation()
	
	if preview_area_shape.shape.radius:
		preview_area_shape.shape.radius = explosion_area

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor():
		if is_current_state(BOMB_STATES.THROWN):
			set_current_state(BOMB_STATES.DROPPED)
		if velocity.x:
			velocity.x = 0
		
	move_and_slide()

func _on_animator_frame_changed() -> void:
	if animator.animation == "dropped" and animator.frame == 7:
		var explosion = EXPLOSION.instantiate()
		explosion.explosion_area = explosion_area
		explosion.damage = damage
		add_child(explosion)
		var sprite : AnimatedSprite2D = explosion.get_node("AnimatedSprite2D")
		await sprite.animation_finished
		queue_free()
