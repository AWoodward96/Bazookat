extends Resource
class_name GameSettings

@export var e_jumpHeight : int = 48
@export var e_timeToJumpApex : float = 0.34
@export var e_genericDeathParticle : PackedScene
@export var e_defaultWorld : WorldTemplate
@export var e_challengeWorld : WorldTemplate
@export var e_internalTestingWorld : WorldTemplate

@export_category("Screen Shakes")
@export var e_rocketJumpScreenShake : CameraShakeData
@export var e_rocketExplosionScreenShake : CameraShakeData

var Gravity : float :
	get:
		return (2 * e_jumpHeight) / pow(e_timeToJumpApex, 2)

var JumpForce : float :
	get:
		return Gravity * e_timeToJumpApex
