extends Node2D
class_name SimpleLauncher


@export var e_launchData : LaunchData
@export var e_timer : Timer

var m_onCD : bool = false


func OnEnter(_body : Node2D):
	if _body is PlayerController && !m_onCD:
		m_onCD = true
		e_timer.start()
		_body.Launch(e_launchData)
	pass

func TimerTimeout():
	m_onCD = false
