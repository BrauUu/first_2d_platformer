extends Node2D

@onready var player: Player = $Player
@onready var door: AnimatableBody2D = $Environment/Objects/Door
@onready var hud: CanvasLayer = $HUD
@onready var tutorial: Control = $Tutorial
@onready var debug_spawn_point: SpawnPoint = $DebugSpawnPoint
@onready var spawn_point: SpawnPoint = $SpawnPoint
@onready var audio_controller: AudioController = $AudioController

@export var show_cutscenes : bool

#var player_start_position : Vector2
var player_start_position : Vector2

signal cinematic_started
signal cinematic_ended

func _ready() -> void:
	audio_controller.play_sound("Ambience")
	audio_controller.play_sound("DefaultMusic")
	
	cinematic_started.connect(_on_cinematic_started)
	cinematic_ended.connect(_on_cinematic_ended)
	GameManager.gm_player_entered_battle.connect(_on_player_enter_battle)
	GameManager.gm_player_left_battle.connect(_on_player_leave_battle)
	
	await get_tree().process_frame
	door.open(false)
	if show_cutscenes:
		player_start_position = spawn_point.position
		run_initial_cinematic()
	else:
		door.close(false)
		player_start_position = debug_spawn_point.position
		player.position = player_start_position

func run_initial_cinematic() -> void:
	cinematic_started.emit()
	player.move()
	while player.position.x < 15:
		await get_tree().process_frame
	player.force_jump()
	while player.position.x < 70:
		await get_tree().process_frame
	door.close()
	while player.position.x < player_start_position.x:
		await get_tree().process_frame
	player.stop(-1)
	await door.door_closed
	player.direction = 1
	cinematic_ended.emit()
	
func _on_cinematic_started() -> void:
	GameManager.can_pause = false
	hud.visible = false
	tutorial.visible = false
	player.is_controllable = false
	
func _on_cinematic_ended() -> void:
	GameManager.can_pause = true
	hud.visible = true
	tutorial.visible = true
	player.is_controllable = true
	
func _on_player_enter_battle() -> void:
	audio_controller.stop_sound("DefaultMusic")
	audio_controller.play_sound("BattleMusic")
	
func _on_player_leave_battle() -> void:
	audio_controller.stop_sound("BattleMusic")
	audio_controller.play_sound("DefaultMusic")
