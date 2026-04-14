extends Control
class_name PauseUI

static var IsOpen : bool = false

@export var e_buttonSFX : FmodEventEmitter2D
var m_releasedPause : bool

func _ready() -> void:
	IsOpen = true
	m_releasedPause = false
	get_tree().paused = true

func _process(_delta):
	if Input.is_action_just_pressed("pause") && m_releasedPause:
		CloseUI()

	if !Input.is_action_pressed("pause") && !m_releasedPause:
		m_releasedPause = true

func Close():
	IsOpen = false
	get_tree().paused = false
	queue_free()

func CloseUI():
	AudioManager.ButtonClick()
	Close()
	pass

func QuitGame():
	var confirmedLambda = func():
		Close()
		GameManager.SendQuitNotification()

	var confirm = UIManager.OpenUI(UIManager.e_genericConfirmationUI)
	confirm.Initialize("ui_confirm_quitgame", confirmedLambda, Callable())

func OnSettings():
	AudioManager.ButtonClick()
	UIManager.OpenUI(UIManager.e_settingsUI)

func OnReturnToTitle() -> void:
	AudioManager.ButtonClick()

	var confirmedLambda = func():
		Close()
		if Level.Current != null:
			LevelManager.ForceReturnToTitle()
		else:
			GameManager.ReturnToMainMenu()

	var confirm = UIManager.OpenUI(UIManager.e_genericConfirmationUI)
	confirm.Initialize("ui_confirm_returntotitle", confirmedLambda, Callable())
