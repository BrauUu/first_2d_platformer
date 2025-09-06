@tool
extends CharacterBody2D

@onready var audio_controller: AudioController = $AudioController

@export var damage : int = 1

@export var width: float:
	set(value):
		width = value
		var sprite := $RepeatingSprite
		sprite.width = value
		update_collision_shape()

@export var height: float:
	set(value):
		height = value
		var sprite := $RepeatingSprite
		sprite.height = value
		update_collision_shape()
		
@export var is_affected_by_gravity: bool = false
@export var spikes_texture: Texture2D:
	set(value):
		spikes_texture = value
		var sprite := $RepeatingSprite
		sprite.texture = value
		
var inflicts_damage := true
		
func _physics_process(delta: float) -> void:
	if not is_affected_by_gravity: return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_floor() and inflicts_damage:
		audio_controller.play_sound("Drop")
		inflicts_damage = false
		set_collision_layer_value(4, false)
	move_and_slide()

func update_collision_shape() -> void:
	var shape_node := $CollisionShape2D
	if shape_node.shape.resource_local_to_scene == false:
			shape_node.shape = shape_node.shape.duplicate()
	if shape_node and shape_node.shape is RectangleShape2D:
		shape_node.shape.size = Vector2(width, height)
		shape_node.position = Vector2(0, -2)
		
func get_damage() -> Dictionary:
	return {
		"damage": damage,
		"knockback_force": 400,
		"source": self,
		"position": {
			"x": null,
			"y": global_position.y
		},
		"death_cause": "Well, that was a sharp decision!"
	}
