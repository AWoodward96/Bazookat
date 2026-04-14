extends Control
class_name MainMenuUI

@export var e_harassSettings : Label
@export var e_harassSettingsOptions : Array[String]

var m_playSelected = false
var m_quitting = false
var m_jokeTween : Tween


func OnPlay():
	# double press protection
	if !m_playSelected && !m_quitting:
		m_playSelected = true
		AudioManager.ButtonClick()
		StartWorld(GameManager.e_gameData.e_defaultWorld)

	pass

func Challenge():
	# double press protection
	if !m_playSelected && !m_quitting:
		m_playSelected = true
		AudioManager.ButtonClick()
		StartWorld(GameManager.e_gameData.e_challengeWorld)

	pass

func StartWorld(_world : WorldTemplate):
	UIManager.FadeOut(1)
	await UIManager.OnFadeComplete

	# For now, Play will always put you in the first level.
	# We want to remove the rocket launcher from them so everyone has the same experience
	PersistDataManager.ClearSaveData()

	LevelManager.StartNewWorld(_world)
	UIManager.FadeIn(1, 1)
	queue_free()


func OnSettings():
	AudioManager.ButtonClick()
	UIManager.OpenUI(UIManager.e_settingsUI)


func OnQuit():
	if !m_quitting:
		AudioManager.ButtonClick()
		m_quitting = true
		GameManager.SendQuitNotification()
	pass
