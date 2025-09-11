@tool
extends AnimatedSprite2D

enum DirectionEnum {LEFT, RIGHT}

const DIRECTIONS = {
	DirectionEnum.LEFT : "left",
	DirectionEnum.RIGHT : "right"
}

@export var direction : DirectionEnum = DirectionEnum.RIGHT:
	set(value):
		direction = value
		update_direction()
		
func update_direction() -> void:
	animation = DIRECTIONS[direction]
	
func _ready() -> void:
	update_direction()
