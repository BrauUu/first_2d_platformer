extends Control

@export var health_component : HealthComponent

@onready var current_health_node: ColorRect = $CurrentHealth
@onready var background: ColorRect = $Background

var max_health : int
var current_health : int

var max_width : float
var current_width : float

var disabled : bool = false

func _ready() -> void:
	max_health = health_component.health
	current_health = health_component.current_health
	max_width = background.size.x
	
	health_component.connect("health_updated", update_current_health)
	
func _process(delta: float) -> void:
	if not disabled:
		current_width = max_width * current_health / max_health
		current_health_node.size.x = current_width
	
func update_current_health(health: int) -> void:
	current_health = health
	if current_health == 0:
		disabled = true
		visible = false
