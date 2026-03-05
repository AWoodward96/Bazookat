extends CharacterBody2D
## Basically the player
class_name PlayerController

enum ECardinalDirections8 { N, ne, E, se, S, sw, W, nw}
enum EState { Normal, Death, Respawn }

@export var e_visual : AnimatedSprite2D
@export var e_bazooka : BazookaBehavior
@export var e_animationTree : AnimationTree
@export var e_state : EState = EState.Normal

@export_category("Running Information")
@export var e_horizontalSpeed : float = 200
@export var e_sprintSpeed : float = 300
@export var e_exitSprintStateDuration : float = 1
@export var e_aerialExtraHorizontal : float = 75
@export var e_horizontalAcceleration : float = 1500
@export var e_horizontalLockoutMultiplier : float = 0.5

@export_category("Jump Information")
@export var e_jumpCutRatio : float = 0.4
@export var e_jumpBufferWindow : float = 0.1
@export var e_coyoteTimeWindow : float = 0.14
@export var e_maxDownwardVelocity : float = 600
@export var e_fastFallMultiplier : float = 2
@export var e_extraHangThreshold : float = 1
@export var e_extraHangMultiplier : float = 0.25
@export var e_pogoVerticalLockoutDuration : float = 0.5

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
@export var e_rocketAngleParticleParent : Node2D
@export var e_rocketAngleParticles : CPUParticles2D

@export_category("Rocket Jump Information")
@export var e_rocketJumpDirectionData : Array[RocketForceHelper]
@export var e_perfectRocketJumpWindow : float = 0.125
@export var e_perfectRocketJumpGravityMultiplier : float = 0.5
@export var e_perfectRocketJumpGravityDuration : float = 1

@export_category("Death")
@export var e_deathCast : ShapeCast2D
@export var e_deathDuration : float = 0.5
@export var e_deathBounce : float = 10
@export var e_deathVelocityDamp : float = 0.9
@export var e_deathParticle : CPUParticles2D


var Gravity : float :
	get:
		return GameManager.GameData.Gravity

var JumpForce : float :
	get:
		return GameManager.GameData.JumpForce


var m_horizontal : float
var m_facingLeft : bool
var m_backpedaling : bool
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

var m_sprinting : bool
var m_inSprintAnimState : bool
var m_endSprintAnimTimer : float
var m_wallNormal : Vector2
var m_horizontalLockoutTimer : float
var m_verticalCutLockoutTimer : float
var m_climbing : bool
var m_climbingStamina : float
var m_sliding : bool

var m_deathTimer : float
var m_fallbackOriginalPosition : Vector2
var m_deathTween : Tween

var m_perfectRocketJumpTimer : float
var m_perfectRocketJumpSuccessTimer : float

# DEBUG
var db_jumpedWithLastRocket : bool = false
var db_lastRocketJumpDirection : ECardinalDirections8
var db_lastRocketJumpPerfect : bool
var db_lastAngleShot : float


func _ready():
	m_fallbackOriginalPosition = global_position

func _physics_process(_delta: float):
	match e_state:
		EState.Normal:
			HandleInput(_delta)
			HandlePhysics(_delta)
		EState.Death:
			velocity *= e_deathVelocityDamp
			move_and_slide()

	HandleParticles()

func HandleInput(_delta : float):
	# Horizontal Movement
	m_horizontal = 0
	if Input.is_action_pressed("left"):
		m_horizontal += -1
	if Input.is_action_pressed("right"):
		m_horizontal += 1

	if Input.is_action_pressed("sprint"):
		m_sprinting = true
		m_endSprintAnimTimer = e_exitSprintStateDuration
	else:
		m_sprinting = false

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
	m_climbing = m_onWall && m_upHeld && m_climbingStamina > 0 && (m_climbing || velocity.y > e_climbStartThreshold) && m_verticalCutLockoutTimer <= 0

	m_inSprintAnimState = m_endSprintAnimTimer > 0

	var bazookaVisible = !m_inSprintAnimState && !m_sliding && !m_climbing
	e_bazooka.UpdateBazookaVisibility(bazookaVisible)
	if Level.Current != null && Level.Camera != null:
		m_backpedaling = (Level.Camera.m_mouseWorldPosition.x < global_position.x && !m_facingLeft) || (Level.Camera.m_mouseWorldPosition.x > global_position.x && m_facingLeft)

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

	if m_endSprintAnimTimer > 0:
		m_endSprintAnimTimer -= _delta

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


	CheckDeath()
	move_and_slide()

	# flip the sprite based on the last direction we moved
	if velocity.x < 0:
		m_facingLeft = true
	if velocity.x > 0:
		m_facingLeft = false
	e_visual.flip_h = m_facingLeft

