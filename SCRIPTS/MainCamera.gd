extends Camera2D
## The one that follows the player and renders everything
class_name MainCamera

@export var e_target : Node2D
@export var e_lerpSpeed : float = 10
@export var e_debug : bool = false
@export var e_mouseworldpositiondebugobject : Node2D
var m_mousePosition : Vector2
var m_mouseWorldPosition : Vector2



func _physics_process(_delta: float):
	global_position = lerp(global_position, e_target.global_position, e_lerpSpeed * _delta)
	UpdateMousePosition()
	pass

func UpdateMousePosition():
	m_mousePosition = get_viewport().get_mouse_position()
	var halfExtents = get_viewport_rect().size / 2
	m_mouseWorldPosition = global_position + m_mousePosition - halfExtents

	e_mouseworldpositiondebugobject.visible = e_debug
	e_mouseworldpositiondebugobject.global_position = m_mouseWorldPosition
	pass
