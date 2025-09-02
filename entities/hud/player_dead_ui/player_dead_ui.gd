extends Control

@onready var select_icon: AnimatedSprite2D = $RespawnButtonContainer/SelectIcon
@onready var death_cause: Label = $DeathCause
@onready var show_respawn_button_timer: Timer = $ShowRespawnButtonTimer
@onready var respawn_button: Button = $RespawnButtonContainer/RespawnButton
@onready var respawn_button_container: Control = $RespawnButtonContainer

func _ready() -> void:
	visible = false
	respawn_button_container.visible = false
	GameManager.connect("gm_player_dead", _on_player_dead)
	
func _on_player_dead(damage_info: Dictionary):
	visible = true
	death_cause.text = damage_info.death_cause
	show_respawn_button_timer.start()
	await show_respawn_button_timer.timeout
	respawn_button_container.visible = true
	respawn_button.grab_focus()

func _on_respawn_button_pressed() -> void:
	visible = false
	respawn_button_container.visible = false
	GameManager.notify_spawn_player()
