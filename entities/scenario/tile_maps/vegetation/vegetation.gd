class_name VegetationLayer
extends TileMapLayer

@onready var grass_hit: AudioStreamPlayer2D = $GrassHit

const CROPPEDS_COORDS = {
	Vector2i(0,0) : {
		'coords': Vector2i(4,3),
		'texture': "res://assets/sprites/scenarios/leaf_particles.png"
		},
	Vector2i(0,3) : {
		'coords': Vector2i(4,3),
		'texture': "res://assets/sprites/scenarios/leaf_particles.png"
	},
	Vector2i(0,1) : {
		'coords': Vector2i(5,3),
		'texture': "res://assets/sprites/scenarios/flowers_particles.png"
	},
	Vector2i(1,3) : {
		'coords': Vector2i(5,3),
		'texture': "res://assets/sprites/scenarios/flowers_particles.png"
	},
	Vector2i(0,2) : {
		'coords': Vector2i(6,3),
		'texture': "res://assets/sprites/scenarios/dryleaves_particles.png"
		},
	Vector2i(2,3) : {
		'coords': Vector2i(6,3),
		'texture': "res://assets/sprites/scenarios/dryleaves_particles.png"
		},
	Vector2i(3,3) : {
		'coords': Vector2i(7,3),
		'texture': "res://assets/sprites/scenarios/root_particles.png"
		}
}

const LEAVES_PARTICLES = preload("res://entities/particles/leaves_particles.tscn")

func _ready() -> void:
	GameManager.connect("gm_node_entered_layer", _on_node_enter_layer)
	
func _on_node_enter_layer(entered_cell: Vector2i, entered_layer) -> void:
	if entered_layer is VegetationLayer: 
		var cropped_coords = get_cropped_coords(get_cell_atlas_coords(entered_cell))
		
		var leaves_particles = LEAVES_PARTICLES.instantiate()
		leaves_particles.texture = load(cropped_coords.texture)
		leaves_particles.position = map_to_local(entered_cell)
		leaves_particles.connect("finished", _on_leaves_particle_finish.bind(leaves_particles))
		leaves_particles.emitting = true
		add_child(leaves_particles)
		
		set_cell(entered_cell, 6, cropped_coords.coords, get_cell_alternative_tile(entered_cell))
		grass_hit.position = map_to_local(entered_cell)
		grass_hit.play()

func get_cropped_coords(coords: Vector2i) -> Dictionary:
	return CROPPEDS_COORDS[coords]
	
func _on_leaves_particle_finish(leaves_particles: GPUParticles2D) -> void:
	leaves_particles.queue_free()
