extends Control

func _process(_delta: float):
	if Input.is_action_just_pressed("csr"):
		visible = !visible
