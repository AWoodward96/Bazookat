extends Control
class_name SettingsUI


func CloseUI():
	AudioManager.ButtonClick()
	queue_free()
	pass
