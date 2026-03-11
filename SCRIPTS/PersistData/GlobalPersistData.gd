extends Node2D
class_name GlobalPersistData

static var NODENAME = "GlobalPersistData"

var m_mcGuffinsCollected : Dictionary = {}


func Save():
	var save_file = FileAccess.open(PersistDataManager.GLOBAL_FILE, FileAccess.WRITE)
	var toJSON = ToJSON()
	var stringify = JSON.stringify(toJSON, "\t")
	save_file.store_line(stringify)

func ToJSON():
	var saveData = {
		"m_mcGuffinsCollected" =  JSON.stringify(m_mcGuffinsCollected)
	}
	return saveData

func FromJSON(_dict : Dictionary):
	m_mcGuffinsCollected = JSON.parse_string(_dict["m_mcGuffinsCollected"])
	pass

func RegisterMcGuffinCollected(_mcGuffin : McGuffin):
	if _mcGuffin == null:
		return

	# At some point this is going to need to become more complicated. Showing which levels have found which mcguffins, etc
	# but for now this is all I care about
	print("Adding McGuffin UID: ", _mcGuffin.e_uid)
	m_mcGuffinsCollected[_mcGuffin.e_uid] = true
	Save()


static func CreateNewGlobalPersist():
	var globalPersist = GlobalPersistData.new()
	globalPersist.name = NODENAME
	PersistDataManager.add_child(globalPersist)

	globalPersist.Save()
	# Not much else to do here yet but we've got it now at least
