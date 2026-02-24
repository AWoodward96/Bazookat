extends Camera2D

class_name MainCamera

@export var a_idleHorizOffset : int = 32
@export var a_movingHorizOffset : int = 48
@export var a_lerpSpeed : float = 25
@export var a_defaultYOffset : int = -32
@export var a_terminalOffset : int = 128
@export var a_terminalOffsetCurve : Curve

var m_player : PlayerController
var terminalRatio : float


func _ready():
	TryGetPlayer()

func _physics_process(_delta: float) -> void:
	var desiredPosition = global_position
	if m_player != null:
		desiredPosition = m_player.global_position

		terminalRatio = (m_player.e_terminalGravity - m_player.velocity.y) / m_player.e_terminalGravity
		desiredPosition += Vector2(0, a_terminalOffset * a_terminalOffsetCurve.sample(1 - terminalRatio))


		var xOffset = 0
		if m_player.m_facingLeft:
			if m_player.m_horizontal != 0:
				xOffset = -a_movingHorizOffset
			else:
				xOffset = -a_idleHorizOffset
		else:
			if m_player.m_horizontal != 0:
				xOffset = a_movingHorizOffset
			else:
				xOffset = a_idleHorizOffset

		desiredPosition += Vector2(xOffset, 0)

	global_position = lerp(global_position, desiredPosition, a_lerpSpeed * _delta)


# TEMPORARY - FIX WHEN YOU HAVE A LEVEL SYSTEM
func TryGetPlayer():
	var playerNodes = get_tree().get_nodes_in_group("Player")
	if playerNodes.size() != 0:
		m_player = playerNodes[0]
