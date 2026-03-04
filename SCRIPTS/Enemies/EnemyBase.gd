extends CharacterBody2D
class_name EnemyBase


@export var e_visual : AnimatedSprite2D
@export var e_affectedByGravity : bool = true

var m_startingPosition : Vector2
var m_killed : bool
var m_active : bool





func _ready():
	m_startingPosition = global_position

func Kill():
	m_killed = true
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
