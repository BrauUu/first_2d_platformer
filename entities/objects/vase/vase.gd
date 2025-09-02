@tool
extends PushableObject

@export var animator: AnimatedSprite2D
@export var hitbox_area: Area2D
@export var collisor: CollisionShape2D

enum VaseSizeEnum {LARGE, SMALL}
var sizes = {
	VaseSizeEnum.SMALL: Vector2(1,1),
	VaseSizeEnum.LARGE: Vector2(2,2)
}

enum VaseTypeEnum {INTERACTABLE, BREAKABLE}
##Defines whether it is possible to push/pull or break the object
@export var vase_type: VaseTypeEnum:
	set(value):
		vase_type = value
		update_interactive_zones()
		
@export var size: VaseSizeEnum:
	set(value):
		size = value
		update_vase_size()

var is_break : bool = false

func _ready() -> void:
	animator.play("default")
	update_interactive_zones()
	update_vase_size()
	super()
	
func _physics_process(delta: float) -> void:
	if is_interactable():
		super(delta)
	
func update_vase_size() -> void:
	var new_scale = sizes[size]
	if hitbox_area:
		hitbox_area.scale = new_scale
	if interactive_zone_left:
		interactive_zone_left.scale = new_scale
		interactive_zone_left.position.x = -7
		interactive_zone_left.position.x -= new_scale.x ** 2
	if interactive_zone_right:
		interactive_zone_right.scale = new_scale
		interactive_zone_right.position.x = 7
		interactive_zone_right.position.x += new_scale.x ** 2
	if collisor:
		collisor.scale = new_scale
	if animator:
		animator.scale = new_scale
	
func update_interactive_zones() -> void:
	var interactable = is_interactable()
	set_collision_layer_value(5, interactable)
	interactive_zone_left.set_collision_mask_value(1, interactable)
	interactive_zone_right.set_collision_mask_value(1, interactable)
	set_collision_mask_value(5, interactable)
	set_collision_mask_value(6, interactable)
	set_collision_mask_value(1, interactable)
	var breakable = is_breakable()
	hitbox_area.set_collision_mask_value(2, breakable)
		
func is_interactable() -> bool:
	return vase_type == VaseTypeEnum.INTERACTABLE
	
func is_breakable() -> bool:
	return vase_type == VaseTypeEnum.BREAKABLE

func _on_player_attack(body: Node2D) -> void:
	if not is_breakable(): return
	if not is_break:
		is_break = true
		audio_controller.play_sound("Break")
		animator.play("break")
