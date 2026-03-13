extends Object
class_name LevelPersistData

static var NODENAME = "LevelPersistData"

var m_mcGuffinsCollected : Dictionary = {}
var m_levelID : String
var m_mcGuffinCount : int

func ToJSON():
	var saveData = {
		"m_mcGuffinsCollected" = JSON.stringify(m_mcGuffinsCollected),
		"m_levelID" = m_levelID,
		"m_mcGuffinCount" = m_mcGuffinCount
	}
	return saveData

func RegisterMcGuffinCollected(_mcGuffin : McGuffin):
	# Convert the uid to string because it's gonna be read from json later
	if !m_mcGuffinsCollected.has(str(_mcGuffin.e_uid)):
		m_mcGuffinCount += 1
		m_mcGuffinsCollected[str(_mcGuffin.e_uid)] = true


static func FromJSON(_dict : Dictionary):
	var levelPersist = LevelPersistData.new()
	levelPersist.m_levelID = _dict["m_levelID"]
	levelPersist.m_mcGuffinsCollected = JSON.parse_string(_dict["m_mcGuffinsCollected"])
	return levelPersist

static func CreateLevelPersistData(_level : Level):
	var levelData = LevelPersistData.new()
	levelData.m_levelID = _level.scene_file_path # should be unique
	return levelData
