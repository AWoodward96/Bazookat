extends Camera2D
## The one that follows the player and renders everything
class_name MainCamera

@export var e_target : Node2D
@export var e_lerpSpeed : float = 10
@export var e_mouseTrackRadius : Vector2 = Vector2(8, 48)
@export var e_velocityMultiplier : float = 0.25
@export var e_velocityLerpSpeed : float = 1
@export var e_rocketScreenShakeStrength : float = 10

@export var e_debug : bool = false
@export var e_mouseworldpositiondebugobject : Node2D

var m_mousePosition : Vector2
var m_mouseWorldPosition : Vector2
var m_velocityLerp : Vector2
var m_screenShakes : CameraShakeData


func _process(_delta: float) -> void:
	# This is happening in process instead of physics process because I need this to be AS up to date as possible
	UpdateMousePosition()
	UpdateLimits()

func _physics_process(_delta: float):
	var desiredPosition = e_target.global_position

	var mouseDST = m_mouseWorldPosition - global_position
	var magnitude = mouseDST.length()
	if magnitude > e_mouseTrackRadius.y:
		mouseDST = mouseDST.normalized() * e_mouseTrackRadius.y
	elif magnitude < e_mouseTrackRadius.x:
		mouseDST = mouseDST.normalized() * e_mouseTrackRadius.x

	mouseDST.y = mouseDST.y * .5

	desiredPosition += mouseDST

	if m_screenShakes != null:
		if m_screenShakes.m_timer > 0:
			offset = Vector2.from_angle(randf_range(0, 2 * PI)).normalized() * m_screenShakes.e_strength
			m_screenShakes.m_timer -= _delta
		else:
			m_screenShakes = null
			offset = Vector2.ZERO

	global_position = lerp(global_position, desiredPosition, e_lerpSpeed * _delta)
	pass

func UpdateMousePosition():
	m_mousePosition = get_viewport().get_mouse_position()
	var halfExtents = get_viewport_rect().size / 2
	m_mouseWorldPosition = get_screen_center_position() + m_mousePosition - halfExtents

	e_mouseworldpositiondebugobject.visible = e_debug
	e_mouseworldpositiondebugobject.global_position = m_mouseWorldPosition
	pass

func UpdateLimits():
	if Level.Current != null && Room.Current != null:
		var extents = Room.Current.GetLocalizedExtents()
		limit_left = extents.position.x
		limit_right = extents.position.x + extents.size.x
		limit_top = extents.position.y
		limit_bottom = extents.position.y + extents.size.y
		pass

func QueueScreenShake(_shakeData : CameraShakeData, _strength : float = 10, _duration : float = 1):
	if _shakeData == null:
		m_screenShakes = CameraShakeData.new()
		m_screenShakes.e_strength = _strength
		m_screenShakes.e_duration = _duration
	else:
		m_screenShakes = _shakeData

	if m_screenShakes != null:
		m_screenShakes.Start()
