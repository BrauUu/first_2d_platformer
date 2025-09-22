class_name FloorButton
extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_controller: AudioController = $AudioController
@onready var large_collision_polygon_2d: CollisionPolygon2D = $LargeCollisionPolygon2D
@onready var press_zone: Area2D = $PressZone
@onready var activator: ConnectionActivator = $Activator

## Only still 'pressed" when there is something above it
@export var pressure_plate : bool

## When triggered will emit an signal to others objects with this "connection_id"
@export var connection_id : int = 0

var pressed : bool = false

func _ready() -> void:
	if pressure_plate:
		press_zone.connect("body_exited", _on_press_zone_body_exited)

func change_shape_disabled(is_disabled: bool, shape: Node2D) -> void:
	shape.disabled = is_disabled

func _on_press_zone_body_entered(body: Node2D) -> void:
	if not pressed:
		pressed = true
		call_deferred("change_shape_disabled", true, large_collision_polygon_2d)
		animated_sprite_2d.play("pressed")
		audio_controller.play_sound("Pressed")
		activator.on_connection_actived()
		
func _on_press_zone_body_exited(body: Node2D) -> void:
	if pressed:
		pressed = false
		call_deferred("change_shape_disabled", false, large_collision_polygon_2d)
		animated_sprite_2d.play("unpressed")
		audio_controller.play_sound("Pressed")
		activator.on_connection_deactivated()
