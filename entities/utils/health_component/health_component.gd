extends Node
class_name HealthComponent

@export var parent : CharacterBody2D

var health : int
var current_health : int

signal health_updated(current_health: int)

func _ready() -> void:
	health = parent.health
	current_health = health
	
	if parent is Player:
		GameManager.connect("gm_player_recovery_health", apply_heal)

func apply_damage(damage_info: Dictionary) -> void:
	var damage = damage_info.damage
	current_health -= damage
	emit_signal("health_updated", current_health)
	
	if current_health <= 0:
		current_health = 0
		if parent.has_method("die"):
			parent.die(damage_info)
			
	else:
		if parent.has_method("hurt"):
			parent.hurt(damage_info)
			
func apply_heal(health_amount: int) -> void:
	current_health += health_amount
	emit_signal("health_updated", current_health)
	
	if current_health > health:
		current_health = health
