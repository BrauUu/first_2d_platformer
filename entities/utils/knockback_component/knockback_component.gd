class_name KnockbackComponent extends Node

signal knockback_ended

const KNOCKBACK_DURATION : = {
	"x": 0.15,
	"y": 0.1
}
var knockback_velocity: Vector2 = Vector2.ZERO
var enabled := false

func apply_knockback(knockback_info: Dictionary) -> void:
	knockback_velocity = get_knockback_force(knockback_info)
	enabled = true

func get_knockback_force(knockback_info: Dictionary) -> Vector2:
	var position : Vector2 = Vector2(
		knockback_info.position.x if knockback_info.position.x else get_parent().global_position.x,
		knockback_info.position.y if knockback_info.position.y else get_parent().global_position.y
		)
	var distance : Vector2 = get_parent().global_position - position
	var direction = distance.normalized()
	return direction * knockback_info.knockback_force

func _physics_process(delta: float) -> void:
	if enabled:
		var tween := create_tween()
		tween.tween_property(
			self, 
			"knockback_velocity", 
			Vector2.ZERO, 
			KNOCKBACK_DURATION["x"] if abs(knockback_velocity.x) > abs(knockback_velocity.y) else KNOCKBACK_DURATION["y"]
			).from(knockback_velocity)
		if knockback_velocity.length() < 25:
			knockback_ended.emit()
			enabled = false
			knockback_velocity = Vector2.ZERO

func get_velocity() -> Vector2:
	return knockback_velocity

func is_enabled() -> bool:
	return enabled
