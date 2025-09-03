extends Node

signal gm_player_dead (damage_info: Dictionary)
signal gm_player_spawned
signal gm_player_hurted (damage_info: Dictionary)
signal gm_player_entered_battle
signal gm_player_left_battle
signal gm_player_recovery_health (health_amount: int)

signal gm_button_pressed(connection_id: int)
signal gm_button_released(connection_id: int)

signal gm_node_entered_layer (entered_cell: Vector2i, entered_layer )
signal gm_node_left_layer (left_cell: Vector2i, entered_layer)

signal gm_music_toggle(toggled_on: bool)
signal gm_music_mute(mute: bool, with_fade_out: bool)

signal gm_coin_collected

var can_pause : bool = true
var is_player_dead : bool = false
var coins_count : int = 0

var current_checkpoint_id : int

func _ready() -> void:
	pass
	
func spawn(node: Node2D, pos: Vector2) -> Node2D:
	var game = get_node("/root/Game")
	if not game.is_ancestor_of(node):
		game.add_child(node)
	node.position = pos
	return node
	
func notify_spawn_player() -> void:
	spawn_player()
	emit_signal("gm_player_spawned")
	
func emit_player_entered_battle() -> void:
	gm_player_entered_battle.emit()
	
func emit_player_left_battle() -> void:
	if not is_player_dead:
		gm_player_left_battle.emit()
	
func spawn_player() -> CharacterBody2D:
		can_pause = true
		var player := preload("res://entities/characters/player/player.tscn").instantiate()
		var checkpoint_position : Vector2 = get_current_checkpoint_position()
		is_player_dead = false
		return spawn(player, checkpoint_position)
		
func recovery_health(health_amount: int) -> void:
	gm_player_recovery_health.emit(health_amount)
	
func notify_player_dead(damage_info: Dictionary) -> void:
	can_pause = false
	is_player_dead = true
	gm_player_dead.emit(damage_info)
	
func notify_player_hurted(damage_info: Dictionary) -> void:
	emit_signal("gm_player_hurted", damage_info)

func get_current_checkpoint_position() -> Vector2:
	var checkpoints = get_node("/root/Game/Checkpoints").get_children()
	for checkpoint in checkpoints:
		if checkpoint.id == current_checkpoint_id:
			return checkpoint.position
	
	var debug_spawn_point = get_node("/root/Game/DebugSpawnPoint")
	if debug_spawn_point.active:
		return debug_spawn_point.position
		
	return get_node("/root/Game/SpawnPoint").position

func notify_node_entered_layer(entered_cell: Vector2i, entered_layer) -> void:
	gm_node_entered_layer.emit(entered_cell, entered_layer)
	
func notify_node_left_layer(left_layer) -> void:
	gm_node_left_layer.emit(left_layer)
	
func toggle_music(toggled_on: bool) -> void:
	gm_music_toggle.emit(toggled_on)
	
func notify_button_pressed(connection_id: int) -> void:
	gm_button_pressed.emit(connection_id)
	
func notify_button_released(connection_id: int) -> void:
	gm_button_released.emit(connection_id)
	
func coin_collected() -> void:
	coins_count += 1
	gm_coin_collected.emit()
	
func mute_current_music(mute: bool, with_fade_out: bool) -> void:
	gm_music_mute.emit(mute, with_fade_out)
	
func update_current_checkpoint_id(id: int) -> void:
	current_checkpoint_id = id
