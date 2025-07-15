extends Node2D

@export var top_detector : RayCast2D
@export var bottom_detector : RayCast2D
@export var parent : Node2D
@export var player_detector : Area2D

var active := true
var is_stopped := false

func _ready() -> void:
	if parent.jump_power and parent.speed:
		var jump_max_height = -parent.jump_power/20
		var jump_max_width = parent.speed/5
		
		top_detector.target_position = Vector2(jump_max_width, 0)
		top_detector.position = Vector2(0, jump_max_height)
		
		bottom_detector.target_position = Vector2(jump_max_width, 0)
		
func _process(_delta: float) -> void:
	if not active: return
	
	if bottom_detector.is_colliding():
		if top_detector.is_colliding():
			is_stopped = true
		else:
			is_stopped = false
			parent.jump()
