extends Area2D
class_name EnemyAttack

@export var parent : CharacterBody2D

var damage : int

func _ready() -> void:
	damage = parent.damage

func get_damage() -> Dictionary:
	return {
		"damage": damage,
		"knockback_force": 100,
		"source": parent,
		"death_cause": "Turns out goblins do know how to use knives. Who knew?"
	}
