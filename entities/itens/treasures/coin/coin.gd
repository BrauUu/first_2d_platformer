extends Treasure

func collect() -> void:
	super()
	GameManager.coin_collected()
