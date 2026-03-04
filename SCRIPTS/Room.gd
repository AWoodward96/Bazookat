@tool
extends Node2D
class_name Room

static var Current : Room

@export var e_roomSize : Vector2i = Vector2i(40, 30) :
	set(_value):
		if _value.x < 40:
			_value.x = 40
		if _value.y < 30:
			_value.y = 30
		e_roomSize = _value

@export var e_respawnPoints : Array[RespawnPoint]
@export var e_defaultRespawnPoint : RespawnPoint

@export_category("Editor")
@export var EditorColor : Color = Color.WHITE
@export var m_editorParent : Node2D
@export var m_editorLine : Line2D


var m_currentRespawnPoint : RespawnPoint


func Overlaps(_position : Vector2):
	return _position.x > global_position.x && _position.x < global_position.x + (e_roomSize.x * GameManager.TILESIZE) && _position.y > global_position.y && _position.y < global_position.y + (e_roomSize.y * GameManager.TILESIZE)

func GetLocalizedExtents():
	var rect : Rect2
	rect.position = global_position
	rect.size = Vector2(e_roomSize * GameManager.TILESIZE)
	return rect

func _ready() -> void:
	if !Engine.is_editor_hint():
		if m_editorParent != null:
			m_editorParent.visible = false

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		EDIT_UpdateEditor()
	else:
		if Level.Current != null && Level.Player != null:
			if Overlaps(Level.Player.global_position) && Current != self:
				Level.Current.EnterRoom(self)


func EDIT_UpdateEditor():
	EDIT_CreateDebugParent()
	EDIT_UpdateLineRenderer()

	if e_defaultRespawnPoint == null:
		e_defaultRespawnPoint = RespawnPoint.new()
		e_defaultRespawnPoint.name = "DefaultRespawnPoint"
		add_child(e_defaultRespawnPoint)
		e_defaultRespawnPoint.owner = get_tree().edited_scene_root

	e_respawnPoints.clear()
	for c in get_children():
		if c is RespawnPoint:
			e_respawnPoints.append(c)

	pass

func EDIT_CreateDebugParent():
	if m_editorParent == null:
		m_editorParent = Node2D.new()
		m_editorParent.name = "EDITOR"
		add_child(m_editorParent)
		m_editorParent.owner = get_tree().edited_scene_root

	if m_editorLine == null:
		m_editorLine = Line2D.new()
		m_editorLine.name = "ROOMEXTENTS"
		m_editorParent.add_child(m_editorLine)
		m_editorLine.owner = get_tree().edited_scene_root

func EDIT_UpdateLineRenderer():
	if m_editorLine != null:
		m_editorLine.clear_points()

		m_editorLine.add_point(Vector2i.ZERO)
		m_editorLine.add_point(Vector2i(e_roomSize.x * GameManager.TILESIZE, 0))
		m_editorLine.add_point(Vector2i(e_roomSize.x * GameManager.TILESIZE, e_roomSize.y * GameManager.TILESIZE))
		m_editorLine.add_point(Vector2i(0, e_roomSize.y * GameManager.TILESIZE))
		m_editorLine.add_point(Vector2i.ZERO)
		m_editorLine.default_color = EditorColor
		pass
	pass


func RegisterRespawnPoint(_respawnPoint : RespawnPoint):
	m_currentRespawnPoint = _respawnPoint
