class_name Lever
extends InteractableObject

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var interactive_zone: Area2D = $InteractiveZone
@onready var audio_controller: AudioController = $AudioController
@onready var activator: ConnectionActivator = $Activator
@onready var floating_key: Control = $FloatingKey

## When triggered will emit an signal to others objects with this "connection_id"
@export var connection_id : int = 0
## Can be interacted one or more times (on/off)
@export var can_be_interacted_once : bool = true

var interacted : bool = false

func _ready() -> void:
	floating_key.visible = false
	animated_sprite_2d.play('off')
	
func _process(delta: float) -> void:
	super(delta)
	if active and can_be_interacted:
		floating_key.player_on_interactive_zone()
	else:
		floating_key.player_out_interactive_zone()
		
func _input(event):
	if not can_be_interacted: return
	if active and event.is_action_pressed("interact"):
		_on_interact()
		
func _on_interact() -> void:
	audio_controller.play_sound("Pushed")
	if can_be_interacted_once:
		active = false
	animated_sprite_2d.play("on" if not interacted else "off")
	if not interacted:
		activator.on_connection_actived()
	else:
		activator.on_connection_deactivated()
	interacted = not interacted

func _on_interactive_zone_player_entered(_entered_zone_player: Player) -> void:
	can_reach = true

func _on_interactive_zone_player_exited(_entered_zone_player: Player) -> void:
	can_reach = false
	can_be_interacted = false
