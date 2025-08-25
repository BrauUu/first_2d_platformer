extends Area2D

@export var vision_detector_shape : Node2D
@export var vision_detector_line : RayCast2D
var parent : Node2D

var detected_body: Node2D = null

var vision_detected_body : CharacterBody2D = null
var vision_detected_body_seen: bool

signal body_seen
signal body_out_of_sight

func _ready() -> void:
	parent = get_parent()

func _process(_delta: float) -> void:
	if not vision_detected_body : return
	
	var target_position = vision_detected_body.global_position - global_position
	if target_position.length() < 10: return
	target_position.x *= parent.scale.x
	vision_detector_line.target_position = Vector2(target_position.x, target_position.y)
	vision_detector_line.force_raycast_update()
	
	if vision_detector_line.get_collider() != detected_body:
		if vision_detected_body_seen:
			body_out_of_sight.emit()
			vision_detected_body_seen = false
		return
	
	if not vision_detected_body_seen:
		emit_signal('body_seen')
		vision_detected_body_seen = true

func body_in_reach(body) -> void:
	detected_body = body
	
func body_out_of_reach() -> void:
	vision_detected_body = null
	vision_detected_body_seen = false
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body == detected_body and vision_detected_body != body:
			vision_detected_body = body
			vision_detected_body_seen = false
