class_name FakeTerrain
extends TileMapLayer

var previous_cells_atlas_coords : Array[Vector2i]
var previous_cells : Array[Vector2i]

func _ready() -> void:
	GameManager.connect("gm_node_entered_layer", _on_player_enter_layer)
	GameManager.connect("gm_node_left_layer", _on_player_leave_layer)
	
func get_neighbors_cells(start_cell: Vector2i) -> Array[Vector2i]:
	var id : int = get_cell_source_id(start_cell)
	
	var neighbors : Array[Vector2i] = [start_cell]
	var indexes : Array = [0,4,8,12]
	var queue : Array[Vector2i] = [start_cell]
	var visiteds : Array[Vector2i]
	
	while queue:
		var actual_cell = queue.pop_front()
		visiteds.append(actual_cell)
		for ind in indexes:
			var new_cell = get_neighbor_cell(actual_cell, ind)
			if get_cell_source_id(new_cell) == id:
				if new_cell and not neighbors.count(new_cell):
					neighbors.append(new_cell)
				if new_cell and not visiteds.count(new_cell):
					queue.append(new_cell)
	return neighbors
	
func _on_player_enter_layer(entered_cell: Vector2i, entered_layer) -> void:
	if not entered_layer is FakeTerrain or previous_cells: return
	var neighbor_cells := get_neighbors_cells(entered_cell)
	previous_cells = neighbor_cells
	for cell in neighbor_cells:
		previous_cells_atlas_coords.append(get_cell_atlas_coords(cell))
		set_cell(cell, 4, Vector2i(4,4))
		
func _on_player_leave_layer(left_layer) -> void:
	if not left_layer is FakeTerrain or not previous_cells: return
	for ind in len(previous_cells):
		var cell = previous_cells[ind]
		set_cell(cell, 4, previous_cells_atlas_coords[ind])
	previous_cells.clear()
	previous_cells_atlas_coords.clear()
