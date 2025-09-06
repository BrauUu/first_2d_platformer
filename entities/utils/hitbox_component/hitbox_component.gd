extends Node

@export var health_component : HealthComponent
@export var knockback_component : KnockbackComponent

func apply_damage(damage_info: Dictionary) -> void:
	if knockback_component:
		knockback_component.apply_knockback(damage_info)
	if health_component:
		health_component.apply_damage(damage_info)

func _on_area_entered(attack: Attack) -> void:
	var entity = get_parent()
	if not attack.entity_was_attacked(entity):
		attack.attacked_entity(entity)
		var damage_info = attack.get_damage()
		apply_damage(damage_info)
		
