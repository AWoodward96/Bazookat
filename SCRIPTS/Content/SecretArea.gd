@tool
extends TileMapLayer
class_name SecretArea

@export var e_area : Area2D
@export var e_shape : CollisionShape2D

var m_obscure : bool = true
var m_tween : Tween

func _ready():
	if Engine.is_editor_hint():
		collision_enabled = false
		z_index = 1

		if e_area == null:
			e_area = Area2D.new()
			e_area.name = "Area"
			add_child(e_area)
			e_area.owner = get_tree().edited_scene_root
			e_area.set_collision_layer_value(1 , false)
			e_area.set_collision_mask_value(1, true)


		if e_shape == null:
			e_shape = CollisionShape2D.new()
			e_shape.name = "Shape"
			e_shape.position = Vector2(8, 8)
			e_area.add_child(e_shape)
			e_shape.owner = get_tree().edited_scene_root
			var newShape = RectangleShape2D.new()
			newShape.size = Vector2(48, 48)
			e_shape.shape = newShape

	if e_area != null:
		e_area.body_entered.connect(OnBodyEntered)
		e_area.body_exited.connect(OnBodyExited)

func OnBodyEntered(_obj : Node2D):
	m_obscure = false
	if m_tween != null:
		m_tween.stop()

	m_tween = get_tree().create_tween()
	m_tween.tween_property(self, "modulate", Color(1,1,1,0), 1)
	pass

func OnBodyExited(_obj : Node2D):
	m_obscure = true
	if m_tween != null:
		m_tween.stop()

	m_tween = get_tree().create_tween()
	m_tween.tween_interval(1)
	m_tween.tween_property(self, "modulate", Color(1,1,1,1), 1)
	pass
