@tool
extends CharacterBody2D

@onready var audio_controller: AudioController = $AudioController
@onready var attack: Attack = $Attack

@export var damage : int = 1

enum DIRECTION_ENUM {UP,RIGHT,DOWN,LEFT}
const DIRECTION_DEGRESS = {
	0: 180,
	1: -90,
	2: 0,
	3: 90
}

@export var direction : DIRECTION_ENUM = DIRECTION_ENUM.UP:
	set(value):
		direction = value
		print(DIRECTION_DEGRESS[value])
		rotation_degrees = DIRECTION_DEGRESS[value]

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
		attack.set_collision_layer_value(4, false)
	move_and_slide()

func update_collision_shape() -> void:
	var shape_node := $CollisionShape2D
	if shape_node.shape.resource_local_to_scene == false:
			shape_node.shape = shape_node.shape.duplicate()
	if shape_node and shape_node.shape is RectangleShape2D:
		shape_node.shape.size = Vector2(width, height-(1 if height > 0 else 0))
		shape_node.position = Vector2(0, -0.5)
		var attack_shape_node = $Attack/CollisionShape2D
		attack_shape_node.shape = shape_node.shape
		attack_shape_node.position = Vector2(0, -0.5)
		
func get_damage() -> Dictionary:
	return {
		"damage": damage,
		"knockback_force": 400,
		"source": self,
		"position": {
			"x": null if not is_affected_by_gravity else global_position.x ,
			"y": global_position.y if not is_affected_by_gravity else null
		},
		"death_cause": "Well, that was a sharp decision!"
	}
