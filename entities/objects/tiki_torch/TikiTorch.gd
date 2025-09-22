extends AnimatedSprite2D

@onready var audio_controller: AudioController = $AudioController

func _ready() -> void:
	audio_controller.play_sound("Fire")
