extends AnimatedSprite2D

func _ready() -> void:
	play()
	await self.animation_finished
	queue_free()
