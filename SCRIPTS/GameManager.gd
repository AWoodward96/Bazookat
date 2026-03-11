extends Node2D

const TILESIZE = 16

@export var e_playerPrefab : PackedScene
@export var e_cameraPrefab : PackedScene
@export var e_gameData : GameSettings

var pool_parent : Node2D
var object_pool : Dictionary


func _ready() -> void:
	pool_parent = Node2D.new()
	pool_parent.name = "GOPool"
	add_child(pool_parent)

	await PersistDataManager.Initialized

	if RunningMainScene():
		ReturnToMainMenu()

func ReturnToMainMenu():
	UIManager.OpenUI(UIManager.e_mainMenuUI)
	UIManager.FadeIn(1)

func GetFromPool(_packedScene : PackedScene):
	if object_pool.has(_packedScene.resource_path):
		var list = object_pool[_packedScene.resource_path] as Array
		if list.size() > 0:
			var ref = list.pop_front()
			ref.visible = true

			# This is fucking stupid. If you just remove_child it throws an error
			var parent = ref.get_parent()
			if parent != null:
				parent.remove_child(ref)
			return ref
		else:
			var instantiate = _packedScene.instantiate()
			return instantiate
	else:
		var instantiate = _packedScene.instantiate()
		return instantiate

func ReturnToPool(_object : Node2D):
	if _object.scene_file_path == "":
		push_error("Object: ", _object.name, " is being released to pool but doesn't have a scene file path. Object will be freed instead.")
		return

	if !object_pool.has(_object.scene_file_path):
		object_pool[_object.scene_file_path] = []

	object_pool[_object.scene_file_path].append(_object)
	_object.reparent(pool_parent)
	_object.hide()

func RunningMainScene():
	return get_tree().get_first_node_in_group("MainScene") != null

func SendQuitNotification():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _notification(_closeNotification):
	# From Godot docs: https://docs.godotengine.org/en/latest/tutorials/inputs/handling_quit_requests.html
	if _closeNotification == NOTIFICATION_WM_CLOSE_REQUEST:
		OnQuit()

## Do not call directly. Please only use SendQuitNotification
## Failure to do this will un-standardize the quit process and could break save games
func OnQuit():
	get_tree().quit() # default behavior
