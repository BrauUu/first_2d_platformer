class_name ConnectedObject
extends Node

@export var activation_function : String
@export var desactivation_function : String

@export var connection_id: int

var parent : Node2D

func _ready() -> void:
	GameManager.connect("gm_notify_connection_activation", _on_connection_actived)
	GameManager.connect("gm_notify_connection_deactivation", _on_connection_deactivated)
	parent = get_parent()

func _on_connection_actived(outer_connection_id) -> void:
	if outer_connection_id == connection_id:
		parent.call_deferred(activation_function)
		
func _on_connection_deactivated(outer_connection_id) -> void:
	if outer_connection_id == connection_id:
		parent.call_deferred(desactivation_function)
