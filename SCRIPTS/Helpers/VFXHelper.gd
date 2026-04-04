extends Node2D
class_name VFXHelper

@export var AutoEmit : bool = true
@export var Particles : Array[CPUParticles2D]
@export var GPUParticles : Array[GPUParticles2D]
   

func _ready():
	for p in Particles:
		p.emitting = true

	for p in GPUParticles:
		p.emitting = true
