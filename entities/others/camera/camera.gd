extends Camera2D

@export var target: Node2D
var target_group : String

func _ready() -> void:
	if target:
		var groups = target.get_groups()
		if len(groups) != 0:
			target_group = groups[0]
		get_target()

func _process(_delta: float) -> void:
	if target:
		position = target.position
	elif target_group:
		get_target()

func get_target() -> void:
	var nodes = get_tree().get_nodes_in_group(target_group)
	if len(nodes) != 0:
		target = nodes[0]
