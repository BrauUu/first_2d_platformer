class_name ConnectionActivator
extends Node

## When triggered will emit an signal to others objects with this "connection_id"
@export var connection_id : int = 0

var parent : Node2D

func _ready() -> void:
	parent = get_parent()
	if not connection_id:
		connection_id = parent.connection_id

func on_connection_actived() -> void:
	if connection_id:
		GameManager.notify_connection_activation(connection_id)
	
func on_connection_deactivated() -> void:
	if connection_id:
		GameManager.notify_connection_deactivation(connection_id)
