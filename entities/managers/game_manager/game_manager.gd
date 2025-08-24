extends Node

signal gm_player_dead (damage_info: Dictionary)
signal gm_player_spawned
signal gm_player_hurted (damage_info: Dictionary)
signal gm_player_entered_battle
signal gm_player_left_battle

signal gm_node_entered_layer (entered_cell: Vector2i, entered_layer )
signal gm_node_left_layer (left_cell: Vector2i, entered_layer)

signal gm_music_toggle(toggled_on: bool)

signal gm_coin_collected

var can_pause : bool = true
var is_player_dead : bool = false
var coins_count : int = 0

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
		var spawn_point := get_current_spawn_point()
			
		var pos = spawn_point.position
		is_player_dead = false
		return spawn(player, pos)
	
func notify_player_dead(damage_info: Dictionary) -> void:
	can_pause = false
	is_player_dead = true
	gm_player_dead.emit(damage_info)
	
func notify_player_hurted(damage_info: Dictionary) -> void:
	emit_signal("gm_player_hurted", damage_info)

func get_current_spawn_point() -> SpawnPoint:
	#TODO: Checkpoint logic
	if $"../Game/DebugSpawnPoint".active:
		return $"../Game/DebugSpawnPoint"
	return $"../Game/SpawnPoint"

func notify_node_entered_layer(entered_cell: Vector2i, entered_layer) -> void:
	gm_node_entered_layer.emit(entered_cell, entered_layer)
	
func notify_node_left_layer(left_layer) -> void:
	gm_node_left_layer.emit(left_layer)
	
func toggle_music(toggled_on: bool) -> void:
	gm_music_toggle.emit(toggled_on)
	
func coin_collected() -> void:
	coins_count += 1
	gm_coin_collected.emit()
