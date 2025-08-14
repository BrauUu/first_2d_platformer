@tool
extends Area2D

@export var width: float:
	set(value):
		width = value
		var sprite := $RepeatingSprite
		sprite.width = value
		update_collision_shape()

@export var height: float:
	set(value):
		height = value
		var sprite := $RepeatingSprite
		sprite.height = value
		update_collision_shape()

func update_collision_shape() -> void:
	var shape_node := $CollisionShape2D
	if shape_node.shape.resource_local_to_scene == false:
			shape_node.shape = shape_node.shape.duplicate()
	if shape_node and shape_node.shape is RectangleShape2D:
		shape_node.shape.size = Vector2(width, height)
		
