class_name Bird
extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var change_action_timer: Timer = $ChangeActionTimer

const WALK_SPEED := 30
const FLY_SPEED := Vector2(50, -150)
const OUT_OF_BOUNDS_POSITION := Vector2(-100, -180)

var STATES = {"walk" : move, "peak" : peak}

@export var movement_distance : int
@export var initial_direction : int

var direction : int
var flew_away : bool
var initial_position: Vector2
var goal_position : Vector2
var limit_walk_positions : Dictionary

func _ready() -> void:
	direction = initial_direction
	initial_position = position
	limit_walk_positions["min"] = initial_position.x - movement_distance
	limit_walk_positions["max"] = initial_position.x + movement_distance
	walk_or_peak()
	
func _process(delta: float) -> void:
	if direction:
		animated_sprite_2d.flip_h = direction > 0
	if is_out_of_bounds():
		queue_free()

func _physics_process(delta: float) -> void:
	if not flew_away:
		if not goal_position.x or is_position_close_enough_to_goal():
			direction = -direction
			goal_position = define_goal_position()
	move_and_slide()
	
func is_position_close_enough_to_goal() -> bool:
	var deadzone = 5.0
	if position.x >= goal_position.x and position.x <= goal_position.x + deadzone:
			return true
	if position.x <= goal_position.x and position.x >= goal_position.x - deadzone:
		return true
	return false
	
func walk_or_peak() -> void:
	var actual_state = STATES.keys().pick_random()
	STATES[actual_state].call()

func define_goal_position() -> Vector2:
	var new_movement_distance = (movement_distance * direction) / 2
	var distance = randf_range(10 * direction, new_movement_distance)
	var new_goal_position = position.x + distance
	if new_goal_position > limit_walk_positions["max"]:
		new_goal_position = (limit_walk_positions["max"] - position.x) + position.x
	if new_goal_position < limit_walk_positions["min"]:
		new_goal_position = (limit_walk_positions["min"] - position.x) + + position.x
	return Vector2(new_goal_position, position.y)
	
func peak() -> void:
	animated_sprite_2d.play("idle")
	
func move() -> void:
	animated_sprite_2d.play("move")
		
func is_out_of_bounds() -> bool:
	return position.x < OUT_OF_BOUNDS_POSITION.x or position.y < OUT_OF_BOUNDS_POSITION.y

func fly_away() -> void:
	animated_sprite_2d.play("fly")
	velocity = Vector2(FLY_SPEED.x * direction, FLY_SPEED.y)
	
func _on_animated_sprite_2d_frame_changed() -> void:
	if flew_away: return
	if animated_sprite_2d.animation == "move" and animated_sprite_2d.frame == 1:
		if position.x >= limit_walk_positions["min"] and position.x <= limit_walk_positions["max"]:
			velocity.x = WALK_SPEED * direction
		else:
			velocity.x = 0
	else:
		velocity.x = 0

func _on_detect_area_body_entered(body: Node2D) -> void:
	if body is Player or body is Enemy:
		flew_away = true
		fly_away()

func _on_change_action_timer_timeout() -> void:
	if flew_away: return
	walk_or_peak()
	change_action_timer.start(randi_range(2, 5))
