extends CharacterBody2D
## Basically the player
class_name PlayerController

enum EExplosionType { Add, Set, MaxSet }

@export var e_visual : Sprite2D
@export var e_bazooka : BazookaBehavior
@export var e_explosionType : EExplosionType = EExplosionType.Add

@export_category("Running Information")
@export var e_horizontalSpeed : float = 300
@export var e_horizontalAcceleration : float = 1500
@export var e_horizontalLockoutMultiplier : float = 0.5

@export_category("Jump Information")
@export var e_jumpHeight : int = 32
@export var e_timeToJumpApex : float = 0.34
@export var e_jumpCutRatio : float = 0.4
@export var e_jumpBufferWindow : float = 0.1
@export var e_coyoteTimeWindow : float = 0.14
@export var e_maxDownwardVelocity : float = 600
@export var e_fastFallMultiplier : float = 2
@export var e_extraHangThreshold : float = 1
@export var e_extraHangMultiplier : float = 0.25

@export_category("Climbing Information")
@export var e_wallClingThreshold : float = 20
@export var e_climbingForce : float = 100
@export var e_climbingCurve : Curve
## In seconds
@export var e_climbingMaxStamina : float = 0.5
@export var e_climbStartThreshold : float = 10

@export_category("Particles")
@export var e_wallslideParent : Node2D
@export var e_wallslideParticle : CPUParticles2D
@export var e_climbParticleParent : Node2D
@export var e_climbParticle : CPUParticles2D


var Gravity : float :
	get:
		return (2 * e_jumpHeight) / pow(e_timeToJumpApex, 2)

var JumpForce : float :
	get:
		return Gravity * e_timeToJumpApex


var m_horizontal : float
var m_facingLeft : bool
var m_downHeld : bool
var m_upHeld : bool

var m_onFloor : bool
var m_onWall : bool
var m_jumpInput : bool # If there is input saying we'd like to jump
var m_jumpHeld : bool # If the jump button is currently being held down
var m_jumpBuffer : float # Checks if we pressed the jump button right before landing
var m_jump : bool # If true, the player should do a normal jump
var m_coyoteTimer : float # Timer for tracking if we can do a valid coyote time jump
var m_coyoteJump : bool # Is true if we're coyote time jumping
var m_jumpCount : int # To prevent abuse of coyote time, and to track how many times we've jumped

var m_wallNormal : Vector2
var m_horizontalLockoutTimer : float
var m_climbing : bool
var m_climbingStamina : float
var m_sliding : bool


func _physics_process(_delta: float):
	HandleInput(_delta)
	HandlePhysics(_delta)
	HandleParticles()

func HandleInput(_delta : float):
	if Input.is_physical_key_pressed(KEY_TAB):
		match e_explosionType:
			EExplosionType.Add:
				e_explosionType = EExplosionType.Set
			EExplosionType.Set:
				e_explosionType = EExplosionType.MaxSet
			EExplosionType.MaxSet:
				e_explosionType = EExplosionType.Add


	# Horizontal Movement
	m_horizontal = 0
	if Input.is_action_pressed("left"):
		m_horizontal += -1
	if Input.is_action_pressed("right"):
		m_horizontal += 1

	m_downHeld = Input.is_action_pressed("down")
	m_upHeld = Input.is_action_pressed("up")

	# Wall and floor checks
	m_onFloor = is_on_floor()
	if is_on_wall():
		m_wallNormal = get_wall_normal()
		if m_wallNormal.x < 0:
			# on the left wall
			m_onWall = m_horizontal > 0
		elif m_wallNormal.x > 0:
			# on the right wall
			m_onWall = m_horizontal < 0
	else:
		m_onWall = false

	# Standard jumping & Input
	var jumpDown = Input.is_action_just_pressed("jump")
	if jumpDown:
		m_jumpBuffer = e_jumpBufferWindow
	m_jumpInput = jumpDown || m_jumpBuffer > 0

	m_jumpHeld = Input.is_action_pressed("jump")
	m_jump = m_jumpInput && m_onFloor

	# Coyote time
	if !m_onFloor:
		m_coyoteTimer += _delta
		m_coyoteJump = m_coyoteTimer < e_coyoteTimeWindow && m_jumpInput && m_jumpCount == 0
	else:
		m_coyoteTimer = 0
		m_jumpCount = 0
		m_climbingStamina = e_climbingMaxStamina

	# sliding and climbing logic
	m_sliding = m_onWall && velocity.y > e_wallClingThreshold
	m_climbing = m_onWall && m_upHeld && m_climbingStamina > 0 && (m_climbing || velocity.y > e_climbStartThreshold)

	# Jump buffer deprecation
	if m_jumpBuffer > 0:
		m_jumpBuffer -= _delta

	if m_horizontalLockoutTimer > 0:
		m_horizontalLockoutTimer -= _delta

	if m_climbingStamina > 0 && m_climbing:
		m_climbingStamina -= _delta
	pass

