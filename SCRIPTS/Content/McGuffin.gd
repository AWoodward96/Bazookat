@tool
extends Node2D
class_name McGuffin

# So I can save and load the state of this object later
@export var e_uid : float = 0
@export var e_visual : Node2D
@export var e_collectionVFX : CPUParticles2D

var m_collected

func CheckCollected():
	if PersistDataManager.GlobalPersist.GetMcGuffinColected(Level.Current, self):
		m_collected = true
		e_visual.visible = false

func _process(_delta):
	if Engine.is_editor_hint():
		if e_uid == 0:
			# I don't really know if I should be using this like this, butttt
			e_uid = Time.get_unix_time_from_system()
	pass

func _on_collection_area_body_entered(_body: Node2D):
	if !m_collected:
		Collect()

func Collect():
	m_collected = true
	e_visual.visible = false
	e_collectionVFX.emitting = true
	PersistDataManager.GlobalPersist.RegisterMcGuffinCollected(Level.Current, self)
