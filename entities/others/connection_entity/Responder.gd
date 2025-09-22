class_name ConnectionResponder
extends Node

@export var activation_function : String
@export var deactivation_function : String

@export var connection_id: int = 0

var parent : Node2D

func _ready() -> void:
	GameManager.connect("gm_notify_connection_activation", _on_connection_actived)
	GameManager.connect("gm_notify_connection_deactivation", _on_connection_deactivated)
	parent = get_parent()

func _on_connection_actived(outer_connection_id) -> void:
	if connection_id and outer_connection_id == connection_id:
		if parent.has_method(activation_function):
			parent.call_deferred(activation_function)
	
func _on_connection_deactivated(outer_connection_id) -> void:
	if connection_id and outer_connection_id == connection_id:
		if parent.has_method(deactivation_function):
			parent.call_deferred(deactivation_function)
