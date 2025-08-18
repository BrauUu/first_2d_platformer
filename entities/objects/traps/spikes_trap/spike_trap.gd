extends Node2D

@export var active : bool
var has_been_activated : bool

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_controller: AudioController = $AudioController

func _on_area_2d_player_entered(player: Player) -> void:
	if has_been_activated: return
	active_trap()
	
func active_trap() -> void:
	animated_sprite_2d.play("active")
	has_been_activated = true
	audio_controller.play_sound("Activated")
	
func drop_spikes() -> void:
	var spikes = preload("res://entities/objects/traps/spikes/spikes.tscn").instantiate()
	spikes.width = 16
	spikes.height = 16
	spikes.is_affected_by_gravity = true
	spikes.position = Vector2(0, 3)
	spikes.spikes_texture = preload("res://assets/sprites/objects/spikes_trap.png")
	add_child(spikes)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "active":
		animated_sprite_2d.play("default")

func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite_2d.frame == 4:
		drop_spikes()
