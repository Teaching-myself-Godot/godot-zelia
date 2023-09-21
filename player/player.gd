extends CharacterBody2D

enum Orientation   { LEFT, RIGHT }
# add movement state for casting
enum MovementState { IDLE, RUNNING, AIRBORNE, CASTING }

var movement_state : int
var orientation    : int

# the exact cast angle in radians
var cast_angle     : float

# Get the gravity from the project settings so you can sync with rigid body nodes.
# NOTE: I changed the default from 980 to 1300, Zelia jumps high yet falls fast.
var gravity    = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed      = 170.0
var jump_speed = -400.0

# Cast fireball signal declaration
signal cast_fire_magic(fireball, direction, location)

# Fireball class
var Fireball = preload("res://projectiles/fireball/Fireball.tscn")

# Vector of L-stick
func get_l_stick_axis_vec() -> Vector2:
	return Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X), 
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)

# Vector from player to mouse position
func get_mouse_vec_to_player() -> Vector2:
	return get_global_mouse_position() - position

# base the angle of casting on the position of the mouse relative to Zelia
func set_cast_angle():
	if Input.is_action_pressed("Left mouse button"):
		cast_angle = get_mouse_vec_to_player().normalized().angle()
	else:
		cast_angle = get_l_stick_axis_vec().normalized().angle()

# base orientation on the angle of casting
func set_orientation_by_cast_angle():
	if cast_angle > -(PI * 0.5) and cast_angle < PI * 0.5:
		orientation = Orientation.RIGHT
	else:
		orientation = Orientation.LEFT

# Set initial movement state
func set_movement_state():
	if Input.is_action_pressed("Fireball button"):
		movement_state = MovementState.CASTING
		set_cast_angle()
	elif is_on_floor():
		movement_state = MovementState.IDLE
	else:
		movement_state = MovementState.AIRBORNE

## Handlers for:
# Updating movement state, velocity and orientation based on the combo of
# her current movement state, pressed inputs and environmental factors

# She cannot run or move on x-axis in the air while casting
# but she _can_ turn around
func handle_casting():
	velocity.x = 0
	set_orientation_by_cast_angle()


# Handles landing, orientation and x-movement in the air
func handle_airborne():
	if is_on_floor():
		movement_state = MovementState.IDLE
	elif Input.is_action_pressed("Run right"):
		orientation = Orientation.RIGHT
		velocity.x = speed
	elif Input.is_action_pressed("Run left"):
		orientation = Orientation.LEFT
		velocity.x = -speed
	else:
		velocity.x = 0

# handle actions on the floor
func handle_running():
	if Input.is_action_pressed("Run right"):
		# so we run right when run right is pressed
		orientation = Orientation.RIGHT
		movement_state = MovementState.RUNNING
		velocity.x = speed
	elif Input.is_action_pressed("Run left"):
		# .. and left ...
		orientation = Orientation.LEFT
		movement_state = MovementState.RUNNING
		velocity.x = -speed
	else:
		# and stand idle if no x-movement button is pressed
		velocity.x = 0
		movement_state = MovementState.IDLE  

# Handle Jump, only to be invoked when on the floor and not in airborne state
func handle_jumping():
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		$JumpSound.play()
		movement_state = MovementState.AIRBORNE
		velocity.y = jump_speed
## /Handlers

## Functions to set the correct sprite
#

# Determine the casting sprite name based on the cast_angle
func get_casting_sprite(deg) -> String:
	var casting_left  = (deg > 120 and deg < 180) or (deg > -180 and deg < -120)
	var casting_right = deg > -60  and deg < 60
	var casting_up    = deg > -140 and deg < -20
	var casting_down  = deg > 30   and deg < 150

	if casting_up and (casting_right or casting_left):
		return "casting_diag_up"
	elif casting_down and (casting_right or casting_left):
		return "casting_down"
	elif casting_up:
		return "casting_up"
	elif casting_down:
		return "casting_down"
	else:
		return "casting_forward"

# Determine sprite based on movement state
func set_current_sprite():
	match (movement_state):
		MovementState.RUNNING:
			$AnimatedSprite2D.animation = "running"
		# This was added
		MovementState.AIRBORNE:
			$AnimatedSprite2D.animation = "jumping"
		MovementState.CASTING:
			# when casting invoge get_casting_sprite
			$AnimatedSprite2D.animation = get_casting_sprite(rad_to_deg(cast_angle))
		_: # MovementState.IDLE
			$AnimatedSprite2D.animation = "idle"

# determine sprite based on orientation
func flip_current_sprite():
	if orientation == Orientation.LEFT:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

## /Sprite funcs

func _ready():
	movement_state = MovementState.IDLE
	orientation    = Orientation.RIGHT
	$AnimatedSprite2D.play()

func _physics_process(delta):
	# Apply the gravity.
	velocity.y += gravity * delta

	# set initial movement state
	set_movement_state()

	# Update movement state, velocity and orientation based on the combo of
	# her current movement state and environmental factors
	if movement_state == MovementState.CASTING:
		handle_casting()
	elif movement_state == MovementState.AIRBORNE:
		handle_airborne()
	else:
		handle_running()
		handle_jumping()

	# Set current sprite and flip to correct orientation
	set_current_sprite()
	flip_current_sprite()

	# Apply 2d physics engine's movement 
	move_and_slide()



func _on_fireball_interval_timer_timeout():
	if movement_state == MovementState.CASTING:
		# elegant, yet no fit:
		var origin = position + Vector2(10, 0).rotated(cast_angle) + Vector2(0, 2)
		cast_fire_magic.emit(Fireball, cast_angle, origin)
