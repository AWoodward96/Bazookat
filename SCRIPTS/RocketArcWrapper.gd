extends Resource
class_name RocketArcWrapper

@export var e_data : Array[RocketForceHelper]

func Evaluate(_angleInDegrees : float):
	var cumulative = 0
	for data in e_data:
		cumulative += data.e_degrees
		if cumulative > _angleInDegrees:
			return data

	return e_data[e_data.size() - 1]
