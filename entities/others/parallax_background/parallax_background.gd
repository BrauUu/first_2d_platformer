extends ParallaxBackground

@onready var clouds: ParallaxLayer = $CloudsLayer

var clouds_speed := 5

func _process(delta: float) -> void:
	clouds.motion_offset.x += clouds_speed * delta
