extends Area2D

@export var disabled: bool = false
@export var detector_shape : CollisionShape2D
@export var vision_detector: Area2D
@export var detect_groups : Array[String] = []
@export var detector_distance: int

var detected_body: Node2D = null
var detected_group: String = ""

signal body_detected(body: Node)
signal body_lost_detection(body: Node)
signal body_out_of_sight

func _ready() -> void:
	if detector_shape:
		detector_shape.shape.radius = detector_distance
	if vision_detector:
		vision_detector.connect("body_seen", _on_vision_detector_body_seen)
		vision_detector.connect("body_out_of_sight", _on_vision_detector_body_out_of_sight)
	
func _on_body_entered(body: Node2D) -> void:
	if disabled: return
	for group in detect_groups:
		if body.is_in_group(group):
			if not vision_detector:
				emit_signal("body_detected", body)
				return
			detected_body = body
			vision_detector.body_in_reach(detected_body)

func _on_body_exited(body: Node2D) -> void:
	if disabled: return
	for group in detect_groups:
		if body.is_in_group(group):
			emit_signal("body_lost_detection", body)
			if vision_detector:
				vision_detector.body_out_of_reach()

func _on_vision_detector_body_seen() -> void:
	emit_signal("body_detected", detected_body)

func _on_vision_detector_body_out_of_sight() -> void:
	body_out_of_sight.emit()

func body_out_of_reach() -> void:
	if vision_detector:
		vision_detector.body_out_of_reach()
