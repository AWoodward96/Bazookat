@tool
extends Node2D
class_name Level

static var Current : Level
static var Player : PlayerController
static var Camera : MainCamera

@export var e_rooms : Array[Room]
@export var e_startingPosition : Node2D
@export var e_numMcGuffins : int = 0
@export var db_rebuildTree : bool = false

func _ready():
	if !Engine.is_editor_hint():
		if Current == null:
			Current = self
			Player = GameManager.e_playerPrefab.instantiate()
			add_child(Player)
			Player.position = e_startingPosition.global_position

			# set it here, so that we don't have a transition at the very start of the map
			for r in e_rooms:
				if r.Overlaps(e_startingPosition.global_position):
					Room.Current = r
					Room.Current.EnterRoom()
					break

			Camera = GameManager.e_cameraPrefab.instantiate() as MainCamera
			add_child(Camera)
			Camera.e_target = Player
			Camera.global_position = Player.position

		if e_startingPosition != null:
			e_startingPosition.visible = false

func _process(_delta: float):
	if Engine.is_editor_hint():
		if !child_entered_tree.is_connected(EDITOR_OnChildEntered):
			child_entered_tree.connect(EDITOR_OnChildEntered)

		if db_rebuildTree:
			db_rebuildTree = false
			e_rooms.clear()

			e_numMcGuffins = 0
			for children in get_children():
				if children is Room:
					e_rooms.append(children)
					e_numMcGuffins += children.e_mcGuffins.size()
		pass

func EDITOR_OnChildEntered(_node : Node):
	db_rebuildTree = true


func EnterRoom(_newRoom : Room):
	if Room.Current != null:
		Room.Current.ExitRoom()
	Room.Current = _newRoom
	Room.Current.EnterRoom()
	pass

func CleanUp():
	# This is called but for now we're not doing anything, but it's here if we need it
	if Current == self:
		Current = null
	pass
