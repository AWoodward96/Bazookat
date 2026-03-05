extends Label


func _process(_delta: float):
	if Level.Current != null && Level.Player != null:
		var player = Level.Player
		var angle = round(player.db_lastAngleShot)
		text = "Last Angle: " + str(angle)
