extends Area2D
class_name DeadZone

@export var damage : int
@export var checkpoints : Array[Area2D]

var last_checkpoint : Area2D

func _ready() -> void:
	for checkpoint in checkpoints:
		checkpoint.connect("body_entered", _on_body_entered.bind(checkpoint))

func get_last_checkpoint() -> Area2D:
	return last_checkpoint
	
func _on_body_entered(body: Node2D, checkpoint: Area2D) -> void:
	last_checkpoint = checkpoint

func get_damage() -> Dictionary:
	return {
		"damage": damage,
		"knockback_force": 0,
		"not_play_animation": true,
		"source": self,
		"position": {
			"x": global_position.x,
			"y": global_position.y
		},
		"death_cause": "You tested gravity. Gravity won."
	}
