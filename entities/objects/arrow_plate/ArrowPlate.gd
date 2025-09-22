@tool
extends Node2D

@onready var floating_message: Control = $FloatingMessage

enum DirectionEnum {LEFT, RIGHT}

const POSITION_FACTOR_ON_ROTATION := 0.5
const DIRECTIONS = {
	DirectionEnum.LEFT : {
		"flip_h": true,
		"default_position": Vector2(-2,-5)
	},
	DirectionEnum.RIGHT : {
		"flip_h": false,
		"default_position": Vector2(2,-5)
	}
}

@export var direction : DirectionEnum = DirectionEnum.RIGHT:
	set(value):
		direction = value
		update_direction()
		
@export_range(-20,20) var arrow_rotation : float:
	set(value):
		arrow_rotation = value
		update_arrow_rotation()
		
@export var readable : bool = false:
	set(value):
		readable = value
		update_readable()
		
@export var message : String
		
func update_direction() -> void:
	var plate = get_node_or_null("Plate")
	var arrow = get_node_or_null("Arrow")
	if arrow and plate:
		arrow.flip_h = DIRECTIONS[direction].flip_h
		plate.flip_h = DIRECTIONS[direction].flip_h
		arrow.position = DIRECTIONS[direction].default_position
		arrow_rotation = -arrow.rotation_degrees

func update_arrow_rotation() -> void:
	var arrow = get_node_or_null("Arrow")
	if arrow:
		arrow.rotation_degrees = arrow_rotation
		arrow.position = DIRECTIONS[direction].default_position
		var pos_variation = int(arrow_rotation / 10) * POSITION_FACTOR_ON_ROTATION 
		var pos_variation_vector : Vector2 = Vector2(
			pos_variation, 
			pos_variation * (-1 if arrow.flip_h else 1)
		)
		arrow.position += pos_variation_vector
	
func update_readable() -> void:
	var arrow = get_node_or_null("Arrow")
	var message_zone = get_node_or_null("MessageZone")
	if arrow:
		arrow.animation = "readable" if readable else "default"
	if message_zone:
		message_zone.set_collision_mask_value(1, readable)

func _ready() -> void:
	update_readable()
	floating_message.message = message

func _on_message_zone_player_entered(player: Player) -> void:
	floating_message.show_message()

func _on_message_zone_player_exited(player: Player) -> void:
	floating_message.hide_message()
