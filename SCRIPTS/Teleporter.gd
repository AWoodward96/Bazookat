@tool
extends Node2D
class_name Teleporter

const HELPER_ICON : String = "res://ART/Characters/Main/bazookat_tall.png"
const UP_ARROW_LOCATION : String = "res://ART/UI/up_arrow.png"


@export var e_oneWay : bool = false
@export var e_startArea : Area2D
@export var e_endArea : Area2D

@export_category("Editor Variables")
@export var e_startPosition : Sprite2D
@export var e_endPosition : Sprite2D
@export var e_startUpArrowVisual : Sprite2D
@export var e_endUpArrowVisual : Sprite2D
@export var e_arrowAlphaSpeed : float = 0.75
@export var e_arrowAmp : float = 0.05
@export var e_arrowFrequency : float = 4


var m_playerInStart : bool
var m_playerInEnd : bool
var m_transparencyTween : Tween
var m_pingPongDelta : float

func _ready() -> void:
	if Engine.is_editor_hint():
		if e_startArea == null:
			e_startArea = Area2D.new()
			e_startArea.name = "Start"
			add_child(e_startArea)
			e_startArea.owner = get_tree().edited_scene_root

			var shape = CollisionShape2D.new()
			shape.name = "StartShape"
			shape.position = Vector2(8,8)
			e_startArea.add_child(shape)
			shape.owner = get_tree().edited_scene_root
			var shapeShape = RectangleShape2D.new()
			shapeShape.size = Vector2(48, 48)
			shape.shape = shapeShape # I'm fucking hilarious shut up

		if e_endArea == null:
			e_endArea = Area2D.new()
			e_endArea.name = "End"
			add_child(e_endArea)
			e_endArea.owner = get_tree().edited_scene_root

			var shape = CollisionShape2D.new()
			shape.name = "EndShape"
			shape.position = Vector2(8,8)
			e_endArea.add_child(shape)
			shape.owner = get_tree().edited_scene_root
			var shapeShape = RectangleShape2D.new()
			shapeShape.size = Vector2(48, 48)
			shape.shape = shapeShape # I'm fucking hilarious shut up

		if e_startPosition == null:
			e_startPosition = EDITOR_CreateHelperSprite("StartDropOff", HELPER_ICON)
			e_startPosition.offset = Vector2(0, -9)

		if e_endPosition == null:
			e_endPosition = EDITOR_CreateHelperSprite("EndDropOff", HELPER_ICON)
			e_endPosition.offset = Vector2(0, -9)

		if e_startUpArrowVisual == null:
			e_startUpArrowVisual = EDITOR_CreateHelperSprite("StartArrow", UP_ARROW_LOCATION, e_startArea)

		if e_endUpArrowVisual == null:
			e_endUpArrowVisual = EDITOR_CreateHelperSprite("EndArrow", UP_ARROW_LOCATION, e_endArea)
#
	else:
		e_endPosition.visible = false
		e_startPosition.visible = false
		e_startUpArrowVisual.modulate = Color.TRANSPARENT
		e_endUpArrowVisual.modulate = Color.TRANSPARENT

		if !e_startArea.body_entered.is_connected(OnBodyEnter_Start):
			e_startArea.body_entered.connect(OnBodyEnter_Start)

		if !e_startArea.body_exited.is_connected(OnBodyExit_Start):
			e_startArea.body_exited.connect(OnBodyExit_Start)

		if !e_endArea.body_entered.is_connected(OnBodyEnter_End):
			e_endArea.body_entered.connect(OnBodyEnter_End)

		if !e_endArea.body_exited.is_connected(OnBodyExit_End):
			e_endArea.body_exited.connect(OnBodyExit_End)

func EDITOR_CreateHelperSprite(_name : String, _iconPath : String, _parent : Node2D = null):
	var local = Sprite2D.new()
	local.name = _name
	local.texture = load(_iconPath)
	local.position = Vector2(8,16)
	if _parent == null:
		add_child(local)
	else:
		_parent.add_child(local)
	local.owner = get_tree().edited_scene_root
	return local

func _process(_delta: float):
	if !Engine.is_editor_hint():
		m_pingPongDelta += _delta
		e_startUpArrowVisual.position += Vector2(0, sin(m_pingPongDelta * e_arrowFrequency) * e_arrowAmp)
		e_endUpArrowVisual.position += Vector2(0, sin(m_pingPongDelta * e_arrowFrequency) * e_arrowAmp)

		if InputManager.inputDown[0]:
			if m_playerInStart:
				InputManager.ReleaseDirectionalInput()
				Level.Current.TeleportPlayer(e_startPosition, e_endPosition)
				return

			if m_playerInEnd && !e_oneWay:
				InputManager.ReleaseDirectionalInput()
				Level.Current.TeleportPlayer(e_endPosition, e_startPosition)
				return


func OnBodyEnter_Start(_body : Node2D):
	m_playerInStart = true
	if m_transparencyTween != null:
		m_transparencyTween.stop()

	m_transparencyTween = create_tween()
	m_transparencyTween.tween_property(e_startUpArrowVisual, "modulate", Color.WHITE, e_arrowAlphaSpeed)


func OnBodyExit_Start(_body : Node2D):
	m_playerInStart = false

	if m_transparencyTween != null:
		m_transparencyTween.stop()

	m_transparencyTween = create_tween()
	m_transparencyTween.tween_property(e_startUpArrowVisual, "modulate", Color.TRANSPARENT, e_arrowAlphaSpeed)


func OnBodyEnter_End(_body : Node2D):
	if e_oneWay:
		return

	m_playerInEnd = true
	if m_transparencyTween != null:
		m_transparencyTween.stop()

	m_transparencyTween = create_tween()
	m_transparencyTween.tween_property(e_endUpArrowVisual, "modulate", Color.WHITE, e_arrowAlphaSpeed)


func OnBodyExit_End(_body : Node2D):
	if e_oneWay:
		return

	m_playerInEnd = false

	if m_transparencyTween != null:
		m_transparencyTween.stop()

	m_transparencyTween = create_tween()
	m_transparencyTween.tween_property(e_endUpArrowVisual, "modulate", Color.TRANSPARENT, e_arrowAlphaSpeed)
