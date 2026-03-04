extends Label


func _process(_delta: float):
	if Level.Current != null && Level.Player != null:
		text = str(Level.Player.velocity)
