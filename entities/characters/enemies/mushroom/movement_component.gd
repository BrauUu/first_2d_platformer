extends Node

const SPEED : int = 50

var velocity : Vector2 = Vector2.ZERO
var parent : Mushroom = null
var has_hit_wall : bool = false

func _ready() -> void:
	parent = get_parent()

func was_awakened(player: Player) -> void:
	var player_direction = sign(player.global_position - parent.global_position)
	velocity.x = -player_direction.x * SPEED
	
func _physics_process(delta: float) -> void:
	if parent.is_on_wall():
		on_hit_wall()
	
func on_hit_wall() -> void:
	velocity.x = -velocity.x
		
func get_velocity() -> Vector2:
	return velocity
