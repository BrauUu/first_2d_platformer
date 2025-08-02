class_name FakeTerrain
extends TileMapLayer

var previous_cells_atlas_coords : Array[Vector2i]
var previous_cells : Array[Vector2i]

func _ready() -> void:
	GameManager.connect("gm_player_entered_fake_terrain", _on_player_enter_fake_terrain)
	GameManager.connect("gm_player_left_fake_terrain", _on_player_leave_fake_terrain)

func _process(delta: float) -> void:
	pass
	
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
	
func _on_player_enter_fake_terrain(entered_cell: Vector2i) -> void:
	var neighbor_cells := get_neighbors_cells(entered_cell)
	previous_cells = neighbor_cells
	for cell in neighbor_cells:
		previous_cells_atlas_coords.append(get_cell_atlas_coords(cell))
		set_cell(cell, 4, Vector2i(4,4))
		
func _on_player_leave_fake_terrain(left_cell: Vector2i) -> void:
	for ind in len(previous_cells):
		var cell = previous_cells[ind]
		set_cell(cell, 4, previous_cells_atlas_coords[ind])
	previous_cells.clear()
	previous_cells_atlas_coords.clear()
