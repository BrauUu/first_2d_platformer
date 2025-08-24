extends Control

@onready var animation_timer: Timer = $AnimationTimer
@onready var coins_amount: Label = $CoinsContainer/Amount
@onready var coins_container: BoxContainer = $CoinsContainer

var player: Player
var player_health_component : HealthComponent

var count := 0
var coins_count := 0

func _ready() -> void:
	await get_tree().process_frame
	GameManager.connect("gm_player_dead", _on_player_dead)
	GameManager.connect("gm_player_spawned", _on_player_respawned)
	GameManager.connect("gm_player_hurted", _on_player_hurted)
	GameManager.connect("gm_coin_collected", _on_coin_collected)
	get_player()
	create_health_hud()
	coins_container.visible = true
	
func get_player() -> void:
		player = $"../../Player"
		player_health_component = player.get_node("HealthComponent")
		count = 0
	
func create_health_hud() -> void:
	var node_size = 48
	var node_gap = 5
	for i in player_health_component.health:
		var full_heart = $HeartsContainer/FullHeart.duplicate()
		full_heart.visible = true
		full_heart.position.x = (node_size + node_gap) * i
		$HeartsContainer.add_child(full_heart)
		full_heart.animation = "full"

func lose_health_hud(lost_health: int) -> void:
	var hearts = $HeartsContainer.get_children()
	for i in range(lost_health + player_health_component.current_health, player_health_component.current_health, - 1):
		var heart = hearts[i]
		if heart.animation != "empty":
			heart.play("lost")
			await heart.animation_finished
			heart.animation = "empty"
			count -= 1
			
func animation() -> void:
	if not player: return
	var hearts = $HeartsContainer.get_children()
	var heart = hearts[player_health_component.current_health - count]
	if player_health_component.current_health == 0: return
	while heart.animation != "full":
		count += 1
		heart = hearts[player_health_component.current_health - count]
	count = (count + 1) % (player_health_component.current_health)
	var tween = create_tween()
	heart.play("idle")
	tween.tween_property(heart, "scale", Vector2(3.5, 3.5), 0.75)
	tween.tween_property(heart, "scale", Vector2(3, 3), 0.75)
	await heart.animation_finished
	heart.animation = "full"
	
func recovery_health_hud() -> void:
	var hearts = $HeartsContainer.get_children()
	var heart = hearts[player_health_component.current_health]
	heart.animation = "full"
	
func reset_health_hud() -> void:
	var hearts = $HeartsContainer.get_children().slice(1, len($HeartsContainer.get_children()))
	for heart in hearts:
		$HeartsContainer.remove_child(heart)
	create_health_hud()
	
func _on_player_hurted(damage_info: Dictionary) -> void:
	var damage = damage_info.damage
	lose_health_hud(damage)
	
func _on_player_dead(damage_info: Dictionary) -> void:
	lose_health_hud(player_health_component.health)
	
func _on_player_respawned() -> void:
	get_player()
	reset_health_hud()

func _on_animation_timer_timeout() -> void:
	animation()
	animation_timer.start()
	
func _on_coin_collected() -> void:
	coins_count += 1
	coins_amount.text = str(coins_count)
