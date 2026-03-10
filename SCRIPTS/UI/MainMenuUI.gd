extends Control
class_name MainMenuUI

var m_playSelected = false
var m_quitting = false


func OnPlay():
	# double press protection
	if !m_playSelected && !m_quitting:
		m_playSelected = true

		UIManager.FadeOut(1)
		await UIManager.OnFadeComplete
		LevelManager.StartNewWorld(GameManager.e_gameData.e_defaultWorld)
		UIManager.FadeIn(1, 1)
		queue_free()

	pass

func OnSettings():

	pass


func OnQuit():
	if !m_quitting:
		m_quitting = true
		GameManager.SendQuitNotification()
	pass
