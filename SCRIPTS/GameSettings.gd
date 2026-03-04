extends Resource
class_name GameSettings

@export var e_jumpHeight : int = 48
@export var e_timeToJumpApex : float = 0.34


var Gravity : float :
	get:
		return (2 * e_jumpHeight) / pow(e_timeToJumpApex, 2)

var JumpForce : float :
	get:
		return Gravity * e_timeToJumpApex
