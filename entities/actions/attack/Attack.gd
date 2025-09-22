class_name Attack
extends Area2D

@export var should_use_attacked_entities : bool = false
var attacked_entities : Array = []

func attacked_entity(entity):
	if not attacked_entities.has(entity):
		attacked_entities.append(entity)
		
func entity_was_attacked(entity) -> bool:
	return attacked_entities.has(entity)
	
func reset_attacked_entities() -> void:
	attacked_entities = []
	
func get_damage() -> Dictionary:
	return get_parent().get_damage()
