extends AnimatableBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var direction : int

signal door_closed
signal door_opened

func _ready() -> void:
	if direction == 1:
		animated_sprite_2d.flip_h = true

func open(show_animation: bool = true) -> void:
	if show_animation:
		animated_sprite_2d.play("open")
	else:
		collision_shape_2d.disabled = true
		animated_sprite_2d.play("opened")
	
	
func close(show_animation: bool = true) -> void:
	collision_shape_2d.disabled = false
	if show_animation:
		animated_sprite_2d.play("close")
	else:
		animated_sprite_2d.play("closed")
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "open":
		collision_shape_2d.disabled = true
		animated_sprite_2d.play("opened")
		door_opened.emit()
	elif animated_sprite_2d.animation == "close":
		animated_sprite_2d.play("closed")
		door_closed.emit()
