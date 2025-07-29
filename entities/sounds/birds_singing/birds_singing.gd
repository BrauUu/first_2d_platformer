extends Node2D

@onready var birds_singing_sound: AudioStreamPlayer2D = $BirdsSinging
@onready var zone: Area2D = $Zone
@onready var collision_shape_2d: CollisionShape2D = $Zone/CollisionShape2D

@export var zone_radius : float = 50

var birds_count : int = 0

func _ready() -> void:
	collision_shape_2d.shape = collision_shape_2d.shape.duplicate()
	collision_shape_2d.shape.radius = zone_radius
	for body in zone.get_overlapping_bodies():
		_on_zone_body_entered(body)

func change_birds_count_and_check_if_there_are_birds(change: int) -> void:
	birds_count += change
	if birds_count <= 0:
		birds_count = 0
		birds_singing_sound.stop()
	elif not birds_singing_sound.playing:
		birds_singing_sound.play()

func _on_zone_body_entered(body: Node2D) -> void:
	if body is Bird:
		change_birds_count_and_check_if_there_are_birds(1)

func _on_zone_body_exited(body: Node2D) -> void:
	if body is Bird:
		change_birds_count_and_check_if_there_are_birds(-1)
