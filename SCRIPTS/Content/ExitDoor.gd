extends Node2D
class_name ExitDoor

var m_canInteract : bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		if m_canInteract:
			LevelManager.LevelSectionComplete()

func _on_area_2d_body_entered(_body: Node2D) -> void:
	m_canInteract = true
	pass

func _on_area_2d_body_exited(_body: Node2D) -> void:
	m_canInteract = false
	pass