func HandleHorizontal(_delta):
	var horizontalVelocity = velocity.x

	# Nerf the horizontal acceleration if you've done a walljump recently.
	# This lets us briefly exceed the horizontal speed after performing a wall jump
	var desiredAcceleration = e_horizontalAcceleration
	if m_horizontalLockoutTimer > 0:
		desiredAcceleration *= e_horizontalLockoutMultiplier

	horizontalVelocity = move_toward(horizontalVelocity, m_horizontal * GetHorizontalSpeed(), desiredAcceleration * _delta)

	velocity = Vector2(horizontalVelocity, velocity.y)


func HandleParticles():
	e_wallslideParent.scale.x = -m_wallNormal.x
	e_wallslideParticle.emitting = m_sliding && e_state == EState.Normal

	e_climbParticleParent.scale.x = -m_wallNormal.x
	e_climbParticle.emitting = m_climbing && e_state == EState.Normal


func RocketJump(_rocketPosition : Vector2, _disruptionDuration : float):
	# Get the rotation of the rocket relative to the player
	var dstFromRocket = _rocketPosition - global_position
	var angle = rad_to_deg(dstFromRocket.angle())

	# I don't like it when I've got negative angles or angles greater than 360. Simplify
	if angle < 0:
		angle += 360
	elif angle > 360:
		angle -= 360

	if e_rocketAngleParticleParent != null:
		e_rocketAngleParticleParent.rotation = deg_to_rad(angle)
		e_rocketAngleParticles.emitting = true

	db_lastAngleShot = angle
	# THIS FEELS AMAZING YESSSSSSSSSSS
	var direction = GetDirectionFromRocketJumpAngle(angle)
	var index = e_rocketJumpDirectionData.find_custom(func(x : RocketForceHelper) : return x.e_direction == direction)
	if index == -1:
		# This should literally never happen but:
		push_error("Could not find rocket jump information. Angle: ", str(angle), " Direction: ", PlayerController.ECardinalDirections8.find_key(direction))
		return

	var data = e_rocketJumpDirectionData[index]
	var perfectMult : float = 1
	if m_perfectRocketJumpTimer > 0:
		perfectMult = data.e_perfectModifier
		m_perfectRocketJumpSuccessTimer = e_perfectRocketJumpGravityDuration

	var desiredVelocity = velocity
	if data.e_HasXForce:
		desiredVelocity = Vector2(data.e_XDirection, data.e_YForceMultiplier * JumpForce * perfectMult)
	else:
		desiredVelocity = Vector2(velocity.x, data.e_YForceMultiplier * JumpForce * perfectMult)

	velocity = desiredVelocity

	m_horizontalLockoutTimer = data.e_horizontalLockoutDuration
	m_verticalCutLockoutTimer = data.e_upwardCutLockoutDuration

	db_lastRocketJumpDirection = direction
	db_lastRocketJumpPerfect = perfectMult != 1
	db_jumpedWithLastRocket = true

	pass

