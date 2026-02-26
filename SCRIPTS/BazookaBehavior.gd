extends Node2D
class_name BazookaBehavior

@export var e_owner : Node2D
@export var e_camera : MainCamera
@export var e_bulletPrefab : PackedScene
var aimedDirection : Vector2

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("fire"):
		Fire(e_owner.global_position, e_camera.m_mouseWorldPosition - e_owner.global_position)
	pass


func Fire(_origin : Vector2, _direction : Vector2):
	var directionNormalized = _direction.normalized()
	var bulletInstance = e_bulletPrefab.instantiate() as BulletBehavior
	bulletInstance.e_direction = directionNormalized
	bulletInstance.global_position = _origin
	get_tree().root.add_child(bulletInstance)
