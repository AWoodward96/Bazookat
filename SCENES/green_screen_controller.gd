extends Node2D

func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_1):
		if Level.Current != null:
			Level.Current.Player.Die(Vector2(0, 0))
	
	if Input.is_key_pressed(KEY_0):
		if Level.Current.Camera != null:
			Level.Current.Camera.zoom += Vector2(0.25, 0.25)
	
	if Input.is_key_pressed(KEY_9):
		if Level.Current.Camera != null:
			Level.Current.Camera.zoom -= Vector2(0.25, 0.25)
