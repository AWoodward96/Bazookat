extends Camera2D
## The one that follows the player and renders everything
class_name MainCamera

@export var e_target : Node2D
@export var e_lerpSpeed : float = 10

func _physics_process(_delta: float):
	global_position = lerp(global_position, e_target.global_position, e_lerpSpeed * _delta)
	pass
