extends Control

@onready var select_icon: AnimatedSprite2D = $HUD/SelectIcon
@onready var buttons: VBoxContainer = $HUD/Buttons
@onready var start_button: Button = $HUD/Buttons/StartButton
@onready var quit_button: Button = $HUD/Buttons/QuitButton
@onready var music_switch: CheckButton = $HUD/MusicSwitch

@onready var player: Player = $Player
@onready var audio_controller: AudioController = $AudioController
@onready var music_controller: MusicController = $MusicController

var ignore_next_focus: bool = true

func _ready() -> void:
	start_button.grab_focus.call_deferred()
	player.animator.flip_h = true
	music_controller.play_sound("Music")
	audio_controller.play_sound("Ambience")

func _on_start_button_pressed() -> void:
	disable_menu(start_button)
	audio_controller.play_sound("MenuSelect")
	player.move()
	while player.position.x < 185:
		await get_tree().process_frame
	player.force_jump()
	while player.position.x < 320:
		await get_tree().process_frame
	FadeIn.transition()
	await FadeIn.transition_finished
	get_tree().change_scene_to_file("res://entities/levels/level_1/level_1.tscn")

func _on_start_button_focus_entered() -> void:
	select_icon.position = buttons.position + start_button.position + Vector2(0, start_button.size.y / 2)
	if ignore_next_focus:
		ignore_next_focus = false
		return
	audio_controller.play_sound("MenuFocus")
	
func _on_start_button_mouse_entered() -> void:
	start_button.grab_focus()
	
func _on_quit_button_pressed() -> void:
	disable_menu(quit_button)
	audio_controller.play_sound("MenuSelect")
	player.quit_game()
	while player.position.y < 160:
		await get_tree().process_frame
	FadeIn.transition()
	await FadeIn.transition_finished
	get_tree().quit()

func _on_quit_button_focus_entered() -> void:
	select_icon.position = buttons.position + quit_button.position + Vector2(0, quit_button.size.y / 2)
	audio_controller.play_sound("MenuFocus")

func _on_quit_button_mouse_entered() -> void:
	quit_button.grab_focus()
	
func _on_music_switch_focus_entered() -> void:
	select_icon.position = music_switch.position + + Vector2(-10, music_switch.size.y  * music_switch.scale.y / 2 - 2)
	audio_controller.play_sound("MenuFocus")
	
func _on_music_switch_mouse_entered() -> void:
	music_switch.grab_focus()

	
func disable_menu(actual_selection: Control) -> void:
	for option in buttons.get_children():
		option.focus_mode = Control.FOCUS_NONE
		option.mouse_filter = MOUSE_FILTER_IGNORE
		if option == actual_selection:
			option.add_theme_color_override("font_color", option.get_theme_color("font_pressed_color"))
			option.add_theme_color_override("font_outline_color", "#0a0a0a")
			
