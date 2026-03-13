extends Node2D

signal OnFadeComplete

@export var e_mainCanvas : CanvasLayer
@export var e_obscureMask : TextureRect
@export var e_mainMenuUI : PackedScene
@export var e_resultsUI : PackedScene
@export var e_bazookaGetUI : PackedScene

var m_fadeTween : Tween

func FadeOut(_duration : float, _delay : float = 0):
	e_obscureMask.material.set_shader_parameter("obscure", true)
	Fade(_duration, _delay)
	pass

func FadeIn(_duration : float, _delay : float = 0):
	e_obscureMask.material.set_shader_parameter("obscure", false)
	Fade(_duration, _delay)

func Fade(_duration : float, _delay : float = 0):
	if m_fadeTween != null:
		m_fadeTween.stop()
		m_fadeTween = null


	e_obscureMask.material.set_shader_parameter("cutoff", 0)
	m_fadeTween = get_tree().create_tween()
	m_fadeTween.tween_interval(_delay)

	# You're not halucinating. Go to 1.25. Yes, the cutoff should be at 1. No that doesn't work.
	# A tiny bit will still be left over and it will drive you insane
	m_fadeTween.tween_method(TweenObscure, 0.0, 1.25, _duration)
	m_fadeTween.tween_callback(FadeComplete)
	m_fadeTween.play()

func FadeComplete():
	OnFadeComplete.emit()

func TweenObscure(_value : float):
	e_obscureMask.material.set_shader_parameter("cutoff", _value)

func OpenUI(_packedScene : PackedScene):
	if _packedScene == null:
		return

	var newUI = _packedScene.instantiate()
	e_mainCanvas.add_child(newUI)
	return newUI
