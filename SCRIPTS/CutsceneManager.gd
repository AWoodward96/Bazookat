extends Node2D

@export var e_dialogueWindow : PackedScene

var m_window : DialogueWindow
var m_sequenceIndex : int = 0
var m_currentSequence : DialogueSequence
var m_anchor : Node2D

func _process(_delta):
	if InputManager.jumpInputDown && m_currentSequence != null:
		InputManager.ReleaseJump()
		if m_window.m_textComplete:
			m_sequenceIndex += 1
			if m_sequenceIndex < m_currentSequence.e_stack.size():
				m_window.ShowDialogue(m_currentSequence.e_stack[m_sequenceIndex], m_anchor)
			else:
				m_window.queue_free()
				m_currentSequence = null
				Level.Player.ExitCutscene()
		else:
			m_window.ForceComplete()

	pass

func StartCutscene(_dialogue : DialogueSequence, _windowPoint : Node2D, _playerPoint : Node2D, _playerLookAt : Vector2):
	if _dialogue == null:
		return

	if _dialogue.e_stack.size() == 0:
		return

	m_sequenceIndex = 0
	if Level.Player != null:
		Level.Player.EnterCutscene()
		Level.Player.global_position = _playerPoint.global_position
		Level.Player.m_cutsceneLookAt = _playerLookAt

	if m_window != null:
		m_window.queue_free()

	m_currentSequence = _dialogue
	m_anchor = _windowPoint
	m_window = e_dialogueWindow.instantiate()
	add_child(m_window)
	m_window.position = _windowPoint.global_position
	m_window.e_dongle.AssignSubject(_windowPoint)
	m_window.ShowDialogue(m_currentSequence.e_stack[0], m_anchor)
	pass
