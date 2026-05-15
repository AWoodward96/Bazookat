@tool
extends TextureRect
class_name DialogeDongleHelper

@export var e_panel : Control
@export var e_yOffset : int = -2
@export var e_xPadding : int = 2
@export var e_subject : Node2D


func _process(_delta: float) -> void:
	if e_panel != null && e_subject != null:
		# oh my god oh my god oh my god
		# I get to use the dot product for like the third time ever
		# in my game dev career I'm so excited!!!!!!!!!
		var below = e_panel.global_position.y + e_panel.size.y < e_subject.global_position.y
		var below_y_size = 0
		var y_offset = e_yOffset
		if below:
			below_y_size = e_panel.size.y
		else:
			y_offset = -y_offset - size.y

		position.y = e_panel.position.y + below_y_size + y_offset
		flip_v = !below

		# get the closest position on a line to the player
		var start = Vector2(e_panel.global_position.x + e_xPadding, e_panel.global_position.y + below_y_size)
		var end = Vector2(e_panel.global_position.x + e_panel.size.x - e_xPadding, e_panel.global_position.y + below_y_size)
		var line = (start - end).normalized()
		var dst = e_subject.global_position - start
		var dot = line.dot(dst)
		var point = start + dot * line
		global_position.x = clamp(point.x, e_panel.global_position.x + e_xPadding, e_panel.global_position.x + e_panel.size.x - e_xPadding - size.x)

		var halfpoint = e_panel.global_position.x + (e_panel.size.x / 2)
		flip_h = halfpoint > global_position.x
		pass

func AssignSubject(_node : Node2D):
	e_subject = _node
