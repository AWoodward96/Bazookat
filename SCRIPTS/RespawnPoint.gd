@tool
extends Area2D
class_name RespawnPoint

const RespawnHelperIconLocation : String = "res://ART/Characters/Main/bazookat_idle.png"

@export var e_shape : CollisionShape2D
@export var e_respawnPoint : Sprite2D

func _ready() -> void:
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

		if e_respawnPoint == null:
			e_respawnPoint = Sprite2D.new()
			e_respawnPoint.name = "Point"
			e_respawnPoint.texture = load(RespawnHelperIconLocation)
			e_respawnPoint.position = Vector2(8,16)
			add_child(e_respawnPoint)
			e_respawnPoint.owner = get_tree().edited_scene_root

	else:
		if e_respawnPoint != null:
			e_respawnPoint.visible = false
		if !body_entered.is_connected(OnBodyEnter):
			body_entered.connect(OnBodyEnter)

func OnBodyEnter(_body : Node2D):
	if Room.Current != null:
		Room.Current.RegisterRespawnPoint(self)
