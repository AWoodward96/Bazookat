extends Label

@export var player : CharacterBody2D

func _process(_delta: float):
	if player != null:
		text = str(player.velocity)
