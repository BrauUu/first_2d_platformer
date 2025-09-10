extends Node

const FACE_DIRECTION_PICK_FACTOR : float = 5

var current_interactable_node : InteractableObject = null
var player : Player

func _ready() -> void:
	player = GameManager.player

func _process(delta: float) -> void:
	
	var pushable_objects = get_tree().get_nodes_in_group("InteractableObject").filter(
		func(object): return object.can_reach
	)
	
	if len(pushable_objects) == 0: 
		current_interactable_node = null
		return
	
	if len(pushable_objects) == 1: 
		current_interactable_node = pushable_objects[0]
		return
	
	var nearest_object_distance : float = INF
	var nearest_object : InteractableObject = null
	
	for object : InteractableObject in pushable_objects:
		if object.can_reach:
			if object.is_being_interacted: return
			var object_distance = player.global_position.distance_to(object.global_position)
			var direction = sign(player.global_position.x - object.global_position.x)
			var diff = abs(nearest_object_distance - object_distance)
			if diff <= FACE_DIRECTION_PICK_FACTOR:
				if (object_distance * direction) * player.face_direction < 0:
					nearest_object = object
					nearest_object_distance = object_distance
			elif object_distance < nearest_object_distance:
				nearest_object_distance = object_distance
				nearest_object = object
	
	current_interactable_node = nearest_object
