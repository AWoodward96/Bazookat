extends Label


func _process(_delta: float):
	if Level.Current != null && Level.Player != null:
		var player = Level.Player
		if player.db_lastRocketJumpPerfect:
			text = "Perfect!"
		else:
			text = ""
