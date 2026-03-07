extends Node2D
class_name OneWayPlatform

@export var e_rigidCollider : StaticBody2D
@export var e_playerDetectorCollider : Area2D


func EnableRigid(_enabled : bool):
	if _enabled:
		e_rigidCollider.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		e_rigidCollider.process_mode = Node.PROCESS_MODE_DISABLED


func _on_player_detector_body_entered(_body: Node2D) -> void:
	EnableRigid(false)


func _on_player_detector_body_exited(_body: Node2D) -> void:
	EnableRigid(true)
	pass # Replace with function body.
