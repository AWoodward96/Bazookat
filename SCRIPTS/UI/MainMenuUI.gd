extends Control
class_name MainMenuUI

@export var e_harassSettings : Label
@export var e_harassSettingsOptions : Array[String]
@export var e_buttonSFX : FmodEventEmitter2D

var m_playSelected = false
var m_quitting = false
var m_jokeTween : Tween


func OnPlay():
	# double press protection
	if !m_playSelected && !m_quitting:
		m_playSelected = true
		e_buttonSFX.play_one_shot()
		StartWorld(GameManager.e_gameData.e_defaultWorld)

	pass

func Challenge():
	# double press protection
	if !m_playSelected && !m_quitting:
		m_playSelected = true
		e_buttonSFX.play_one_shot()
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
	#if m_jokeTween != null:
		#m_jokeTween.stop()
#
	#m_jokeTween = get_tree().create_tween()
	#e_harassSettings.modulate = Color.WHITE
	#var rng = randi() % e_harassSettingsOptions.size()
	## ensure different
	#if e_harassSettingsOptions[rng] == e_harassSettings.text:
		#rng += 1
		#rng = rng % e_harassSettingsOptions.size()
#
	#e_harassSettings.text = e_harassSettingsOptions[rng]
#
	#m_jokeTween.tween_interval(2)
	#m_jokeTween.tween_property(e_harassSettings, "modulate", Color(1,1,1,0), 2)
	#pass

	e_buttonSFX.play_one_shot()
	UIManager.OpenUI(UIManager.e_settingsUI)


func OnQuit():
	if !m_quitting:
		e_buttonSFX.play_one_shot()
		m_quitting = true
		GameManager.SendQuitNotification()
	pass
