class_name Treasure
extends CharacterBody2D

var current_state: int
var animations: PackedStringArray

@export var animator: AnimatedSprite2D
@export var interaction_area: Area2D
@export var audio_controller: AudioController

enum TREASURE_STATES {DROPPING, DROPPED, COLLECTED}

func update_animation() -> void:
	var animation = TREASURE_STATES.keys()[current_state].to_lower()
	if animation in animations:
		animator.play(animation)
	
func is_valid_treasure_state(value: int) -> bool:
	return value in TREASURE_STATES.values()
	
func is_current_state(state: int) -> bool:
	return state == current_state
	
func get_current_state() -> int:
	return current_state
	
func set_current_state(new_state: int) -> void:
	if is_valid_treasure_state(new_state):
		current_state = new_state
		
func _ready() -> void:
	set_current_state(TREASURE_STATES.DROPPING)
	animations = animator.sprite_frames.get_animation_names()
	animator.play("dropped")
	animator.connect("animation_finished", _on_animation_finished)
	
func collect() -> void:
	audio_controller.play_sound("Collect")
	set_current_state(TREASURE_STATES.COLLECTED)
	update_animation()
	
func _process(delta: float) -> void:
	if is_on_floor():
		if not interaction_area.has_connections("body_entered"):
			interaction_area.connect("body_entered", _on_interaction_area_body_entered)
			for body in interaction_area.get_overlapping_bodies():
				_on_interaction_area_body_entered(body)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and is_current_state(TREASURE_STATES.DROPPED):
		velocity += get_gravity() * delta
			
	move_and_slide()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is Player and is_current_state(TREASURE_STATES.DROPPED):
		collect()

func _on_animation_finished() -> void:
	if is_current_state(TREASURE_STATES.COLLECTED):
		#TODO: remover todo o tesouro (path)
		queue_free()
