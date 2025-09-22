class_name HealItem
extends CharacterBody2D

@export var interaction_area: Area2D
@export var audio_controller: AudioController
@export var animated_sprite_2d: AnimatedSprite2D

@export var heal_amount : int 

func _ready() -> void:
	animated_sprite_2d.play("dropped")

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	GameManager.recovery_health(heal_amount)
	audio_controller.play_sound("Collect")
	animated_sprite_2d.play("collected")
	await animated_sprite_2d.animation_finished
	queue_free()
