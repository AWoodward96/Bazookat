extends Node2D
class_name BazookaBehavior

@export var e_owner : PlayerController
@export var e_bulletPrefab : PackedScene
@export var e_visualParent : Node2D
@export var e_visual : AnimatedSprite2D
@export var e_emitterParent : Node2D

@export var e_reloadSpeed : float = 1

@export var e_shootRocketSFX : FmodEventEmitter2D
@export var e_noAmmoSFX : FmodEventEmitter2D

var HasAmmo : bool :
	get:
		return m_hardCD <= 0 && m_hasAmmo

var Camera : MainCamera :
	get:
		if Level.Current != null:
			return Level.Current.Camera
		else:
			return get_viewport().get_camera_2d()

var m_hardCD : float
var m_hasAmmo : bool

var db_currentAngle : float


func UpdateBazookaVisibility(_visible : bool):
	e_visual.visible = _visible

func _physics_process(_delta: float) -> void:
	if Camera == null || !e_owner.e_hasBazooka || e_owner.e_state != PlayerController.EState.Normal:
		return

	if e_owner.e_state == PlayerController.EState.Cutscene:
		e_visualParent.rotation = 0
		e_visual.flip_v = false
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
		if HasAmmo:
			Fire(e_emitterParent.global_position, dst)
		else:
			e_noAmmoSFX.play()

	e_visual.material.set_shader_parameter("perform_color_swap", !HasAmmo)
	if m_hardCD > 0:
		m_hardCD -= _delta
	pass

func UpdateDisplay():
	if Camera == null:
		return

func ForceReload(_overrideTimer : bool = false):
	m_hasAmmo = true
	if _overrideTimer:
		m_hardCD = 0

func Fire(_origin : Vector2, _direction : Vector2):
	e_shootRocketSFX.play()

	m_hardCD = e_reloadSpeed
	m_hasAmmo = false

	if e_owner is PlayerController:
		e_owner.db_jumpedWithLastRocket = false
		e_owner.db_lastRocketJumpPerfect = false

	var directionNormalized = _direction.normalized()
	var bulletInstance = GameManager.GetFromPool(e_bulletPrefab) as BulletBehavior
	bulletInstance.Instantiate(directionNormalized)
	bulletInstance.global_position = _origin
	get_tree().root.add_child(bulletInstance)
