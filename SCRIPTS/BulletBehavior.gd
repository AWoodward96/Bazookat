extends Node2D
class_name BulletBehavior

@export var e_speed : float = 10
@export var e_direction : Vector2
@export var e_raycaster : RayCast2D
@export var e_visual : Node2D
@export var e_rotateVisual : bool = true

# Particles that disconect and reparent to the Root Node that auto destroy
@export var e_autonomousParticleParent : Node2D
@export var e_autonomousParticle : PackedScene
@export var e_particleCleanup : float = 0.5
@export var e_pool : bool = true

var m_orign : Vector2
var m_released : bool
var m_createdParticle : Node2D
var m_lifetime : float

func Instantiate(_direction : Vector2):
	e_direction = _direction
	m_released = false
	m_lifetime = 0

	CleanupParticle()
	if e_autonomousParticleParent != null && e_autonomousParticle:
		m_createdParticle = e_autonomousParticle.instantiate()
		e_autonomousParticleParent.add_child(m_createdParticle)
		m_createdParticle.position = Vector2.ZERO

func _physics_process(_delta: float):
	m_lifetime += _delta
	var movementVector = e_direction * e_speed * _delta

	if e_rotateVisual && e_visual != null:
		e_visual.rotation = e_direction.angle()


	e_raycaster.target_position = movementVector
	e_raycaster.force_raycast_update()
	if e_raycaster.is_colliding():
		var point = e_raycaster.get_collision_point()
		var dst = (point - global_position) as Vector2

		# This ensures that the bullet doesn't sink into the ground if moving at high speeds
		if dst.length() < (e_speed * _delta):
			global_position = point
			return

	global_position += movementVector


func _on_area_2d_body_entered(_body: Node2D):
	Destroy.call_deferred()

func Destroy():
	if e_pool:
		if !m_released:
			m_released = true
			if m_createdParticle != null:
				# This needs to be fixed later. Based on how the particle gets created
				# You can have the cleanupparticle go off after the object gets pooled and reinitialized
				m_createdParticle.reparent(get_tree().root)
				var cleanup = get_tree().create_timer(e_particleCleanup)
				cleanup.timeout.connect(CleanupParticle)

			GameManager.ReturnToPool(self)
	else:
		queue_free()
	pass

func CleanupParticle():
	if m_createdParticle != null:
		m_createdParticle.queue_free()
		m_createdParticle = null

	pass
