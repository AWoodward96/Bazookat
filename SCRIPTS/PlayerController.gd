extends CharacterBody2D
## Basically the player
class_name PlayerController

enum ECardinalDirections8 { N, ne, E, se, S, sw, W, nw}

@export var e_visual : Sprite2D
@export var e_bazooka : BazookaBehavior

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

@export_category("Rocket Jump Information")
@export var e_rocketJumpDirectionData : Array[RocketForceHelper]
@export var e_perfectRocketJumpWindow : float = 0.125
@export var e_perfectRocketJumpYMult : float = 1.15
@export var e_perfectRocketJumpGravityMultiplier : float = 0.5
@export var e_perfectRocketJumpGravityDuration : float = 1


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
var m_verticalCutLockoutTimer : float
var m_climbing : bool
var m_climbingStamina : float
var m_sliding : bool

var m_perfectRocketJumpTimer : float
var m_perfectRocketJumpSuccessTimer : float

# DEBUG
var db_jumpedWithLastRocket : bool = false
var db_lastRocketJumpDirection : ECardinalDirections8
var db_lastRocketJumpPerfect : bool


func _physics_process(_delta: float):
	HandleInput(_delta)
	HandlePhysics(_delta)
	HandleParticles()

func HandleInput(_delta : float):
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

	if m_perfectRocketJumpTimer > 0:
		m_perfectRocketJumpTimer -= _delta

	if m_perfectRocketJumpSuccessTimer > 0:
		m_perfectRocketJumpSuccessTimer -= _delta

	if m_verticalCutLockoutTimer > 0:
		m_verticalCutLockoutTimer -= _delta

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

				if m_perfectRocketJumpSuccessTimer > 0:
					gravityMult = e_perfectRocketJumpGravityMultiplier

				velocity.y += Gravity * gravityMult * _delta

			if !m_jumpHeld && velocity.y < 0 && m_verticalCutLockoutTimer <= 0 && m_perfectRocketJumpSuccessTimer <= 0:
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
		m_perfectRocketJumpTimer = e_perfectRocketJumpWindow

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


func RocketJump(_rocketPosition : Vector2, _disruptionDuration : float):
	# Get the rotation of the rocket relative to the player
	var dstFromRocket = _rocketPosition - global_position
	var angle = rad_to_deg(dstFromRocket.angle())

	# I don't like it when I've got negative angles or angles greater than 360. Simplify
	if angle < 0:
		angle += 360
	elif angle > 360:
		angle -= 360

	print("hit: ", angle)
	# THIS FEELS AMAZING YESSSSSSSSSSS
	var direction = GetDirectionFromRocketJumpAngle(angle)
	var index = e_rocketJumpDirectionData.find_custom(func(x : RocketForceHelper) : return x.e_direction == direction)
	if index == -1:
		# This should literally never happen but:
		push_error("Could not find rocket jump information. Angle: ", str(angle), " Direction: ", PlayerController.ECardinalDirections8.find_key(direction))
		return

	var perfectMult : float = 1
	if m_perfectRocketJumpTimer > 0:
		print("Perfect!")
		perfectMult = e_perfectRocketJumpYMult
		m_perfectRocketJumpSuccessTimer = e_perfectRocketJumpGravityDuration

	print("Jump Direction: ", PlayerController.ECardinalDirections8.find_key(direction))
	var data = e_rocketJumpDirectionData[index]
	if data.e_HasXForce:
		velocity = Vector2(data.e_XDirection, data.e_YForceMultiplier * JumpForce * perfectMult)
	else:
		velocity = Vector2(velocity.x, data.e_YForceMultiplier * JumpForce * perfectMult)

	m_horizontalLockoutTimer = data.e_horizontalLockoutDuration
	m_verticalCutLockoutTimer = data.e_upwardCutLockoutDuration

	db_lastRocketJumpDirection = direction
	db_lastRocketJumpPerfect = perfectMult != 1
	db_jumpedWithLastRocket = true

	pass

func GetDirectionFromRocketJumpAngle(_angle : float):
	## This is complicated
	## The whole S, SE, and SW angles are 50 degree arcs
	## E and W are harder to hit, but are around 40 degree's, scewed slightly.
	## The scewing is basically 15 degree's below the horizontal, and 25 degree's above the horizontal

	## The N directions are basically 20 degree arcs simply because they're used way way less than the other angles

	## Basically, perfect N and perfect S have angles of 50 degrees (IE South is 90 +- (50 /2))
	## perfect E and perfect W are a bit harder to do, angles of 30 degress (IE West is 180 += (30 /2)
	## The SE and SW angles are a bit easier to hit, coming out to be 50 degree's, but a bit more angled towards the horizontal than the vertical.
	## We do this because we don't want a player on the ground, aiming for a SE/SW jump accidentally hitting a perfect EW jump

	var ewAngle : float = 30.0
	var sAngle : float = 60.0
	var nAngle : float = 20
	var halfS = sAngle / 2
	var halfEW = ewAngle / 2
	var halfN = nAngle / 2

	if _angle > 360 - (halfEW + halfN) || _angle <= halfEW:
		return ECardinalDirections8.E
	elif _angle > halfEW && _angle <= 90 - halfS:
		return ECardinalDirections8.se
	elif _angle > 90 - halfS && _angle <= 90 + halfS:
		return ECardinalDirections8.S
	elif _angle > 90 + halfS && _angle <= 180 - halfEW:
		return ECardinalDirections8.sw
	elif _angle > 180 - halfEW && _angle <= 180 + (halfEW + halfN):
		return ECardinalDirections8.W
	elif _angle > 180 + (halfEW + halfN) && _angle <= 270 - halfN:
		return ECardinalDirections8.nw
	elif _angle > 270 - halfN && _angle <= 270 + halfN:
		return ECardinalDirections8.N
	else:
		return ECardinalDirections8.ne
