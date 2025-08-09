class_name VegetationLayer
extends TileMapLayer

const CROPPEDS_COORDS = {
	Vector2i(0,0) : Vector2i(4,3),
	Vector2i(0,3) : Vector2i(4,3),
	Vector2i(0,1) : Vector2i(5,3),
	Vector2i(1,3) : Vector2i(5,3),
	Vector2i(0,2) : Vector2i(6,3),
	Vector2i(2,3) : Vector2i(6,3),
	Vector2i(3,3) : Vector2i(7,3),
}

func _ready() -> void:
	GameManager.connect("gm_node_entered_layer", _on_node_enter_layer)
	
func _on_node_enter_layer(entered_cell: Vector2i, entered_layer) -> void:
	if entered_layer is VegetationLayer: 
		var cropped_coords = get_cropped_coords(get_cell_atlas_coords(entered_cell))
		set_cell(entered_cell, 6, cropped_coords, get_cell_alternative_tile(entered_cell))

func get_cropped_coords(coords: Vector2i) -> Vector2i:
	return CROPPEDS_COORDS[coords]
