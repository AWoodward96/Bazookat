@tool
extends Control
class_name DialogueWindow

const DEFAULT_FONT_FILE = "res://ART/Fonts/c64esque.ttf"

@export var e_textLabel : RichTextLabel
@export var e_container : PanelContainer
@export var e_dialoguePip : FmodEventEmitter2D
@export var e_dongle : DialogeDongleHelper

@export var e_tester : DialogueEvent
@export var e_debug : bool = false

var m_revealTween : Tween
var m_textComplete : bool = false


func _process(_delta : float):
	if Engine.is_editor_hint() && e_debug:
		ShowDialogue(e_tester, null)
		e_debug = false

func ShowDialogue(_dialogueEntry : DialogueEvent, _anchor : Node2D):
	if _dialogueEntry == null:
		e_textLabel.clear()
		e_textLabel.append_text("N/A")
		return

	e_textLabel.clear()

	var font = _dialogueEntry.e_font
	if font == null:
		font = load(DEFAULT_FONT_FILE) as FontFile
	e_textLabel.push_font(font, _dialogueEntry.e_fontSize)
	e_textLabel.push_color(Color.BLACK)
	e_textLabel.append_text(tr(_dialogueEntry.e_text))

	if _anchor != null:
		global_position = _anchor.global_position + _dialogueEntry.e_panelPositionOffset

	e_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	e_container.size = _dialogueEntry.e_panelStartingSize

	m_textComplete = false
	m_revealTween = create_tween()
	e_textLabel.visible_ratio = 0
	m_revealTween.tween_property(e_textLabel, "visible_ratio", 1, _dialogueEntry.e_revealSpeed)
	m_revealTween.tween_callback(OnTweenComplete)
	pass

func OnTweenComplete():
	m_textComplete = true
	pass

func ForceComplete():
	m_textComplete = true
	if m_revealTween != null:
		m_revealTween.stop()
	e_textLabel.visible_ratio = 1
