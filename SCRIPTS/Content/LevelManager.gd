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

	PersistDataManager.SaveAll()
	m_currentWorldLevel = m_currentWorldTemplate.Levels[m_currentWorldLevelIndex].instantiate()
	e_levelParent.add_child(m_currentWorldLevel)
	m_mcGuffinsTotal += m_currentWorldLevel.e_numMcGuffins
	pass

func LevelSectionComplete():
	if m_currentWorldTemplate != null:
		Level.Current.Player.OnLevelComplete()
		await get_tree().create_timer(0.25).timeout
		var ui = UIManager.OpenUI(UIManager.e_resultsUI) as ResultsUI
		ui.Show(Level.Current)
		await ui.ResultsSequenceComplete

		UIManager.FadeOut(1, 0)
		await UIManager.OnFadeComplete

		# has next level
		if m_currentWorldLevelIndex + 1 < m_currentWorldTemplate.Levels.size():
			m_currentWorldLevelIndex += 1
			CreateNextLevelSection()
			UIManager.FadeIn(1, 0)
		else:
			m_currentWorldLevel.CleanUp()
			m_currentWorldLevel.queue_free()
			GameManager.ReturnToMainMenu()

			pass

	else:
		if Level.Current != null:
			UIManager.FadeOut(1, 0)
			await UIManager.OnFadeComplete
			var level = Level.Current
			Level.Current.CleanUp()
			level.queue_free()
			GameManager.ReturnToMainMenu()

	pass
