extends Control

var SELECT_ICON : AnimatedSprite2D
var RESUME_BUTTON : Button
var MAIN_MENU_BUTTON : Button
var QUIT_BUTTON : Button
var BUTTONS : VBoxContainer

var on_pause := false

func _ready() -> void:
	visible = on_pause
	SELECT_ICON = $SelectIcon
	RESUME_BUTTON = $Buttons/ResumeButton
	MAIN_MENU_BUTTON = $Buttons/BackToMenuButton
	QUIT_BUTTON = $Buttons/QuitButton
	BUTTONS = $Buttons

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		handle_pause_menu()

func _exit_tree():
	get_tree().paused = false

func handle_pause_menu() -> void:
	on_pause = not on_pause
	visible = on_pause
	get_tree().paused = on_pause
	if on_pause:
		RESUME_BUTTON.grab_focus()

func _on_resume_button_pressed() -> void:
	handle_pause_menu()

func _on_resume_button_focus_entered() -> void:
	SELECT_ICON.position = BUTTONS.position + RESUME_BUTTON.position + Vector2(40, RESUME_BUTTON.size.y / 2 - 2)

func _on_resume_button_mouse_entered() -> void:
	RESUME_BUTTON.grab_focus()

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
