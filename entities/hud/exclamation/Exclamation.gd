extends AnimatedSprite2D

func _ready() -> void:
	visible = false

func show_warning() -> void:
	visible = true
	play("active")

func hide_warning(on_animation: bool = true) -> void:
	if not on_animation:
		visible = false
		return
		
	play("fade")
	await animation_finished
	if animation == "fade":
		visible = false
