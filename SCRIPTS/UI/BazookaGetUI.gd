extends Control
class_name BazookaGetUI

signal SequenceComplete

@export var e_title : Label
@export var e_armed : Label


func _ready():
	if Level.Player != null:
		Level.Player.EnterCutscene("item_get")
		Level.Player.e_bazooka.UpdateBazookaVisibility(false)
	
		
	var tween = get_tree().create_tween()
	e_armed.modulate = Color(1,1,1,0)
	e_title.scale = Vector2(2, 2)
	
	tween.tween_property(e_title, "scale", Vector2(1.0, 1.0), 0.34)
	tween.tween_method(ZoomCamera, 1.0, 2.0, 0.34)
	tween.chain()
	tween.tween_interval(2)
	tween.tween_property(e_armed, "modulate", Color.WHITE, 2)
	tween.chain()
	tween.tween_interval(4)
	tween.tween_method(ZoomCamera, 2.0, 1.0, 0.34)
	tween.tween_callback(func(): 
		Level.Player.ExitCutscene()
		SequenceComplete.emit()
		if Level.Camera != null:
			Level.Camera.zoom = Vector2(1,1)
		queue_free())
	pass

func ZoomCamera(_val : float):
	if Level.Camera != null:
		Level.Camera.zoom = Vector2(_val, _val)
		
