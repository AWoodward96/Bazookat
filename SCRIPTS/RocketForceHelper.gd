extends Resource
class_name RocketForceHelper

@export var e_degrees : float
@export var e_debugColor : Color

@export_category("Force Data")
@export var e_direction : PlayerController.ERocketJumpDirections
@export var e_HasXForce : bool = false
@export var e_XDirection : float = 0
@export var e_YForceMultiplier : float = 1
@export var e_horizontalLockoutDuration : float = 0.5
@export var e_upwardCutLockoutDuration : float = 0.5
@export var e_perfectModifier : float = 1.25
@export var e_maxSpeedGain : float = 0
