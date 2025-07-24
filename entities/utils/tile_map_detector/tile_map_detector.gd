class_name TileMapDetector
extends Area2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is FakeTerrain:
		print(global_position)
		var entered_cell = Vector2i((global_position / 16 - Vector2(1,0)))
		GameManager.notify_player_entered_fake_terrain(entered_cell)

func _on_body_exited(body: Node2D) -> void:
	if body is FakeTerrain:
		var left_cell = Vector2i((global_position / 16 - Vector2(1,0)))
		GameManager.notify_player_left_fake_terrain(left_cell)
