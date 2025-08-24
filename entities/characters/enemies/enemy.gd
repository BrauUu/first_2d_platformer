class_name Enemy 
extends CharacterBody2D

@export var speed : int
@export var damage : int
@export var initial_direction : int
@export var jump_power : int
@export var cooldown : float
@export var health : int

var current_cooldown : float
var direction : int

func set_state(state) -> void:
	assert(false, "Subclasses must override set_state")

func set_animation(animation: String) -> void:
	assert(false, "Subclasses must override set_animation")
