extends CutsceneEventBase
class_name DialogueEvent

@export var e_text : String
@export var e_font : FontFile
@export var e_fontSize : int = 16
@export var e_revealSpeed : float = 1
@export var e_panelStartingSize = Vector2(128, 0)
@export var e_panelPositionOffset : Vector2
@export var e_immediateCleanup : bool


func Enter(_context : CutsceneContext):
	if _context.CurrentDialogWindow == null:
		var window = CutsceneManager.e_dialogueWindow.instantiate()
		_context.CurrentDialogWindow = window
		CutsceneManager.add_child(_context.CurrentDialogWindow)

	_context.CurrentDialogWindow.position = _context.WindowAnchor.global_position
	_context.CurrentDialogWindow.e_dongle.AssignSubject(_context.WindowAnchor)
	_context.CurrentDialogWindow.ShowDialogue(self, _context.WindowAnchor)
	return true

func Execute(_delta : float, _context : CutsceneContext):
	if _context == null || _context.CurrentDialogWindow == null:
		return true

	if InputManager.jumpInputDown:
		InputManager.ReleaseJump()
		if _context.CurrentDialogWindow.m_textComplete:
			return true
		else:
			_context.CurrentDialogWindow.ForceComplete()

	pass

func Exit(_context : CutsceneContext):
	if e_immediateCleanup:
		_context.CurrentDialogWindow.queue_free()
		_context.CurrentDialogWindow = null
