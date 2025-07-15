extends Node

@export var health_component : HealthComponent
@export var knockback_component : KnockbackComponent

func apply_damage(damage_info: Dictionary) -> void:
	if health_component:
		health_component.apply_damage(damage_info)
	if knockback_component:
		knockback_component.apply_knockback(damage_info)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_damage"):
		var damage_info = body.get_damage()
		apply_damage(damage_info)
	
func _on_area_entered(area: Area2D) -> void:
	if area.has_method("get_damage"):
		var damage_info = area.get_damage()
		apply_damage(damage_info)
