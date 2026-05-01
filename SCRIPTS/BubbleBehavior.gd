extends CharacterBody2D
class_name Bubble

@export var e_visual : AnimatedSprite2D
@export var e_carriedVelocityModifier : float = 0.85
@export var e_frictionRate : float = 3
@export var e_resetTimer : Timer
@export var e_playerCollider : CollisionShape2D
@export var e_playerHoldRoot : Node2D

@export var e_poppedSFX : FmodEventEmitter2D
@export var e_enterSFX : FmodEventEmitter2D
@export var e_respawnSFX : FmodEventEmitter2D

var m_held : bool = false
var m_disabled : bool = false
var m_homePosition : Vector2

func _ready():
	m_homePosition = global_position
	pass

func _physics_process(_delta: float) -> void:
	velocity = lerp(velocity, Vector2.ZERO, e_frictionRate * _delta)
	var collide = move_and_collide(velocity * _delta)
	if collide != null:
		velocity = velocity.bounce(collide.get_normal())
	pass

func OnPlayerEnter(_player : PlayerController):
	if e_enterSFX != null:
		e_enterSFX.play_one_shot()

	m_held = true
	velocity = _player.velocity * e_carriedVelocityModifier
	_player.Bubbled(self)
	pass

func Pop():
	if e_poppedSFX != null:
		e_poppedSFX.play_one_shot()

	m_held = false
	m_disabled = true
	e_visual.visible = false
	e_resetTimer.start()

func Reset():
	e_visual.play("respawn")
	global_position = m_homePosition
	e_visual.visible = true
	m_disabled = false
	pass

func RespawnTimerTimeout():
	if e_respawnSFX != null:
		e_respawnSFX.play_one_shot()
	Reset()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if m_disabled:
		return

	if body is PlayerController:
		OnPlayerEnter(body as PlayerController)
		pass
