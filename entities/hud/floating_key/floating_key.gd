extends Control

var scales = [Vector2(0.5, 0.5), Vector2(0.6, 0.6)]

@export var sprite_2d : Sprite2D
var texture : AtlasTexture
var icons : Dictionary

var state := "default"
var tween : Tween

func _ready() -> void:
	texture = sprite_2d.texture
	icons = IconsManager.get_current_icons()
	visible = false
	GamepadTypeManager.connect("gamepad_type_changed", on_gamepad_type_changed)
	sprite_2d.scale = scales[0]
	texture.atlas = load(icons["path"])
	texture.region = icons["interact"]
	animate()

func key_pressed() -> void:
	state = "pressed"
	tween.kill()

func key_released() -> void:
	state = "default"
	animate()

func animate() -> void:
	tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite_2d, "scale", Vector2(0.5, 0.5), 0.75)
	tween.tween_property(sprite_2d, "scale", Vector2(0.6, 0.6), 0.75)

func player_on_interactive_zone() -> void:
	visible = true
	
func player_out_interactive_zone() -> void:
	visible = false

func on_gamepad_type_changed() -> void:
	icons = IconsManager.get_current_icons()
	texture.atlas = load(icons["path"])
	texture.region = icons["interact"]
