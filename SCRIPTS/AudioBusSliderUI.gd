extends Node
class_name AudioBusSliderUI

enum EAudioBusType { Master, Music, SFX, UI}

@export var e_busType : EAudioBusType
@export var e_valueText : LineEdit
@export var e_slider : HSlider
@export var e_exampleAudio : FmodEventEmitter2D
@export var e_audioLockout : float = 0.25

var m_audioCDTimer : float = 0
var m_blockSliderChange : bool = false


func _process(delta: float) -> void:
	if m_audioCDTimer > 0:
		m_audioCDTimer -= delta

func OnSliderChanged(value: float) -> void:
	if m_blockSliderChange:
		m_blockSliderChange = false
		return

	if e_valueText != null:
		e_valueText.text = "%d" % value
		
	ChangeAudioStrength(value)
	TryPlayAudio()


func OnTextChanged(_newText : String) -> void:
	if e_slider != null:
		m_blockSliderChange = true
		e_slider.value = int(_newText)

	ChangeAudioStrength(int(_newText))
	TryPlayAudio()

func ChangeAudioStrength(_strength : int):
	var value = _strength / 100.0
	match e_busType:
		EAudioBusType.Master:
			AudioManager.SetMasterVolume(value)
		EAudioBusType.SFX:
			AudioManager.SetSFXVolume(value)
		EAudioBusType.Music:
			AudioManager.SetMusicVolume(value)
		EAudioBusType.UI:
			AudioManager.SetUIVolume(value)
	pass

func TryPlayAudio():
	if m_audioCDTimer > 0:
		return
	
	m_audioCDTimer = e_audioLockout
	if e_exampleAudio != null:
		e_exampleAudio.play_one_shot()
