extends Label


@export var player : PlayerController


func _process(_delta: float):
	if player != null:
		text = str(PlayerController.EExplosionType.find_key(player.e_explosionType))
