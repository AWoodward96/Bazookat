extends Control
class_name ResultsUI

signal ResultsSequenceComplete

@export var e_levelComplete : Label
@export var e_mcGuffinsParent : Control
@export var e_mcGuffins : Label
@export var e_pressAnything : Label

var m_canContinue : bool

func Show(_level : Level):
	e_levelComplete.visible = false
	e_mcGuffinsParent.visible = false
	e_pressAnything.visible = false
	m_canContinue = false
	var persist = PersistDataManager.GlobalPersist.GetLevelPersistData(_level) as LevelPersistData

	await get_tree().create_timer(1).timeout
	e_levelComplete.visible = true
	await get_tree().create_timer(1).timeout

	e_mcGuffins.text = tr("ui_mcguffins_found_title").format({"NUM" = persist.m_mcGuffinCount, "NUM2" = _level.e_numMcGuffins})
	e_mcGuffinsParent.visible = true

	await get_tree().create_timer(1.5).timeout

	e_pressAnything.visible = true
	m_canContinue = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") && m_canContinue:
		m_canContinue = false
		ResultsSequenceComplete.emit()
		queue_free()
