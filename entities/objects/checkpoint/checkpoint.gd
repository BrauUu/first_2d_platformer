extends AnimatedSprite2D

@onready var audio_controller: AudioController = $AudioController

var is_animation_finished : bool = false
var activated : bool = false

func _ready() -> void:
	play("inactive")

func _process(delta: float) -> void:
	pass

func _on_checkpoint_area_player_entered(body: Player) -> void:
	if not activated:
		audio_controller.play_sound("Activating")
		play("activating")
		await get_tree().create_timer(3).timeout
		is_animation_finished = true

func _on_animation_finished() -> void:
	if animation == "activating":
		audio_controller.stop_sound("Activating")
		play("active")
		audio_controller.play_sound("OnActive")
		activated = true

func _on_frame_changed() -> void:
	if animation == "activating" and frame == 5 and not is_animation_finished:
		frame = 3
