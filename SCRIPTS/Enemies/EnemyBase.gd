extends CharacterBody2D
class_name EnemyBase

const DEATHSPEEDDAMPENING : float = 0.95
const DEATHVECTORMULTIPLIER : float = 100

@export var e_visual : AnimatedSprite2D
@export var e_affectedByGravity : bool = true
@export var e_collider : CollisionShape2D

var m_startingPosition : Vector2
var m_killed : bool
var m_active : bool


func _ready():
	m_startingPosition = global_position

func Kill(_direction : Vector2):
	if !m_killed:
		velocity = -_direction.normalized() * DEATHVECTORMULTIPLIER
		m_killed = true

		# cause this can happen in a collision call
		var defferedCollisionOff = func() : e_collider.disabled = true
		defferedCollisionOff.call_deferred()

		DeathAnimation()

func DeathAnimation():
	var tween = get_tree().create_tween()
	e_visual.material.set_shader_parameter("color_override", Color.WHITE)
	tween.tween_method(func(_val) : e_visual.material.set_shader_parameter("use_color_override", _val), 0, 1, 0.5)
	tween.tween_interval(0.5)

	tween.tween_callback(DeathAnimationComplete)
	pass

func DeathAnimationComplete():
	var deathParticle = GameManager.e_gameData.e_genericDeathParticle.instantiate()
	deathParticle.global_position = global_position
	get_tree().root.add_child(deathParticle)

	# I don't think I care about pooling enemies. There aren't gonna be a billion of them
	queue_free()

func Activate(_active : bool):
	m_active = _active

	if !_active:
		OnRoomReset()

func OnRoomReset():
	# don't do anything if you're ded/in the process of dying
	if m_killed:
		return

	velocity = Vector2.ZERO
	global_position = m_startingPosition
	pass
