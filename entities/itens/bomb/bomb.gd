class_name Bomb
extends CharacterBody2D

@onready var animator: AnimatedSprite2D = $Animator
@onready var audio_controller: AudioController = $AudioController

const EXPLOSION = preload("res://entities/actions/explosion/explosion.tscn")

@export var explosion_area : int
var damage : int

enum BOMB_STATES {THROWN, DROPPED}

var current_state: int
var animations: PackedStringArray
var show_preview: bool

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
	audio_controller.play_sound("Wick")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor():
		if is_current_state(BOMB_STATES.THROWN):
			set_current_state(BOMB_STATES.DROPPED)
			audio_controller.play_sound("Drop")
		if velocity.x:
			velocity.x = 0
		
	move_and_slide()
	
func _draw():
	if show_preview:
		draw_circle(Vector2.ZERO, explosion_area, "#dadada50")

func set_show_preview_area(value: bool):
	show_preview = value
	queue_redraw()

func _on_animator_frame_changed() -> void:
	if animator.animation != "dropped" : return
	if animator.frame == 1:
		set_show_preview_area(true)
	if animator.frame == 5:
		audio_controller.stop_sound("Wick")
		set_show_preview_area(false)
		var explosion = EXPLOSION.instantiate()
		explosion.explosion_area = explosion_area
		explosion.damage = damage
		add_child(explosion)
		var sprite : AnimatedSprite2D = explosion.get_node("AnimatedSprite2D")
		await sprite.animation_finished
		queue_free()
