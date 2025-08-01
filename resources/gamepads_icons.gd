extends Node

var icons_paths = {
	"keyboard": {
		"path": "res://assets/sprites/hud/keys/keyboard_black.png",
		"move": Rect2(176,64,48,32),
		"move_left": Rect2(48,48,16,16),
		"move_right": Rect2(80,48,16,16),
		"jump": Rect2(80,80,80,16),
		"attack": Rect2(112,48,16,16),
		"pause": Rect2(24,0,24,16),
		"interact": Rect2(80,32,16,16),
		"interact-pressed": Rect2(80,128,16,16)
	},
	"xbox": {
		"path": "res://assets/sprites/hud/keys/xone.png",
		"move": Rect2(48,64,16,16),
		"move_left": Rect2(64,64,16,16),
		"move_right": Rect2(96,64,16,16),
		"jump": Rect2(0,16,16,16),
		"attack": Rect2(0,48,16,16),
		"pause": Rect2(64,16,16,16),
		"interact": Rect2(0,80,16,16),
		"interact-pressed": Rect2(16,32,16,16)
	},
	"ps": {
		"path": "res://assets/sprites/hud/keys/ps4.png",
		"move": Rect2(48,64,16,16),
		"move_left": Rect2(64,192,16,16),
		"move_right": Rect2(96,192,16,16),
		"jump": Rect2(0,16,16,16),
		"attack": Rect2(0,48,16,16),
		"pause": Rect2(48,16,16,16),
		"interact": Rect2(0,80,16,16),
		"interact-pressed": Rect2(16,80,16,16),
	}
}
