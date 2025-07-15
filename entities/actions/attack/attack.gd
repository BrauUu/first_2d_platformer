extends Area2D
class_name PlayerAttack

@onready var attack_effect = $AttackEffect
@export var damage : int

func _ready() -> void:
	await attack_effect.animation_finished
	queue_free()

func get_damage() -> Dictionary:
	return {
		"damage": damage,
		"knockback_force": 50,
		"source": self.get_parent(),
		"death_cause": ""
	}
