class_name Lever
extends InteractableObject

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var interactive_zone: Area2D = $InteractiveZone
@onready var audio_controller: AudioController = $AudioController
@onready var activator: ConnectionActivator = $Activator
@onready var floating_key: Control = $FloatingKey

## When triggered will emit an signal to others objects with this "connection_id"
@export var connection_id : int = 0

var interacted : bool = false

func _ready() -> void:
	floating_key.visible = false
	animated_sprite_2d.play('unpushed')
	
func _process(delta: float) -> void:
	super(delta)
	if can_be_interacted and not interacted:
		floating_key.player_on_interactive_zone()
	else:
		floating_key.player_out_interactive_zone()
		
func _input(event):
	if not can_be_interacted or player.on_animation: return
	if event.is_action_pressed("interact") and not interacted:
		_on_interact()
		
func _on_interact() -> void:
	audio_controller.play_sound("Pushed")
	animated_sprite_2d.play("pushed")
	interacted = true
	activator.on_connection_actived()
	floating_key

func _on_interactive_zone_player_entered(_player: Player) -> void:
	can_reach = true
	player = _player

func _on_interactive_zone_player_exited(_player: Player) -> void:
	if floating_key:
		floating_key.player_out_interactive_zone()
	can_reach = false
	can_be_interacted = false
	player = null
