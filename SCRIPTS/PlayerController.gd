extends CharacterBody2D
## Basically the player
class_name PlayerController

@export var e_visual : Sprite2D

@export_category("Running Information")
@export var e_horizontalSpeed : float = 300
@export var e_horizontalAcceleration : float = 1500

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

@export_category("Walljump Information")
@export var e_horizontalWallJumpForce : float = 350
@export var e_wallClingThreshold : float = 20
@export var e_wallJumpMultiplier : float = 0.85
@export var e_wallJumpLockoutDuration : float = 0.15
@export var e_wallJumpLockoutHorizontalMultiplier : float = 0.5


var Gravity : float :
	get:
		return (2 * e_jumpHeight) / pow(e_timeToJumpApex, 2)

var JumpForce : float :
	get:
		return Gravity * e_timeToJumpApex

var WallJumpForce : float :
	get:
		return JumpForce * e_wallJumpMultiplier


var m_horizontal : float
var m_facingLeft : bool
var m_downHeld : bool

var m_onFloor : bool
var m_onWall : bool
var m_jumpInput : bool # If there is input saying we'd like to jump
var m_jumpHeld : bool # If the jump button is currently being held down
var m_jumpBuffer : float # Checks if we pressed the jump button right before landing
var m_jump : bool # If true, the player should do a normal jump
var m_coyoteTimer : float # Timer for tracking if we can do a valid coyote time jump
var m_coyoteJump : bool # Is true if we're coyote time jumping
var m_jumpCount : int # To prevent abuse of coyote time, and to track how many times we've jumped

var m_wallJump : bool
var m_wallNormal : Vector2
var m_wallJumpLockoutTimer : float


func _physics_process(_delta: float):
	HandleInput(_delta)
	HandlePhysics(_delta)

func HandleInput(_delta : float):
	# Horizontal Movement
	m_horizontal = 0
	if Input.is_action_pressed("left"):
		m_horizontal += -1
	if Input.is_action_pressed("right"):
		m_horizontal += 1

	m_downHeld = Input.is_action_pressed("down")

	# Wall and floor checks
	m_onFloor = is_on_floor()
	if is_on_wall():
		m_wallNormal = get_wall_normal()
		if m_wallNormal.x < 0:
			# on the left wall
			m_onWall = m_horizontal > 0 && velocity.y > e_wallClingThreshold
		elif m_wallNormal.x > 0:
			# on the right wall
			m_onWall = m_horizontal < 0 && velocity.y > e_wallClingThreshold
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

	# Wall jump
	m_wallJump = is_on_wall() && m_jumpInput

	# Jump buffer deprecation
	if m_jumpBuffer > 0:
		m_jumpBuffer -= _delta

	if m_wallJumpLockoutTimer > 0:
		m_wallJumpLockoutTimer -= _delta
	pass

func HandlePhysics(_delta : float):
	var horizontalVelocity = velocity.x

	# Nerf the horizontal acceleration if yoiu've done a walljump recently.
	# This lets us briefly exceed the horizontal speed after performing a wall jump
	var desiredAcceleration = e_horizontalAcceleration
	if m_wallJumpLockoutTimer > 0:
		desiredAcceleration *= e_wallJumpLockoutHorizontalMultiplier
	horizontalVelocity = move_toward(horizontalVelocity, m_horizontal * e_horizontalSpeed, desiredAcceleration * _delta)

	velocity = Vector2(horizontalVelocity, velocity.y)

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

			if !m_jumpHeld && velocity.y < 0:
				velocity.y = velocity.y * e_jumpCutRatio
		else:
			velocity.y += Gravity * 0.15 * _delta

	if m_jump || m_coyoteJump:
		velocity.y = -JumpForce
		m_jumpCount += 1
		m_jumpBuffer = 0
	elif m_wallJump:
		velocity = Vector2(m_wallNormal.x * e_horizontalWallJumpForce, -WallJumpForce)
		m_jumpBuffer = 0
		m_wallJumpLockoutTimer = e_wallJumpLockoutDuration


	move_and_slide()

	# flip the sprite based on the last direction we moved
	if m_horizontal < 0:
		m_facingLeft = true
	if m_horizontal > 0:
		m_facingLeft = false
	e_visual.flip_h = m_facingLeft
