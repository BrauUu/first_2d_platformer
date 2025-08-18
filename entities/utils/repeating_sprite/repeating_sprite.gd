@tool
extends Sprite2D
class_name RepeatingSprite

@export var width: float:
	set(value):
		width = value
		update_region()
		
@export var height: float:
	set(value):
		height = value
		update_region()
		
func _set(property: StringName, value) -> bool:
	if property == "texture":
		texture = value
		update_region()
		return true
	return false
		
func update_region() -> void:
	if texture:
		region_enabled = true
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		region_rect = Rect2(Vector2.ZERO, Vector2(width, height))
