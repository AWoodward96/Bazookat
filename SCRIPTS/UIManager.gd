extends Node2D

signal OnFadeComplete

@export var e_obscureMask : TextureRect

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
	m_fadeTween.tween_method(TweenObscure, 0.0, 1.0, _duration)
	m_fadeTween.tween_callback(func() : OnFadeComplete.emit())
	m_fadeTween.play()


func TweenObscure(_value : float):
	e_obscureMask.material.set_shader_parameter("cutoff", _value)
