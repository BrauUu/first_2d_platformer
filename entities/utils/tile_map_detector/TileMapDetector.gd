class_name TileMapDetector
extends Area2D

enum TilesTypes { FakeTerrain, VegetationLayer }

@export var tile_type: TilesTypes

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if is_body_of_type(body):
		var entered_cell = body.get_coords_for_body_rid(body_rid)
		if entered_cell == null:
			return
		GameManager.notify_node_entered_layer(entered_cell, body)

func _on_body_exited(body: Node2D) -> void:
	if is_body_of_type(body):
		GameManager.notify_node_left_layer(body)

func is_body_of_type(body: Node) -> bool:
	match tile_type:
		TilesTypes.FakeTerrain:
			return body is FakeTerrain
		TilesTypes.VegetationLayer:
			return body is VegetationLayer
	return false
