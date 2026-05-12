@tool
extends Node2D
class_name TurretBase

const AIM_OFFSET : Vector2 = Vector2(0, -16)

@export var e_barrelVisual : AnimatedSprite2D
@export var e_trackPlayer : bool
@export var e_direction : Vector2

@export var e_shootBullets : bool
@export var e_shotCD : float = 2
@export var e_bulletPrefab : PackedScene

var m_internalCD : float = 0


func _physics_process(_delta: float):
	if !Engine.is_editor_hint():
		TrackPlayer()
		Fire(_delta)
	else:
		RotateBarrel(e_direction.angle())

	pass

func Fire(_delta : float):
	if !e_shootBullets:
		return

	m_internalCD += _delta
	if m_internalCD > e_shotCD:
		m_internalCD = 0
		var bulletInstance = GameManager.GetFromPool(e_bulletPrefab) as BulletBehavior
		bulletInstance.Instantiate(e_direction)
		bulletInstance.global_position = e_barrelVisual.global_position
		get_tree().root.add_child(bulletInstance)
	pass

func TrackPlayer():
	if Level.Player != null && e_trackPlayer:
		var dst = (Level.Player.global_position  + AIM_OFFSET) - e_barrelVisual.global_position
		RotateBarrel(dst.angle())
		e_direction = Vector2.RIGHT.rotated(dst.angle())
	else:
		RotateBarrel(e_direction.angle())


func RotateBarrel(_angle : float):
	e_barrelVisual.rotation = _angle
	var inDeg = rad_to_deg(_angle)
	if inDeg < 0:
		inDeg += 360
	elif inDeg > 360:
		inDeg -= 360

	e_barrelVisual.flip_v = inDeg > 90 && inDeg < 270
