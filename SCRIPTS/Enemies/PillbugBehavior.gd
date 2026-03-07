extends EnemyBase
class_name Pillbug

enum EWalkState { Moving, Turning }

@export var e_crawlSpeed : float = 150
@export var e_crawlAcceleration : float = 1500
@export var e_walkState : EWalkState = EWalkState.Moving
@export var e_turnDuration : float = 0.5

@export var e_ledgeDetectorParent : Node2D
@export var e_ledgeDetectorCast : RayCast2D
@export var e_wallDetectorCast : RayCast2D
@export var e_startFacingLeft : bool

var m_facingLeft : bool
var m_turningTimer : float

func _ready():
	super()
	m_facingLeft = e_startFacingLeft

func _physics_process(_delta: float):
	if !m_active:
		return

	if m_killed:
		velocity = velocity * DEATHSPEEDDAMPENING
		move_and_slide()
		return

	if m_facingLeft:
		e_visual.flip_h = true
		e_ledgeDetectorParent.scale.x = -1
	else:
		e_visual.flip_h = false
		e_ledgeDetectorParent.scale.x = 1

	if !is_on_floor():
		velocity.y += GameManager.GameData.Gravity * _delta

	match e_walkState:
		EWalkState.Moving:
			var horizontal = Vector2.RIGHT
			if m_facingLeft:
				horizontal = Vector2.LEFT

			velocity.x = move_toward(velocity.x, horizontal.x * e_crawlSpeed, e_crawlAcceleration * _delta)
			move_and_slide()

			e_wallDetectorCast.force_raycast_update()
			e_ledgeDetectorCast.force_raycast_update()
			var detectedWall = e_wallDetectorCast.get_collider() != null
			var detectedLedge = (is_on_floor() && e_ledgeDetectorCast.get_collider() == null)
			if detectedLedge || detectedWall:
				StartTurn()

		EWalkState.Turning:
			velocity.x = 0
			if m_turningTimer > 0:
				m_turningTimer -= _delta
			else:
				e_walkState = EWalkState.Moving

func StartTurn():
	m_facingLeft = !m_facingLeft
	m_turningTimer = e_turnDuration
	velocity.x = 0
	e_walkState = EWalkState.Turning


func OnRoomReset():
	super()
	e_walkState = EWalkState.Moving
	m_facingLeft = e_startFacingLeft
	m_turningTimer = 0
