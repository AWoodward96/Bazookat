extends Label


func _process(_delta: float):
	if Level.Current != null && Level.Player != null:
		var player = Level.Player
		var angle = round(player.e_bazooka.db_currentAngle)
		var cardinal = player.GetDirectionFromRocketJumpAngle(angle)
		text = str(angle) + " - " + str(PlayerController.ERocketJumpDirections.find_key(cardinal.e_direction))
