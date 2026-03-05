extends Node2D
class_name BazookaBehavior

@export var e_owner : Node2D
@export var e_camera : MainCamera
@export var e_bulletPrefab : PackedScene
@export var e_visualParent : Node2D
@export var e_visual : AnimatedSprite2D
@export var e_emitterParent : Node2D

var aimedDirection : Vector2
var db_currentAngle : float

var Camera : MainCamera :
	get:
		if Level.Current != null:
			return Level.Current.Camera
		else:
			return get_viewport().get_camera_2d()

func UpdateBazookaVisibility(_visible : bool):
	e_visual.visible = _visible

func _physics_process(_delta: float) -> void:
	if Camera == null:
		return

	var dst = Camera.m_mouseWorldPosition - e_owner.global_position
	if e_visualParent != null && e_visual != null:
		var angle = dst.angle()
		e_visualParent.rotation = angle

		var inDeg = rad_to_deg(angle)
		if inDeg < 0:
			inDeg += 360
		elif inDeg > 360:
			inDeg -= 360

		db_currentAngle = inDeg
		e_visual.flip_v = inDeg > 90 && inDeg < 270

	if Input.is_action_just_pressed("fire"):
		Fire(e_emitterParent.global_position, dst)
	pass

func UpdateDisplay():
	if Camera == null:
		return



func Fire(_origin : Vector2, _direction : Vector2):
	if e_owner is PlayerController:
		e_owner.db_jumpedWithLastRocket = false
		e_owner.db_lastRocketJumpPerfect = false

	var directionNormalized = _direction.normalized()
	var bulletInstance = GameManager.GetFromPool(e_bulletPrefab) as BulletBehavior
	bulletInstance.Instantiate(directionNormalized)
	bulletInstance.global_position = _origin
	get_tree().root.add_child(bulletInstance)
