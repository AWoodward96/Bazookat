extends Node2D

enum ControllerScheme { Keyboard, Controller }
static var CurrentInputScheme : ControllerScheme = ControllerScheme.Keyboard

@export var inputHeldThreshold = 0.5
@export var inputHeldMoveTick = 0.06
@export var faux_cursor : Sprite2D

@export var cursor_controller_speed : float = 16
@export var cursor_controller_lerp : float = 10
@export var cursor_controller_range_offset : float = 64

var inputDown : Array[bool] = [false, false, false, false] # up, right, down, left
var inputHeld : Array[bool] = [false, false, false, false]

var jumpInputDown : bool
var jumpInputHeld : bool

var aim_horizontal : float
var aim_vertical : float
var move_horizontal : float
var move_vertical : float

var sprintDown : bool
var sprintHeld : bool

var cancelDown : bool
var cancelHeld : bool

var pauseDown : bool
var pauseHeld : bool

var mousePosition : Vector2
var mouseWorldPosition : Vector2
var lerpedControllerMousePosition : Vector2



func _physics_process(_delta):
	UpdateInputArrays(_delta)
	UpdateControllerMouse(_delta)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		CurrentInputScheme = ControllerScheme.Keyboard

	# For some reason, a Mouse Move event passes the InputEventJoypadButton or InputEventJoypadMotion check
	# Because of that filter out all mouse input events
	elif event is InputEventJoypadButton or InputEventJoypadMotion && event is not InputEventMouse:
		if event is InputEventJoypadMotion:
			if abs(event.axis_value) < 0.1:
				return
		CurrentInputScheme = ControllerScheme.Controller


func UpdateInputArrays(_delta):
	inputDown = [false, false, false, false] # Up, Right, Down, Left
	inputHeld = [false, false, false, false] # Up, Right, Down, Left

	if Input.is_action_pressed("up") : inputHeld[0] = true
	if Input.is_action_pressed("right") : inputHeld[1] = true
	if Input.is_action_pressed("down") : inputHeld[2] = true
	if Input.is_action_pressed("left") : inputHeld[3] = true
	if Input.is_action_just_pressed("up"): inputDown[0] = true
	if Input.is_action_just_pressed("right"): inputDown[1] = true
	if Input.is_action_just_pressed("down"): inputDown[2] = true
	if Input.is_action_just_pressed("left"): inputDown[3] = true

	jumpInputHeld = Input.is_action_pressed("jump")
	jumpInputDown = Input.is_action_just_pressed("jump")

	sprintHeld = Input.is_action_pressed("sprint")
	sprintDown = Input.is_action_just_pressed("sprint")

	pauseHeld = Input.is_action_pressed("pause")
	pauseDown = Input.is_action_just_pressed("pause")

	aim_horizontal =  Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	aim_vertical = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	move_horizontal = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_vertical = Input.get_action_strength("down") - Input.get_action_strength("up")



func UpdateControllerMouse(_delta):
	var viewport = get_viewport()
	if CurrentInputScheme == ControllerScheme.Keyboard:
		mousePosition = viewport.get_mouse_position()
		var halfExtents = get_viewport_rect().size / 2
		var camera = viewport.get_camera_2d()
		if camera != null:
			mouseWorldPosition = camera.get_screen_center_position() + mousePosition - halfExtents
	elif CurrentInputScheme == ControllerScheme.Controller:
		var controllerAim = Vector2(aim_horizontal, aim_vertical)
		if Level.Current != null:
			Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CONFINED_HIDDEN
			faux_cursor.visible = true

			if Level.Player != null:
				if controllerAim.length() > 0.25:
					faux_cursor.position = Level.Player.position + (controllerAim * cursor_controller_range_offset)
					mouseWorldPosition = faux_cursor.position
				return
		else:
			Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CONFINED
			faux_cursor.visible = false


			viewport.warp_mouse(get_viewport().get_mouse_position() + controllerAim * cursor_controller_speed)
		pass

func ReleasePause():
	pauseDown = false
