class_name KnockbackComponent extends Node

var deceleration : float
var knockback_velocity: Vector2 = Vector2.ZERO
var enabled := false

func apply_knockback(knockback_info: Dictionary) -> void:
	var force = get_knockback_force(knockback_info)
	enabled = true
	knockback_velocity = Vector2(force.x, 0)
	deceleration = abs(force.x)

func get_knockback_force(knockback_info: Dictionary) -> Vector2:
	var source = knockback_info.source
	var position = source.global_position
	var distance = get_parent().global_position - position
	var direction = _get_vector_direction(distance)
	return direction * knockback_info.knockback_force

func _get_vector_direction(vector: Vector2) -> Vector2:
	if vector.x > 0:
		return Vector2(1, 0)
	else:
		return Vector2(-1, 0)

func _physics_process(delta: float) -> void:
	if enabled:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, deceleration * delta)
		deceleration *= 1.05
		if knockback_velocity.length() < 1 :
			enabled = false
			knockback_velocity = Vector2.ZERO

func get_velocity() -> Vector2:
	return knockback_velocity

func is_enabled() -> bool:
	return enabled
