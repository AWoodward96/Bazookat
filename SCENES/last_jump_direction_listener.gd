extends Label

@export var player : PlayerController

func _process(_delta: float):
	if player != null:
		if player.db_jumpedWithLastRocket:
			text = str(PlayerController.ECardinalDirections8.find_key(player.db_lastRocketJumpDirection))
		else:
			text = ""
