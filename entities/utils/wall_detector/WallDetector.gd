extends Node2D

@export var top_detector : RayCast2D
@export var bottom_detector : RayCast2D
@export var fake_terrain_detector : RayCast2D
@export var actual_area_detector : Area2D

@export var parent : Node2D

var active := true
var is_stopped := false
var force_stop := false

func _ready() -> void:
	if parent.jump_power and parent.speed:
		var jump_max_height = -parent.jump_power/20
		var jump_max_width = parent.speed/4
		
		top_detector.target_position = Vector2(jump_max_width, 0)
		top_detector.position = Vector2(0, jump_max_height)
		
		bottom_detector.target_position = Vector2(jump_max_width, 0)
		
		if fake_terrain_detector:
			fake_terrain_detector.target_position = Vector2(10, 0)
			
		if actual_area_detector:
			actual_area_detector.connect("body_entered", _on_fake_terrain_body_entered)
			actual_area_detector.connect("body_exited", _on_fake_terrain_body_left)
		
func _process(_delta: float) -> void:
	if not active: return
	
	if fake_terrain_detector and fake_terrain_detector.is_colliding():
		if is_fake_terrain_hidden(fake_terrain_detector.get_collider()) and not is_on_fake_terrain():
			force_stop = true
	else:
		force_stop = false
	
	if bottom_detector.is_colliding() and top_detector.is_colliding():
		is_stopped = true
	elif bottom_detector.is_colliding():
		is_stopped = false
		parent.jump()
	else:
		is_stopped = false

func _on_fake_terrain_body_entered(body: Node2D) -> void:
	if parent.has_method("set_is_on_fake_terrain"):
		parent.set_is_on_fake_terrain(true)
		
func _on_fake_terrain_body_left(body: Node2D) -> void:
	if parent.has_method("set_is_on_fake_terrain"):
		parent.set_is_on_fake_terrain(false)
		
func is_fake_terrain_hidden(collider: FakeTerrain) -> bool:
	return len(collider.previous_cells) == 0
	
func is_on_fake_terrain() -> bool:
	return parent.is_on_fake_terrain
