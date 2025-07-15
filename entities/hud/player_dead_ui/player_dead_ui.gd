extends Control


func _ready() -> void:
	visible = false
	GameManager.connect("gm_player_dead", _on_player_dead)
	
func _on_player_dead(damage_info: Dictionary):
	visible = true
	$DeathCause.text = damage_info.death_cause
	$ShowRespawnButtonTimer.start()
	await $ShowRespawnButtonTimer.timeout
	$RespawnButton.visible = true

func _on_respawn_button_pressed() -> void:
	visible = false
	$RespawnButton.visible = false
	GameManager.notify_spawn_player()
