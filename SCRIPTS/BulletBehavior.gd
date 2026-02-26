extends Node2D
class_name BulletBehavior

@export var e_speed : float = 10
@export var e_direction : Vector2
@export var e_raycaster : RayCast2D

var m_orign : Vector2

func _physics_process(_delta: float):
	var movementVector = e_direction * e_speed * _delta
	e_raycaster.target_position = movementVector
	e_raycaster.force_raycast_update()
	if e_raycaster.is_colliding():
		var point = e_raycaster.get_collision_point()
		var dst = (point - global_position) as Vector2

		# This ensures that the bullet doesn't sink into the ground if moving at high speeds
		if dst.length() < (e_speed * _delta):
			global_position = point
			return

	global_position += movementVector


func _on_area_2d_body_entered(body: Node2D):
	queue_free()
