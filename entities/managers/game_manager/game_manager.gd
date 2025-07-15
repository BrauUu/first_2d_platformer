extends Node

@export var player_lifes_count := 0

signal gm_player_dead (damage_info: Dictionary)
signal gm_player_spawned
signal gm_player_hurted (damage_info: Dictionary)
signal gm_game_over

func _ready() -> void:
	pass
	
func get_player_lifes_count() -> int:
	return player_lifes_count
	
func spawn(node: Node2D, pos: Vector2) -> Node2D:
	get_node("/root/Game").add_child(node)
	node.position = pos
	return node
	
func notify_spawn_player() -> void:
	
	if player_lifes_count > 0:
		spawn_player()
		emit_signal("gm_player_spawned")
		return
	
	#TODO: Game over
	
func spawn_player(is_game_over: bool = false) -> CharacterBody2D:
		var player := preload("res://entities/characters/player/player.tscn").instantiate()
		var spawn_point : SpawnPoint
		
		if not is_game_over:
			spawn_point = get_current_spawn_point()
			player_lifes_count -= 1
		else:
			spawn_point = get_first_spawn_point()
		var pos = spawn_point.position
		return spawn(player, pos)

func restart() -> void:
	spawn_player(true)
	
func notify_player_dead(damage_info: Dictionary) -> void:
	if player_lifes_count <= 0:
		gm_game_over.emit()
		return
	emit_signal("gm_player_dead", damage_info)
	
func notify_player_hurted(damage_info: Dictionary) -> void:
	emit_signal("gm_player_hurted", damage_info)

func get_current_spawn_point() -> SpawnPoint:
	#TODO: Checkpoint logic
	return $"../Game/SpawnPoint"
	
func get_first_spawn_point() -> SpawnPoint:
	return $"../Game/SpawnPoint"
