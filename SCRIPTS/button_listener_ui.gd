extends Control
class_name ButtonListenerUI

@export var e_up : TextureRect
@export var e_down : TextureRect
@export var e_inputString : String

func _process(_delta: float):
	var state = Input.is_action_pressed(e_inputString)
	e_up.visible = !state
	e_down.visible = state
