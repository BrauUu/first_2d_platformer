extends Node2D

@export var grass_positions : Array[Vector2]
@export var parent : Node2D
const GRASS = preload("res://entities/scenario/vegetation/grass.tscn")

func _ready() -> void:
	for position in grass_positions:
		var grass = GRASS.instantiate()
		grass.position = position
		parent.add_child(grass)

func _process(delta: float) -> void:
	pass
