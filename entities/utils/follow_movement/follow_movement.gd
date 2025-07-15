class_name FollowMovement extends Node

@export var attack_distance : Vector2
@export var ground_detector: RayCast2D
@export var wall_detector: Node2D
@export var player_detector: Area2D
@export var give_up_countdown: Timer

@export var parent : Enemy

var speed : int
var target : Node2D
var deadzone: int = 2
var start_position: Vector2
var start_direction: float
var hole_direction := 0
var enabled : bool = true

func _ready() -> void:
	start_position = parent.global_position
	start_direction = parent.initial_direction
	speed = parent.speed
	
	player_detector.connect("body_detected", _on_player_detector_body_detected)
	player_detector.connect("body_lost_detection", _on_player_detector_body_lost_detection)
	give_up_countdown.connect("timeout", _on_give_up_countdown_timeout)

func get_motion_velocity() -> Vector2:
	
	check_movement_possiblity()
	
	var distance
	var new_velocity
	
	if not target:
		if abs(start_position.x - parent.global_position.x) > deadzone:
			distance = start_position - parent.global_position
			new_velocity = distance.normalized() * speed 
		else:
			new_velocity = Vector2.ZERO
			parent.set_direction(start_direction)
	else:
		distance = target.global_position - parent.global_position
		new_velocity = distance.normalized() * speed
		var direction = 1 if new_velocity.x > 0 else -1
		
		if can_attack(distance, attack_distance):
			new_velocity.x = 0
			if parent.has_method("look_for_player"):
				parent.look_for_player(target)
			parent.attack()
			
		if not ground_detector.is_colliding():
			if direction == hole_direction:
				hole_direction = direction
				new_velocity.x = 0
			hole_direction = direction
	
	new_velocity.y = 0
	return new_velocity

func is_enabled() -> bool:
	return enabled
	
func can_attack(base: Vector2, comparison: Vector2) -> bool:
	if (base.x <= comparison.x and base.x >= -comparison.x) and (base.y <= comparison.y and base.y >= -comparison.y):
		return true
	return false
	
func check_movement_possiblity() -> void:
	if wall_detector.is_stopped or not ground_detector.is_colliding():
		if give_up_countdown.is_stopped():
			give_up_countdown.start()
	elif not give_up_countdown.is_stopped():
		give_up_countdown.stop()
	
				
func _on_player_detector_body_detected(body: Node) -> void:
	if body != target:
		target = body
		parent.following()

func _on_player_detector_body_lost_detection(body: Node) -> void:
	if body == target:
		parent.stop_following()
		target = null

func _on_give_up_countdown_timeout() -> void:
	parent.stop_following()
	target = null
