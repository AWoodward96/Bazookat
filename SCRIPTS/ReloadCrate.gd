extends Node2D
class_name ReloadCrate

@export var e_visual : Sprite2D
@export var e_respawnTimer : Timer

var m_broken : bool

func Reload(_body : Node2D):
	if m_broken:
		return

	if Level.Current != null && Level.Player != null:
		if Level.Player.e_bazooka != null:
			Level.Player.e_bazooka.ForceReload(true)

		Level.Player.m_climbingStamina = Level.Player.e_climbingMaxStamina

	m_broken = true
	e_visual.visible = false
	e_respawnTimer.start()

func Respawn():
	e_visual.visible = true
	m_broken = false
	pass
