class_name InteractableObject
extends CharacterBody2D

var can_reach: bool = false
var is_being_interacted: bool = false
var can_be_interacted: bool = false

var player : Player

func _process(delta: float) -> void:
	if not can_reach: return
	can_be_interacted = InteractionManager.current_interactable_node == self
