extends Area2D
class_name DeadZone

@export var damage : int

func _ready() -> void:
	damage = 10000

func get_damage() -> Dictionary:
	return {
		"damage": damage,
		"knockback_force": 0,
		"not_play_animation": true,
		"source": self,
		"death_cause": "You tested gravity. Gravity won."
	}
