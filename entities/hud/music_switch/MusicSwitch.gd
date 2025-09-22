extends Control

func _on_toggled(toggled_on: bool) -> void:
	GameManager.toggle_music(toggled_on)
