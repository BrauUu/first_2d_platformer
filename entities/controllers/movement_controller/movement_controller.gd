class_name MovementController extends Node

@export var movement_modules_data: Array[MovementModuleData] = []
var movement_modules := []

func _ready() -> void:
	for data in movement_modules_data:
		var mod = get_node_or_null(data.module)
		if mod and mod.has_method("get_motion_velocity"):
			movement_modules.append({ "module": mod, "priority": data.priority })
	
	movement_modules.sort_custom(_sort_by_priority)

func _sort_by_priority(a, b) -> int:
	return b.priority - a.priority
	
func get_combined_velocity() -> Vector2:
	var active_entries := []
	for entry in movement_modules:
		var mod = entry.module
		if mod.has_method("is_enabled") and not mod.is_enabled():
			continue
		active_entries.append(entry)

	if active_entries.is_empty():
		return Vector2.ZERO

	var max_priority : int = active_entries[0].priority

	var top_entries := []
	var velocity := Vector2.ZERO
	for entry in active_entries:
		if entry.priority == max_priority:
			top_entries.append(entry)
			velocity += entry.module.get_motion_velocity()

	return velocity
