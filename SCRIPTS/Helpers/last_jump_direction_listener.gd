extends Label


func _process(_delta: float):
	if Level.Current != null && Level.Player != null:
		var player = Level.Player
		var angle = round(player.db_lastAngleShot)
		if player.db_jumpedWithLastRocket:
			text = str(PlayerController.ERocketJumpDirections.find_key(player.db_lastRocketJumpDirection)) + "(" + str(angle) + ")"
		else:
			text = ""
