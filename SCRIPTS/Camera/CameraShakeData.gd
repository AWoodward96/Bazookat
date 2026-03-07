extends Resource
class_name CameraShakeData

@export var e_strength : float = 10
@export var e_duration : float = 1
var m_timer : float

func Start():
	m_timer = e_duration