func GetDirectionFromRocketJumpAngle(_angle : float):
	## This is complicated
	## S is a 70 degree arc
	## SE and SW are a 55 degree arc
	## W and E are both 50 degree's and are skewed above the horizontal (IE if they're below the horizontal, they're SW and SE)
	## N is 20, while the NE and NW are both at 30
	## I think in the future, NE and NW might want to be smaller, and W and E might want to be bigger but...

	## We do this because we don't want a player on the ground, aiming for a SE/SW jump accidentally hitting a perfect EW jump
	## We also don't want to accidentally hit a NW and NE when we're going for an E or a W, so that's why all the angles are skewed

	var ewAngle : float = 50
	var sAngle : float = 70.0
	var nAngle : float = 20
	var halfS = sAngle / 2
	var halfN = nAngle / 2

	if _angle > 360 - (ewAngle):
		return ECardinalDirections8.E 							# 50
	elif _angle > 0 && _angle <= 90 - halfS:
		return ECardinalDirections8.se 							# 55
	elif _angle > 90 - halfS && _angle <= 90 + halfS:
		return ECardinalDirections8.S 							# 70
	elif _angle > 90 + halfS && _angle <= 180:
		return ECardinalDirections8.sw 							# 55
	elif _angle > 180 && _angle <= 180 + (ewAngle):
		return ECardinalDirections8.W 							# 50
	elif _angle > 180 + (ewAngle) && _angle <= 270 - halfN:
		return ECardinalDirections8.nw 							# 30
	elif _angle > 270 - halfN && _angle <= 270 + halfN:
		return ECardinalDirections8.N 							# 20
	else:
		return ECardinalDirections8.ne 							# 30

func GetHorizontalSpeed():
	var speed = e_horizontalSpeed

	if m_sprinting && m_onFloor:
		speed = e_sprintSpeed

	if !m_onFloor:
		speed += e_aerialExtraHorizontal

	return speed

func Die(_normal : Vector2):
	if e_state == EState.Normal:
		velocity = _normal.normalized() * e_deathBounce
		e_state = EState.Death
		m_deathTimer = e_deathDuration

		e_bazooka.UpdateBazookaVisibility(false)
		e_visual.material.set_shader_parameter("color_override", Color.WHITE)
		e_visual.material.set_shader_parameter("use_color_override", 1.0)


		await get_tree().create_timer(0.35).timeout
		e_deathParticle.emitting = true
		e_visual.visible = false
		await get_tree().create_timer(0.35).timeout

		if !UIManager.OnFadeComplete.is_connected(OnDeathFadeOutComplete):
			UIManager.OnFadeComplete.connect(OnDeathFadeOutComplete)
		UIManager.FadeOut(e_deathDuration, e_deathDuration)
	pass

func OnDeathFadeOutComplete():
	if UIManager.OnFadeComplete.is_connected(OnDeathFadeOutComplete):
		UIManager.OnFadeComplete.disconnect(OnDeathFadeOutComplete)
	UIManager.FadeIn(e_deathDuration)
	Respawn()

func SetOutlineParam(_value : float):
	e_visual.material.set_shader_parameter("thickness", _value)

func SetColorOverrideParam(_value : float):
	e_visual.material.set_shader_parameter("use_color_override", _value)

func Respawn():
	e_state = EState.Respawn

	e_visual.visible = true
	var respawnPosition = m_fallbackOriginalPosition
	if Room.Current != null:
		var room = Room.Current
		if room.m_currentRespawnPoint != null:
			respawnPosition = room.m_currentRespawnPoint.e_respawnPoint.global_position
		elif room.e_defaultRespawnPoint != null:
			respawnPosition = room.e_defaultRespawnPoint.e_respawnPoint.global_position

		room.ResetRoom()

	m_deathTween = get_tree().create_tween()
	m_deathTween.tween_method(SetOutlineParam, 15, 1, 0.5)
	m_deathTween.tween_method(SetColorOverrideParam, 1, 0, 0.5)
	m_deathTween.tween_callback(func() : e_state = EState.Normal)
	m_deathTween.play()
	global_position = respawnPosition
	e_deathParticle.emitting = true

func CheckDeath():
	for index in e_deathCast.get_collision_count():
		var collider = e_deathCast.get_collider(index)
		if collider == null:
			continue

		if collider is TileMapLayer:
			# this is just death. You've hit the death layer
			Die(e_deathCast.get_collision_normal(index))
		else:
			var enemy = collider.get_collision_mask_value(3)
			if enemy && collider is EnemyBase:
				if velocity.y > 0:
					# kill the enemy
					velocity.y = -JumpForce
					m_verticalCutLockoutTimer = e_pogoVerticalLockoutDuration
					collider.Kill()
					pass
				else:
					Die(e_deathCast.get_collision_normal(index))
	pass
