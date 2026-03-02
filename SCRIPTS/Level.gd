extends Node2D
class_name Level

static var Current : Level
static var Player : PlayerController
static var Camera : MainCamera

@export var e_rooms : Array[Room]
@export var e_startingPosition : Node2D

func _ready():
	if Current == null:
		Current = self
		Player = GameManager.PlayerPrefab.instantiate()
		add_child(Player)
		Player.position = e_startingPosition.global_position

		# set it here, so that we don't have a transition at the very start of the map
		for r in e_rooms:
			if r.Overlaps(e_startingPosition.global_position):
				Room.Current = r
				break

		Camera = GameManager.CameraPrefab.instantiate() as MainCamera
		add_child(Camera)
		Camera.e_target = Player
		Camera.global_position = Player.position

	if e_startingPosition != null:
		e_startingPosition.visible = false

func EnterRoom(_newRoom : Room):
	Room.Current = _newRoom
	pass
