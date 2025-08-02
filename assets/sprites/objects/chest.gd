class_name Chest
extends Node2D

## Itens that will be dropped when the chest is opened.
@export var treasures : Array[TreasureData]
## Cluster for grouping all dropped itens from the chest.
@export var treasures_cluster: Node2D 

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D
@onready var open_audio: AudioStreamPlayer2D = $Open

const SPEED : int = 2
enum CHEST_STATES {CLOSED, OPENING, OPEN}
var PATHS_POINTS = [
	[
		{"position": Vector2(0,0), "in": Vector2(0, 0), "out": Vector2(0,0)},
		{"position": Vector2(10,-12), "in": Vector2(-10, 0), "out": Vector2(10,0)},
		{"position": Vector2(20,0), "in": Vector2(0, 0), "out": Vector2(0,0)}
	],
	[
		{"position": Vector2(0,0), "in": Vector2(0, 0), "out": Vector2(0,0)},
		{"position": Vector2(5,-8), "in": Vector2(-5, 0), "out": Vector2(5,0)},
		{"position": Vector2(10,0), "in": Vector2(0, 0), "out": Vector2(0,0)}
	],
	[
		{"position": Vector2(0,0), "in": Vector2(0, 0), "out": Vector2(0,0)},
		{"position": Vector2(2,-8), "in": Vector2(-2, 0), "out": Vector2(2,0)},
		{"position": Vector2(4,0), "in": Vector2(0, 0), "out": Vector2(0,0)}
	],
	[
		{"position": Vector2(0,0), "in": Vector2(0, 0), "out": Vector2(0,0)},
		{"position": Vector2(-10,-12), "in": Vector2(10, 0), "out": Vector2(-10,0)},
		{"position": Vector2(-20,0), "in": Vector2(0, 0), "out": Vector2(0,0)}
	],
	[
		{"position": Vector2(0,0), "in": Vector2(0, 0), "out": Vector2(0,0)},
		{"position": Vector2(-5,-8), "in": Vector2(5, 0), "out": Vector2(-5,0)},
		{"position": Vector2(-10,0), "in": Vector2(0, 0), "out": Vector2(0,0)}
	],
	[
		{"position": Vector2(0,0), "in": Vector2(0, 0), "out": Vector2(0,0)},
		{"position": Vector2(-2,-8), "in": Vector2(2, 0), "out": Vector2(-2,0)},
		{"position": Vector2(-4,0), "in": Vector2(0, 0), "out": Vector2(0,0)}
	],
]

var current_state: int
var animations : PackedStringArray
var treasures_paths : Array[Path2D]

func update_animation() -> void:
	var animation = CHEST_STATES.keys()[current_state].to_lower()
	if animation in animations:
		animator.play(animation)
		
func is_valid_chest_state(value: int) -> bool:
	return value in CHEST_STATES.values()
	
func is_current_state(state: int) -> bool:
	return state == current_state
		
func get_current_state() -> int:
	return current_state
	
func set_current_state(new_state: int) -> void:
	if is_valid_chest_state(new_state):
		current_state = new_state

func _ready() -> void:
	animations = animator.sprite_frames.get_animation_names()
	set_current_state(CHEST_STATES.CLOSED)
	update_animation()

func _process(delta: float) -> void:
	if not treasures_paths: return
	
	for treasure_path in treasures_paths:
		var path_follow_2D = treasure_path.get_child(0) as PathFollow2D
		
		if path_follow_2D.progress_ratio < 1:
			path_follow_2D.progress_ratio += delta * SPEED
			
		if path_follow_2D.progress_ratio >= 1:
			if path_follow_2D.get_child_count():
				var treasure = path_follow_2D.get_child(0) as Treasure
				if treasure.is_current_state(treasure.TREASURE_STATES.DROPPING):
					treasure.set_current_state(treasure.TREASURE_STATES.DROPPED)

func open_chest() -> void:
	set_current_state(CHEST_STATES.OPENING)
	open_audio.play()
	update_animation()
	position.y -= 1
	while animator.frame < 3:
		await animator.frame_changed
	drop_treasures()
	
func drop_treasures() -> void:
	var paths = PATHS_POINTS.duplicate()
	for treasure in treasures:
		var qty = treasure.quantity
		for count in qty:
			if paths.is_empty():
				paths = PATHS_POINTS.duplicate()
			
			var idx = randi_range(0, paths.size() - 1)
			var path_points = paths.pop_at(idx)
			
			var path_2d = create_path_2d(path_points)
			var path_follow_2d = path_2d.get_child(0) as PathFollow2D
			
			if treasure.scene.can_instantiate():
				var instance = treasure.scene.instantiate()
				path_follow_2d.add_child(instance)
			
			treasures_cluster.add_child(path_2d)
			treasures_paths.append(path_2d)
		
func create_path_2d(points: Array) -> Path2D:
	var curve = Curve2D.new()
	for point in points:
		curve.add_point(position + point.position, point.in, point.out)

	var path_follow = PathFollow2D.new()
	path_follow.rotates = false
	path_follow.loop = false

	var path = Path2D.new()
	path.curve = curve
	path.add_child(path_follow)

	return path

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is Player and is_current_state(CHEST_STATES.CLOSED):
		open_chest()
		
func _on_animation_finished() -> void:
	if is_current_state(CHEST_STATES.OPENING):
		set_current_state(CHEST_STATES.OPEN)
		update_animation()
