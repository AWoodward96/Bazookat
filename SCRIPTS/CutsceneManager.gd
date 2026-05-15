extends Node2D

@export var e_dialogueWindow : PackedScene

var m_window : DialogueWindow
var m_sequenceIndex : int = 0
var m_currentSequence : DialogueSequence
var m_currentContext : CutsceneContext

func _process(_delta):
	if m_currentSequence != null:
		if m_sequenceIndex < m_currentSequence.e_stack.size():
			if m_currentSequence.e_stack[m_sequenceIndex].Execute(_delta, m_currentContext):
				m_currentSequence.e_stack[m_sequenceIndex].Exit(m_currentContext)

				m_sequenceIndex += 1
				if m_sequenceIndex < m_currentSequence.e_stack.size():
					m_currentSequence.e_stack[m_sequenceIndex].Enter(m_currentContext)
				else:
					m_currentContext.CleanUp()
					m_currentSequence = null
					Level.Player.ExitCutscene()
	pass

func StartCutscene(_dialogue : DialogueSequence, _windowPoint : Node2D, _playerPoint : Node2D, _playerLookAt : Vector2):
	if _dialogue == null:
		return

	if _dialogue.e_stack.size() == 0:
		return

	m_sequenceIndex = 0
	m_currentContext = CutsceneContext.new()
	m_currentContext.WindowAnchor = _windowPoint

	if Level.Player != null:
		Level.Player.EnterCutscene()
		Level.Player.global_position = _playerPoint.global_position
		Level.Player.m_cutsceneLookAt = _playerLookAt

	if m_window != null:
		m_window.queue_free()

	m_currentSequence = _dialogue
	m_currentSequence.e_stack[0].Enter(m_currentContext)
	pass
