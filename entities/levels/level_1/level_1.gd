extends Node2D

@onready var player: Player = $Player
@onready var door: AnimatableBody2D = $Environment/Objects/Door
@onready var hud: CanvasLayer = $HUD
@onready var tutorial: Control = $Tutorial

signal cinematic_started
signal cinematic_ended

func _ready() -> void:
	cinematic_started.connect(_on_cinematic_started)
	cinematic_ended.connect(_on_cinematic_ended)
	await get_tree().process_frame
	door.open(false)
	run_initial_cinematic()

func run_initial_cinematic() -> void:
	cinematic_started.emit()
	player.move()
	while player.position.x < 40:
		await get_tree().process_frame
	player.force_jump()
	while player.position.x < 93:
		await get_tree().process_frame
	door.close()
	while player.position.x < 125:
		await get_tree().process_frame
	player.stop(-1)
	await door.door_closed
	player.direction = 1
	player.is_controllable = true
	cinematic_ended.emit()
	
func _on_cinematic_started() -> void:
	hud.visible = false
	tutorial.visible = false
	
func _on_cinematic_ended() -> void:
	hud.visible = true
	tutorial.visible = true
