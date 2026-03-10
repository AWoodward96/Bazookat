extends Node2D

@export var e_levelParent : Node2D

var m_currentWorldLevel : Level
var m_currentWorldLevelIndex : int = 0
var m_currentWorldTemplate : WorldTemplate

var m_mcGuffinsGot : int
var m_mcGuffinsTotal : int

func StartNewWorld(_worldTemplate : WorldTemplate):
	m_currentWorldTemplate = _worldTemplate
	m_currentWorldLevelIndex = 0
	m_mcGuffinsGot = 0
	m_mcGuffinsTotal = 0
	CreateNextLevelSection()


func CreateNextLevelSection():
	if m_currentWorldLevel != null:
		m_currentWorldLevel.CleanUp()
		m_currentWorldLevel.queue_free()

	m_currentWorldLevel = m_currentWorldTemplate.Levels[m_currentWorldLevelIndex].instantiate()
	e_levelParent.add_child(m_currentWorldLevel)
	m_mcGuffinsTotal += m_currentWorldLevel.e_numMcGuffins
	pass

func LevelSectionComplete():
	if m_currentWorldTemplate != null:
		if m_currentWorldLevelIndex + 1 < m_currentWorldTemplate.Levels.size():
			UIManager.FadeOut(1, 0)
			await UIManager.OnFadeComplete
			m_currentWorldLevelIndex += 1
			CreateNextLevelSection()
			UIManager.FadeIn(1, 0)
			pass
		else:
			# Show results, go back to title
			UIManager.FadeOut(1, 0)
			await UIManager.OnFadeComplete
			m_currentWorldLevel.CleanUp()
			m_currentWorldLevel.queue_free()
			GameManager.ReturnToMainMenu()

			pass

	else:
		if Level.Current != null:
			UIManager.FadeOut(1, 0)
			await UIManager.OnFadeComplete
			Level.Current.CleanUp()
			Level.Current.queue_free()
			GameManager.ReturnToMainMenu()

	pass
