extends Container

@onready var label: Label = $Label

@export var message : String

func _ready() -> void:
	label.text = message
	hide_message()
	
func show_message() -> void:
	visible = true

func hide_message() -> void:
	visible = false
