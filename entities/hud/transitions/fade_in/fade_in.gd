extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal transition_finished

func _ready() -> void:
	visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func transition() -> void:
	visible = true
	animation_player.play("fade_in")

func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == "fade_in":
		transition_finished.emit()
		animation_player.play("fade_out")
	elif animation_name == "fade_out":
		visible = false
