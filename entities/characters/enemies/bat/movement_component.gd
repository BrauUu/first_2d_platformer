extends Node

@export var awake_area : Area2D
@export var attack_area: Area2D
@export var parent: Bat

var velocity: Vector2 = Vector2.ZERO
var enabled: bool = false
var target: Player = null
var attack_target_position: Vector2 = Vector2.ZERO
var target_in_range_to_attack: bool = false

func _ready() -> void:
	
	awake_area.connect("body_entered", _on_awake_area_player_entered)
	awake_area.connect("body_exited", _on_awake_area_player_exited)
	attack_area.connect("body_entered", _on_attack_area_player_entered)
	attack_area.connect("body_exited", _on_attack_area_player_exited)
	
func _physics_process(delta: float) -> void:
	if not enabled: return
	
	if not target:
		velocity = flies_back_and_forth()
		return
		
	var distance = 0
	
	if attack_target_position and parent.current_cooldown <= 0 and (target_in_range_to_attack or parent.attacking):
		parent.attacking = true
		distance = attack_target_position - parent.global_position
		velocity = distance.normalized() * parent.attack_speed
		attack_target_position += velocity
		if parent.global_position.distance_to(target.global_position) > 100:
			parent.attacking = false
			parent.current_cooldown = parent.cooldown
		for i in range(parent.get_slide_collision_count()):
			parent.attacking = false
			parent.current_cooldown = parent.cooldown
	else:
		distance = target.global_position - parent.global_position
		velocity = distance.normalized() * parent.speed
		
	if not parent.attacking and attack_target_position:
		attack_target_position = target.global_position
		
	if distance.x > 0:
		parent.direction = 1
	else:
		parent.direction = -1
		
func flies_back_and_forth() -> Vector2:
	var distance_to_initial_point := parent.global_position - parent.initial_point
	var should_change_direction := false
	if parent.direction * distance_to_initial_point.x >= parent.fly_distance:
		should_change_direction = true
		
	for i in range(parent.get_slide_collision_count()):
		var collision_direction := parent.get_slide_collision(i).get_normal()
		if collision_direction.x and int(collision_direction.x) != parent.direction:
			should_change_direction = true
			
	if should_change_direction:
		parent.change_direction()
		
	return Vector2(
		parent.direction, 
		-sign(distance_to_initial_point.y)
	).normalized() * parent.speed

func get_velocity() -> Vector2:
	return velocity

func is_enabled() -> bool:
	return enabled
	
func _on_awake_area_player_entered(player: Player) -> void:
	target = player

func _on_awake_area_player_exited(player: Player) -> void:
	target = null
	
func _on_attack_area_player_entered(player: Player) -> void:
	if not attack_target_position:
		attack_target_position = player.global_position
	target_in_range_to_attack = true

func _on_attack_area_player_exited(player: Player) -> void:
	target_in_range_to_attack = false
