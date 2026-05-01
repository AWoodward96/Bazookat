extends Label

func _process(_delta: float):
	if Level.Current != null && Level.Player != null:
		var player = Level.Player
		text = str("%0.2f" % player.m_rocketJumpExtraBoost)
