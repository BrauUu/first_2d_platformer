extends Control

var SELECT_ICON : AnimatedSprite2D
var RESTART_BUTTON : Button
var MAIN_MENU_BUTTON : Button
var QUIT_BUTTON : Button
var BUTTONS : VBoxContainer

func _ready() -> void:
	SELECT_ICON = $SelectIcon
	RESTART_BUTTON = $Buttons/RestartButton
	MAIN_MENU_BUTTON = $Buttons/BackToMenuButton
	QUIT_BUTTON = $Buttons/QuitButton
	BUTTONS = $Buttons
	
	visible = false
	GameManager.connect("gm_game_over", _on_game_over)
	
func _on_game_over() -> void:
	visible = true
	get_tree().paused = true
	RESTART_BUTTON.grab_focus()

func _on_restart_button_pressed() -> void:
	FadeIn.transition()
	await FadeIn.transition_finished
	visible = false
	get_tree().paused = false
	GameManager.restart()
	
func _on_restart_button_focus_entered() -> void:
	SELECT_ICON.position = BUTTONS.position + RESTART_BUTTON.position + Vector2(40, RESTART_BUTTON.size.y / 2 - 2)

func _on_restart_button_mouse_entered() -> void:
	RESTART_BUTTON.grab_focus()

func _on_back_to_menu_button_pressed() -> void:
	FadeIn.transition()
	await FadeIn.transition_finished
	get_tree().change_scene_to_file("res://entities/hud/main_menu/main_menu.tscn")

func _on_back_to_menu_button_focus_entered() -> void:
	SELECT_ICON.position = BUTTONS.position + MAIN_MENU_BUTTON.position + Vector2(40, MAIN_MENU_BUTTON.size.y / 2 - 2)

func _on_back_to_menu_button_mouse_entered() -> void:
	MAIN_MENU_BUTTON.grab_focus()

func _on_quit_button_pressed() -> void:
	FadeIn.transition()
	await FadeIn.transition_finished
	get_tree().quit()

func _on_quit_button_focus_entered() -> void:
	SELECT_ICON.position = BUTTONS.position + QUIT_BUTTON.position + Vector2(40, QUIT_BUTTON.size.y / 2 - 2)

func _on_quit_button_mouse_entered() -> void:
	QUIT_BUTTON.grab_focus()
