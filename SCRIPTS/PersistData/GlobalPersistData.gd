extends Node2D
class_name GlobalPersistData

static var NODENAME = "GlobalPersistData"

var m_levelPersistData : Array[LevelPersistData]

func RegisterMcGuffinCollected(_level : Level, _mcGuffin : McGuffin):
	if _mcGuffin == null:
		return

	var level = GetLevelPersistData(_level)
	level.RegisterMcGuffinCollected(_mcGuffin)
	Save()

func GetMcGuffinColected(_level : Level, _mcGuffin : McGuffin):
	for l : LevelPersistData in m_levelPersistData:
		if l.m_levelID == _level.scene_file_path:
			return l.m_mcGuffinsCollected.has(_mcGuffin)

	return false

func GetLevelPersistData(_level : Level):
	for l : LevelPersistData in m_levelPersistData:
		if l.m_levelID == _level.scene_file_path:
			return l

	var newLevelPersist = LevelPersistData.CreateLevelPersistData(_level)
	m_levelPersistData.append(newLevelPersist)
	return newLevelPersist

func Save():
	var save_file = FileAccess.open(PersistDataManager.GLOBAL_FILE, FileAccess.WRITE)
	var toJSON = ToJSON()
	var stringify = JSON.stringify(toJSON, "\t")
	save_file.store_line(stringify)

func ToJSON():
	var saveData = {
		"m_levelPersistData" = PersistDataManager.ArrayToJSON(m_levelPersistData)
	}
	return saveData

func FromJSON(_dict : Dictionary):
	var returnedArray = PersistDataManager.JSONToArray(_dict["m_levelPersistData"], Callable.create(LevelPersistData, "FromJSON"))
	m_levelPersistData.assign(returnedArray)


static func CreateNewGlobalPersist():
	var globalPersist = GlobalPersistData.new()
	globalPersist.name = NODENAME
	PersistDataManager.add_child(globalPersist)

	globalPersist.Save()
	# Not much else to do here yet but we've got it now at least
