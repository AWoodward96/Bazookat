extends Node2D

@export var e_visual : Node2D
@export var e_particleParent : Node2D

var m_pickedUp : bool = false

func Pickup(_body : Node2D):
	if Level.Player != null && !m_pickedUp:
		# There should probably be an animation for this but we're good right now
		m_pickedUp = true
		e_particleParent.visible = false
		e_visual.visible = false
		Level.Player.SetBazookaState(true)
		PersistDataManager.PlayerPersist.m_pickedUpBazooka = true