func HandlePhysics(_delta : float):
	HandleHorizontal(_delta)

	if !m_onFloor:
		# Don't apply gravity if we've hit the max downward velocity
		# But still alow things to push us past that
		if !m_onWall:
			if velocity.y < e_maxDownwardVelocity:
				var gravityMult = 1
				if m_downHeld:
					gravityMult = e_fastFallMultiplier
				else:
					# Extra hang time
					if abs(velocity.y) < e_extraHangThreshold:
						gravityMult = e_extraHangMultiplier

				velocity.y += Gravity * gravityMult * _delta

			if !m_jumpHeld && velocity.y < 0 && m_horizontalLockoutTimer <= 0:
				velocity.y = velocity.y * e_jumpCutRatio
		else:
			# Climbing and sliding logic
			if m_climbing:
				var normalizedDuration = 1 - (m_climbingStamina / e_climbingMaxStamina)
				var forceMultiplier = e_climbingCurve.sample(normalizedDuration)
				velocity.y = -e_climbingForce * forceMultiplier
			elif m_sliding:
				velocity.y += Gravity * 0.15 * _delta
			else:
				velocity.y += Gravity * _delta


	if m_jump || m_coyoteJump:
		velocity.y = -JumpForce
		m_jumpCount += 1
		m_jumpBuffer = 0

	move_and_slide()

	# flip the sprite based on the last direction we moved
	if m_horizontal < 0:
		m_facingLeft = true
	if m_horizontal > 0:
		m_facingLeft = false
	e_visual.flip_h = m_facingLeft

func HandleHorizontal(_delta):

	var horizontalVelocity = velocity.x

	# Nerf the horizontal acceleration if you've done a walljump recently.
	# This lets us briefly exceed the horizontal speed after performing a wall jump
	var desiredAcceleration = e_horizontalAcceleration
	if m_horizontalLockoutTimer > 0:
		desiredAcceleration *= e_horizontalLockoutMultiplier

	horizontalVelocity = move_toward(horizontalVelocity, m_horizontal * e_horizontalSpeed, desiredAcceleration * _delta)

	velocity = Vector2(horizontalVelocity, velocity.y)


func HandleParticles():
	e_wallslideParent.scale.x = -m_wallNormal.x
	e_wallslideParticle.emitting = m_sliding

	e_climbParticleParent.scale.x = -m_wallNormal.x
	e_climbParticle.emitting = m_climbing

	pass

func ApplyRocketExplosion(_force : Vector2, _disruptionDuration : float = 0.5):
	match e_explosionType:
		EExplosionType.Add:
			velocity += _force
		EExplosionType.Set:
			velocity = _force
		EExplosionType.MaxSet:
			var xSign = sign(_force.x)
			var ySign = sign(_force.y)
			velocity = Vector2(xSign * max(abs(velocity.x), abs(_force.x)), ySign * max(abs(velocity.y), abs(_force.y)) )
	m_horizontalLockoutTimer = _disruptionDuration
	pass
