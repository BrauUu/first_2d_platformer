extends Attack
class_name PlayerAttack

@onready var attack_effect = $AttackEffect
@export var damage : int

func _ready() -> void:
	await attack_effect.animation_finished
	queue_free()

func get_damage() -> Dictionary:
	return {
		"damage": damage,
		"knockback_force": 200,
		"source": self.get_parent(),
		"position": {
			"x": global_position.x,
			"y": global_position.y
		},
		"death_cause": ""
	}
