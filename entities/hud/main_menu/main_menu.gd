extends Control

var SELECT_ICON : AnimatedSprite2D
var START_BUTTON : Button
var QUIT_BUTTON : Button
var BUTTONS : VBoxContainer

@onready var player: Player = $Player

var has_interacted : bool = false

func _ready() -> void:
	SELECT_ICON = $SelectIcon
	START_BUTTON = $Buttons/StartButton
	QUIT_BUTTON = $Buttons/QuitButton
	BUTTONS = $Buttons
	
	START_BUTTON.grab_focus()
	player.animator.flip_h = true

func _on_start_button_pressed() -> void:
	if has_interacted: return
	
	has_interacted = true
	player.move()
	while player.position.x < 240:
		await get_tree().process_frame
	player.force_jump()
	while player.position.x < 385:
		await get_tree().process_frame
	FadeIn.transition()
	await FadeIn.transition_finished
	get_tree().change_scene_to_file("res://entities/levels/level_1/level_1.tscn")

func _on_start_button_focus_entered() -> void:
	SELECT_ICON.position = BUTTONS.position + START_BUTTON.position + Vector2(0, START_BUTTON.size.y / 2)
	
func _on_start_button_mouse_entered() -> void:
	START_BUTTON.grab_focus()
	
func _on_quit_button_pressed() -> void:
	if has_interacted: return
	
	has_interacted = true
	player.quit_game()
	while player.position.y < 200:
		await get_tree().process_frame
	FadeIn.transition()
	await FadeIn.transition_finished
	get_tree().quit()

func _on_quit_button_focus_entered() -> void:
	SELECT_ICON.position = BUTTONS.position + QUIT_BUTTON.position + Vector2(0, QUIT_BUTTON.size.y / 2)

func _on_quit_button_mouse_entered() -> void:
	QUIT_BUTTON.grab_focus()
