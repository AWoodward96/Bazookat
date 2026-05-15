@tool
extends Area2D
class_name DialogueTrigger

const UP_ARROW_LOCATION : String = "res://ART/UI/up_arrow.png"
const DEBUG_WINDOW_LOCATION : String = "res://RESOURCES/Prefabs/UI/text_box_ui.tscn"
const CHARACTER_POINT_ICON_HELPER : String = "res://ART/Characters/Main/bazookat_tall.png"


@export var e_dialogueSequence : DialogueSequence
@export var e_showDebug : bool
@export var e_debugWindow : DialogueWindow
@export var e_debugStep : int = 0 :
	set(_val):
		e_debugStep = _val
		EDITOR_ForceUpdateDebugWindow()

@export_category("Visual Helpers")
@export var e_shape : CollisionShape2D
@export var e_upArrowVisual : Sprite2D
@export var e_characterPoint : Sprite2D
@export var e_arrowAlphaSpeed : float = 0.75
@export var e_arrowAmp : float = 0.05
@export var e_arrowFrequency : float = 4

@export var e_editorParent : Node2D

var m_playerIn : bool
var m_transparencyTween : Tween
var m_pingPongDelta : float

func _ready():
	if Engine.is_editor_hint():
		if e_shape == null:
			e_shape = CollisionShape2D.new()
			e_shape.name = "Shape"
			e_shape.position = Vector2(8, 8)
			add_child(e_shape)
			e_shape.owner = get_tree().edited_scene_root
			var newShape = RectangleShape2D.new()
			newShape.size = Vector2(48, 48)
			e_shape.shape = newShape

		if e_upArrowVisual == null:
			e_upArrowVisual = Sprite2D.new()
			e_upArrowVisual.z_index = 5
			e_upArrowVisual.name = "Arrow"
			e_upArrowVisual.texture = load(UP_ARROW_LOCATION)
			e_upArrowVisual.position = Vector2(8,16)
			add_child(e_upArrowVisual)
			e_upArrowVisual.owner = get_tree().edited_scene_root

		if e_characterPoint == null:
			e_characterPoint = Sprite2D.new()
			e_characterPoint.name = "Point"
			e_characterPoint.texture = load(CHARACTER_POINT_ICON_HELPER)
			e_characterPoint.position = Vector2(8,16)
			e_characterPoint.offset = Vector2(0, -9)
			add_child(e_characterPoint)
			e_characterPoint.owner = get_tree().edited_scene_root

		if e_editorParent == null:
			e_editorParent = Node2D.new()
			e_editorParent.name = "EDITOR"
			add_child(e_editorParent)
			e_editorParent.owner = get_tree().edited_scene_root
	else:
		e_editorParent.visible = false
		e_characterPoint.visible = false
		e_upArrowVisual.modulate = Color.TRANSPARENT
		m_pingPongDelta = 0

		if !body_entered.is_connected(OnBodyEnter):
			body_entered.connect(OnBodyEnter)

		if !body_exited.is_connected(OnBodyExit):
			body_exited.connect(OnBodyExit)

func _process(_delta):
	if !Engine.is_editor_hint():
		m_pingPongDelta += _delta
		e_upArrowVisual.position += Vector2(0, sin(m_pingPongDelta * e_arrowFrequency) * e_arrowAmp)

		if InputManager.inputDown[0] && m_playerIn:
			InputManager.ReleaseDirectionalInput()
			CutsceneManager.StartCutscene(e_dialogueSequence, self, e_characterPoint, position)


	else:
		if e_debugWindow == null && e_showDebug:
			EDITOR_CreateDebugWindow()
			EDITOR_ForceUpdateDebugWindow()

		if e_debugWindow != null && !e_showDebug:
			e_debugWindow.free()
			e_debugWindow = null

func EDITOR_CreateDebugWindow():
	e_debugWindow = load(DEBUG_WINDOW_LOCATION).instantiate()
	e_editorParent.add_child(e_debugWindow)
	e_debugWindow.owner = get_tree().edited_scene_root
	e_debugWindow.e_dongle.AssignSubject(self)
	pass

func EDITOR_ForceUpdateDebugWindow():
	if e_debugWindow != null:
		if e_dialogueSequence == null:
			return

		var step = clamp(e_debugStep, 0, e_dialogueSequence.e_stack.size() - 1)
		e_debugWindow.ShowDialogue(e_dialogueSequence.e_stack[step], self)
	pass

func OnBodyEnter(_body : Node2D):
	m_playerIn = true
	if m_transparencyTween != null:
		m_transparencyTween.stop()

	m_transparencyTween = create_tween()
	m_transparencyTween.tween_property(e_upArrowVisual, "modulate", Color.WHITE, e_arrowAlphaSpeed)


func OnBodyExit(_body : Node2D):
	m_playerIn = false

	if m_transparencyTween != null:
		m_transparencyTween.stop()

	m_transparencyTween = create_tween()
	m_transparencyTween.tween_property(e_upArrowVisual, "modulate", Color.TRANSPARENT, e_arrowAlphaSpeed)
