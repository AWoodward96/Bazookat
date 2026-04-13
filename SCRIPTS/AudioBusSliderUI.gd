extends Node
class_name AudioBusSliderUI

enum EAudioBusType { Master, Music, SFX, UI}

@export var e_busType : EAudioBusType
@export var e_valueText : LineEdit
@export var e_slider : HSlider
@export var e_exampleAudio : FmodEventEmitter2D

var m_blockSliderChange : bool = false


func OnSliderChanged(value: float) -> void:
	if m_blockSliderChange:
		m_blockSliderChange = false
		return

	if e_valueText != null:
		e_valueText.text = "%d" % value
	ChangeAudioStrength(value)
	if e_exampleAudio != null:
		e_exampleAudio.play_one_shot()


func OnTextChanged(_newText : String) -> void:
	if e_slider != null:
		m_blockSliderChange = true
		e_slider.value = int(_newText)

	ChangeAudioStrength(int(_newText))
	if e_exampleAudio != null:
		e_exampleAudio.play_one_shot()

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
