extends Camera2D
## The one that follows the player and renders everything
class_name MainCamera

@export var e_target : Node2D
@export var e_lerpSpeed : float = 10
@export var e_mouseTrackRadius : Vector2 = Vector2(8, 48)
@export var e_velocityMultiplier : float = 0.25
@export var e_velocityLerpSpeed : float = 1


@export var e_debug : bool = false
@export var e_mouseworldpositiondebugobject : Node2D


var m_mousePosition : Vector2
var m_mouseWorldPosition : Vector2
var m_velocityLerp : Vector2


func _process(_delta: float) -> void:
	# This is happening in process instead of physics process because I need this to be AS up to date as possible
	UpdateMousePosition()

func _physics_process(_delta: float):
	var desiredPosition = e_target.global_position

	var mouseDST = m_mouseWorldPosition - global_position
	var magnitude = mouseDST.length()
	if magnitude > e_mouseTrackRadius.y:
		mouseDST = mouseDST.normalized() * e_mouseTrackRadius.y
	elif magnitude < e_mouseTrackRadius.x:
		mouseDST = mouseDST.normalized() * e_mouseTrackRadius.x
		
	mouseDST.y = mouseDST.y * .5

	#if e_target is PlayerController:
		#m_velocityLerp = lerp(m_velocityLerp, e_target.velocity * e_velocityMultiplier, e_velocityLerpSpeed * _delta)
		#desiredPosition += Vector2(m_velocityLerp.x, 0)

	desiredPosition += mouseDST

	global_position = lerp(global_position, desiredPosition, e_lerpSpeed * _delta)
	pass

func UpdateMousePosition():
	m_mousePosition = get_viewport().get_mouse_position()
	var halfExtents = get_viewport_rect().size / 2
	m_mouseWorldPosition = global_position + m_mousePosition - halfExtents

	e_mouseworldpositiondebugobject.visible = e_debug
	e_mouseworldpositiondebugobject.global_position = m_mouseWorldPosition
	pass
