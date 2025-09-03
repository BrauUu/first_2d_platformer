extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_controller: AudioController = $AudioController

var explosion_area: int
var damage: int
var show_preview: bool

func _ready() -> void:
	set_show_preview_area(true)
	audio_controller.play_sound("Explosion")
	if collision_shape_2d.shape.radius:
		collision_shape_2d.shape.radius = explosion_area
		
func _draw():
	if show_preview:
		draw_circle(Vector2.ZERO, explosion_area, "#fb705d50")

func set_show_preview_area(value: bool):
	show_preview = value
	queue_redraw()

func get_damage() -> Dictionary:
	return {
		"damage": damage,
		"knockback_force": 100,
		"source": self,
		"death_cause": "KABOOM!!"
	}
