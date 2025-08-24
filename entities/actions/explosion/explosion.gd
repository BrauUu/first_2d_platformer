extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var explosion_area : int
var damage : int

func _ready() -> void:
	if collision_shape_2d.shape.radius:
		collision_shape_2d.shape.radius = explosion_area

func get_damage() -> Dictionary:
	return {
		"damage": damage,
		"knockback_force": 0,
		"source": self,
		"death_cause": "EXPLOSION"
	}
