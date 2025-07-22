extends Node

signal gm_player_dead (damage_info: Dictionary)
signal gm_player_spawned
signal gm_player_hurted (damage_info: Dictionary)

var can_pause : bool = true

func _ready() -> void:
	pass
	
func spawn(node: Node2D, pos: Vector2) -> Node2D:
	get_node("/root/Game").add_child(node)
	node.position = pos
	return node
	
func notify_spawn_player() -> void:
	spawn_player()
	emit_signal("gm_player_spawned")
	
func spawn_player(is_game_over: bool = false) -> CharacterBody2D:
		can_pause = true
		var player := preload("res://entities/characters/player/player.tscn").instantiate()
		var spawn_point := get_current_spawn_point()
			
		var pos = spawn_point.position
		return spawn(player, pos)

func restart() -> void:
	spawn_player(true)
	emit_signal("gm_player_spawned")
	
func notify_player_dead(damage_info: Dictionary) -> void:
	can_pause = false
	gm_player_dead.emit(damage_info)
	
func notify_player_hurted(damage_info: Dictionary) -> void:
	emit_signal("gm_player_hurted", damage_info)

func get_current_spawn_point() -> SpawnPoint:
	#TODO: Checkpoint logic
	return $"../Game/SpawnPoint"
