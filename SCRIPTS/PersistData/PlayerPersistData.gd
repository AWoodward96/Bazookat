extends Node2D
class_name PlayerPersistData

static var NODENAME = "PlayerPersistData"

var m_pickedUpBazooka : bool

func Save():
	var save_file = FileAccess.open(PersistDataManager.PLAYER_FILE, FileAccess.WRITE)
	var toJSON = ToJSON()
	var stringify = JSON.stringify(toJSON, "\t")
	save_file.store_line(stringify)
	pass


func ToJSON():
	var saveData = {
		"m_pickedUpBazooka" = m_pickedUpBazooka
	}

	return saveData

func FromJSON(_dict : Dictionary):
	m_pickedUpBazooka = _dict["m_pickedUpBazooka"]

static func CreateNewPlayerPersistData():
	var playerPersist = PlayerPersistData.new()
	playerPersist.name = NODENAME
	PersistDataManager.add_child(playerPersist)

	playerPersist.m_pickedUpBazooka = false
	playerPersist.Save()
	pass
