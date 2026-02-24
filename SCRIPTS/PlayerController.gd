extends CharacterBody2D
## Controls the player
class_name PlayerController

@export var e_horizontalSpeed : float = 300
@export var e_horizontalAcceleration : float = 10
@export var e_visual : Sprite2D

@export var e_jumpHeight : int = 64
@export var e_timeToJumpApex : float = 0.34
@export var e_cutJumpRatio : float = 0.6
@export var e_validCoyoteWindow : float = 0.14
@export var e_validJumpBufferWindow : float = 0.1
@export var e_terminalGravity : float = 48


var Gravity : float :
	get:
		return (2 * e_jumpHeight) / pow(e_timeToJumpApex, 2)

var JumpForce : float :
	get:
		return Gravity * e_timeToJumpApex



var m_horizontal : float
var m_facingLeft : bool	# True for left, False for Right
var m_onFloor : bool
var m_jump : bool
var m_coyoteJump : bool
var m_jumpCount : int
var m_jumpInput : bool
var m_jumpBuffer : float
var m_jumpHeld : bool
var m_calculatedGravity : float
var m_coyoteTimer : float



func _process(_delta: float):
	m_horizontal = 0
	if Input.is_action_pressed("left"):
		m_horizontal += -1
	if Input.is_action_pressed("right"):
		m_horizontal += 1

	m_onFloor = is_on_floor()

	# Check the jump buffer, so that if we press the button right before we hit the ground we still jumpp
	var jumpDown = Input.is_action_just_pressed("jump")
	if jumpDown:
		m_jumpBuffer = e_validJumpBufferWindow
	m_jumpInput = jumpDown || m_jumpBuffer > 0

	# So that we can cut it later
	m_jumpHeld = Input.is_action_pressed("jump")

	m_jump = m_jumpInput && m_onFloor

	if !m_onFloor:
		m_coyoteTimer += _delta
		m_coyoteJump = m_coyoteTimer < e_validCoyoteWindow && m_jumpInput
	else:
		m_coyoteTimer = 0
		m_jumpCount = 0

	if m_jumpBuffer > 0:
		m_jumpBuffer -= _delta
	pass


func _physics_process(_delta: float):
	var horizontal = velocity.x
	horizontal = move_toward(horizontal, m_horizontal * e_horizontalSpeed, e_horizontalAcceleration)
	velocity = Vector2(horizontal, velocity.y)

	if !m_onFloor:
		#if is_on_wall_only():
			#var wallNormal = get_wall_normal()
			#if wallNormal < 0 && m_horizontal < 0:
#
			#pass

		if velocity.y < e_terminalGravity:
			velocity.y += Gravity * _delta

		if !m_jumpHeld && velocity.y < 0:
			velocity.y = velocity.y * e_cutJumpRatio

	if (m_jump || m_coyoteJump) && m_jumpCount == 0:
		m_jumpCount += 1
		m_jumpBuffer = 0 # If we jump, we want to exit out of the buffer
		velocity.y =  -JumpForce

	move_and_slide()

	# flip the sprite based on the last direction we moved
	if m_horizontal < 0:
		m_facingLeft = true
	if m_horizontal > 0:
		m_facingLeft = false
	e_visual.flip_h = m_facingLeft
	pass
