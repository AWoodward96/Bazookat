@tool
extends Node2D
class_name WaterHelper

@export var e_waterAreaSize : Vector2 = Vector2(256, 256)
@export var e_surfaceRenderer : Line2D
@export var e_renderingPolygon : Polygon2D
@export var e_segments : float = 32
@export var e_amp : float = 1.25
@export var e_wavelength : float = 3

@export var e_surfaceLine : Array[Vector2]

@export var e_simulateDisruption : bool
@export var e_disruptionPoint = Vector2(100, 0)
@export var e_disruptFalloff : float = 30
@export var e_disruptStrength : float = 5
@export var e_disruptWavelength : float = 5

var m_disruptPoint : Vector2 = Vector2(0, 0)
var m_currentDisruptStrength : float
var m_timer : float
var m_disruptTimer : float

func _physics_process(_delta: float) -> void:
	if e_simulateDisruption:
		e_simulateDisruption = false
		Disrupt(e_disruptionPoint)

	m_currentDisruptStrength = lerp(m_currentDisruptStrength, 0.0, _delta)
	ConstructSurfaceLine(_delta)
	e_surfaceRenderer.points = e_surfaceLine
	ConstructPolygon()
	pass

func ConstructSurfaceLine(_delta : float):
	m_timer += _delta
	m_disruptTimer += _delta
	e_surfaceLine.clear()
	var segmentLength = e_waterAreaSize.x / float(e_segments)
	for i in range(0, e_segments):
		var point = Vector2(i * segmentLength, 0)

		var disruptionStrength = GetDisruptedVector(point)
		point += Vector2(0, sin((m_timer * e_wavelength) + i) * e_amp)
		point += Vector2(0, cos((m_disruptTimer * e_disruptWavelength) + i) * disruptionStrength)
		e_surfaceLine.append(point)
		pass

	# then add one more to make the full size
	e_surfaceLine.append(Vector2(e_waterAreaSize.x, 0))
	pass

func GetDisruptedVector(_point : Vector2):
	var magDisruptionSQD = e_disruptFalloff * e_disruptFalloff
	var mag = (_point - m_disruptPoint).length_squared()
	var dif = 1 - clamp((float(mag) / float(magDisruptionSQD)), 0, 1)
	return m_currentDisruptStrength * dif

func ConstructPolygon():
	var polygonArray : Array[Vector2]
	polygonArray.append_array(e_surfaceLine)
	polygonArray.append(e_waterAreaSize)
	polygonArray.append(Vector2(0, e_waterAreaSize.y))
	e_renderingPolygon.polygon = polygonArray
	pass

func Disrupt(_point : Vector2):
	m_disruptTimer = 0
	m_disruptPoint = _point
	m_currentDisruptStrength = e_disruptStrength
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	var point = body.position - position
	if point.y < 5 && point.y > -5:
		Disrupt(point)
