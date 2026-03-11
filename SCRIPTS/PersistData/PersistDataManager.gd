extends Node2D

static var SAVEDATA_DIR = "user://SAVEDATA/"
static var PLAYER_FILE = "user://SAVEDATA/Player.json"
static var GLOBAL_FILE = "user://SAVEDATA/Global.json"
static var PlayerPersist : PlayerPersistData
static var GlobalPersist : GlobalPersistData

signal Initialized

func _ready():
	ValidateDirectories()
	LoadPersistData()
	await get_tree().physics_frame
	Initialized.emit()
	pass

func ValidateDirectories():
	var dir = DirAccess.open("user://")
	if !dir.dir_exists(SAVEDATA_DIR):
		DirAccess.make_dir_absolute(SAVEDATA_DIR)
	pass

func LoadPersistData():
	LoadGlobal()
	LoadPlayer()
	pass

func LoadGlobal():
	if !FileAccess.file_exists(GLOBAL_FILE):
		GlobalPersist = GlobalPersistData.CreateNewGlobalPersist()
	else:
		var parsedString = GetJSONFromTextFile(GLOBAL_FILE)
		if parsedString == null:
			GlobalPersist = GlobalPersistData.CreateNewGlobalPersist()
		else:
			GlobalPersist = GlobalPersistData.new()
			GlobalPersist.name = GlobalPersistData.NODENAME
			add_child(GlobalPersist)
			GlobalPersist.FromJSON(parsedString)

func SaveAll():
	GlobalPersist.Save()
	PlayerPersist.Save()

func GetJSONFromTextFile(_path : String):
	var save_file = FileAccess.open(_path, FileAccess.READ)
	var fileText = save_file.get_as_text()
	return JSON.parse_string(fileText)

func LoadPlayer():
	if !FileAccess.file_exists(PLAYER_FILE):
		PlayerPersist = PlayerPersistData.CreateNewPlayerPersistData()
	else:
		var parsedString = GetJSONFromTextFile(PLAYER_FILE)
		if parsedString == null:
			PlayerPersist = PlayerPersistData.CreateNewPlayerPersistData()
		else:
			PlayerPersist = PlayerPersistData.new()
			PlayerPersist.name = PlayerPersistData.NODENAME
			add_child(PlayerPersist)
			PlayerPersist.FromJSON(parsedString)
	pass
