@tool
extends Node2D
class_name Room

static var Current : Room

@export var RoomSize : Vector2i = Vector2i(40, 30) :
	set(_value):
		if _value.x < 40:
			_value.x = 40
		if _value.y < 30:
			_value.y = 30
		RoomSize = _value

@export_category("Editor")
@export var EditorColor : Color = Color.WHITE
@export var m_editorParent : Node2D
@export var m_editorLine : Line2D


func Overlaps(_position : Vector2):
	return _position.x > global_position.x && _position.x < global_position.x + (RoomSize.x * GameManager.TILESIZE) && _position.y > global_position.y && _position.y < global_position.y + (RoomSize.y * GameManager.TILESIZE)

func GetLocalizedExtents():
	var rect : Rect2
	rect.position = global_position
	rect.size = Vector2(RoomSize * GameManager.TILESIZE)
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
		m_editorLine.add_point(Vector2i(RoomSize.x * GameManager.TILESIZE, 0))
		m_editorLine.add_point(Vector2i(RoomSize.x * GameManager.TILESIZE, RoomSize.y * GameManager.TILESIZE))
		m_editorLine.add_point(Vector2i(0, RoomSize.y * GameManager.TILESIZE))
		m_editorLine.add_point(Vector2i.ZERO)
		m_editorLine.default_color = EditorColor
		pass
	pass
