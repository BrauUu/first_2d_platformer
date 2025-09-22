extends Node

@onready var player_detector_raycast: RayCast2D = $"../PlayerDetectorRaycast"
@onready var ground_detector: RayCast2D = $"../GroundDetector"

const SPEED : int = 50

var velocity : Vector2 = Vector2.ZERO
var parent : Mushroom = null
var has_hit_wall : bool = false
var change_direction_count : int = 0
const max_change_direction_count : int = 3

func _ready() -> void:
	parent = get_parent()

func run_from(player: Player) -> void:
	if not player_detector_raycast.enabled:
		player_detector_raycast.enabled = true
	var player_direction = sign(player.global_position - parent.global_position)
	velocity.x = -player_direction.x * SPEED
	change_direction_count += 1
	if change_direction_count >= max_change_direction_count and not parent.is_current_state(parent.MUSHROOM_STATES.AFRAID):
		parent.afraid()
	
func _physics_process(delta: float) -> void:
	if parent.is_on_wall():
		on_hit_wall()
	if parent.is_active() and player_detector_raycast.is_colliding() and change_direction_count < max_change_direction_count:
		run_from(player_detector_raycast.get_collider())
	if not ground_detector.is_colliding() or ground_detector.get_collider() is Attack:
		on_hit_wall()
		
	
func on_hit_wall() -> void:
	velocity.x = -velocity.x
		
func get_velocity() -> Vector2:
	return velocity

func _on_timer_timeout() -> void:
	change_direction_count = 0
