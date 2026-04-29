@tool
extends Line2D
class_name RocketJumpVisualiser

@export var e_segments : RocketArcWrapper
@export var e_numSegments : int = 180
@export var e_segmentSize : int = 360
@export var e_helperLabel : Label

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# rebuild
		ValidateAngles()
		SetupColors()
		clear_points()
		for i in range(0, e_numSegments):
			var segment = Vector2.RIGHT * e_segmentSize
			segment = segment.rotated(deg_to_rad(i))
			add_point(segment)
			add_point(Vector2.ZERO)

		pass

func ValidateAngles():
	var totalDegrees = 0
	for data in e_segments.e_data:
		totalDegrees += data.e_degrees

	if totalDegrees == 360:
		e_helperLabel.text = "Full 360 Achieved!"
	else:
		e_helperLabel.text = "Missing Degrees: " + str(360 - totalDegrees)
	pass

func SetupColors():
	if e_segments == null:
		return


	var emptyFloatArray : PackedFloat32Array
	#emptyFloatArray.append(0)
	gradient.offsets = emptyFloatArray
	#gradient.offsets.append(0)
	var angle_frontier = 0
	for data in e_segments.e_data:
		gradient.add_point((angle_frontier + 0.01) / 360.0 , data.e_debugColor)
		gradient.add_point((data.e_degrees + angle_frontier) / 360.0 , data.e_debugColor)
		angle_frontier += data.e_degrees

	pass
