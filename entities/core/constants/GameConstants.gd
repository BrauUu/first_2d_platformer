class_name GameConstants
extends RefCounted


enum Direction {
	LEFT = -1,
	NONE = 0,
	RIGHT = 1
}

const GRAVITY_SCALE: float = 1.0
const DEFAULT_JUMP_VELOCITY: float = -400.0
const DEFAULT_SPEED: float = 300.0

const IDLE_ANIMATION: String = "idle"
const WALK_ANIMATION: String = "walk"
const JUMP_ANIMATION: String = "jump"
const ATTACK_ANIMATION: String = "attack"
const HURT_ANIMATION: String = "hurt"
const DIE_ANIMATION: String = "die"

const LAYER_PLAYER: int = 1
const LAYER_PLAYER_ATTACKS: int = 2
const LAYER_ENEMY: int = 3
const LAYER_ENEMY_ATTACKS: int = 4
const LAYER_OBJECTS: int = 5
const LAYER_TERRAIN: int = 6
const LAYER_DEAD_ZONE: int = 7
const LAYER_INTERACTIVE_ZONE: int = 8
const LAYER_ANIMALS: int = 9
const LAYER_FAKE_TERRAIN: int = 10
const LAYER_BREAKABLE: int = 11
const LAYER_MESSAGE_ZONE: int = 12

const STATE_IDLE: String = "idle"
const STATE_MOVE: String = "move"
const STATE_JUMP: String = "jump"
const STATE_ATTACK: String = "attack"
const STATE_HURT: String = "hurt"
const STATE_DEATH: String = "death"
const STATE_CHASE: String = "chase"

enum TreasureState {
	DROPPING,
	DROPPED,
	COLLECTED
}

static func velocity_to_direction(velocity_x: float) -> Direction:
	if velocity_x > 0:
		return Direction.RIGHT
	elif velocity_x < 0:
		return Direction.LEFT
	else:
		return Direction.NONE

static func position_to_direction(from_pos: Vector2, to_pos: Vector2) -> Direction:
	var diff = to_pos.x - from_pos.x
	return velocity_to_direction(diff)

static func opposite_direction(direction: Direction) -> Direction:
	match direction:
		Direction.LEFT:
			return Direction.RIGHT
		Direction.RIGHT:
			return Direction.LEFT
		Direction.NONE:
			return Direction.NONE
		_:
			return Direction.NONE
