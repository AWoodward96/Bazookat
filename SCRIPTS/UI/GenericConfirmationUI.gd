extends Control
class_name GenericConfirmationUI

signal SelectionComplete

@export var e_confirmationTitle : Label

var m_yesAction : Callable
var m_noAction : Callable

func Initialize(_confirmationString : String, _yesAction : Callable, _noAction : Callable):
	e_confirmationTitle.text = tr(_confirmationString)
	m_yesAction = _yesAction
	m_noAction = _noAction

func OnYes():
	AudioManager.ButtonClick()
	if m_yesAction.is_valid():
		m_yesAction.call()
	Close()
	pass

func OnNo():
	AudioManager.ButtonClick()
	if m_noAction.is_valid():
		m_noAction.call()
	Close()
	pass

func Close():
	SelectionComplete.emit()
	queue_free()
