extends Label

@export var player : PlayerController

func _process(_delta: float):
	if player != null:
		if player.db_lastRocketJumpPerfect:
			text = "Perfect!"
		else:
			text = ""
