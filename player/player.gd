extends CharacterBody2D

enum Orientation   { LEFT, RIGHT }
enum MovementState { IDLE, RUNNING, AIRBORNE }

# I removed the exports for now, no debugging needed at the moment
var movement_state : int
var orientation    : int

# Get the gravity from the project settings so you can sync with rigid body nodes.
# NOTE: I changed the default from 980 to 1300, Zelia jumps high yet falls fast.
var gravity    = ProjectSettings.get_setting("physics/2d/default_gravity")
# The most realistic speed for Zelia's feet
var speed      = 120.0
# Funnily the original game had jump_speed set to -4.0 and gravity to 13.0
var jump_speed = -400.0

# No changes here
func _ready():
	movement_state = MovementState.IDLE
	orientation    = Orientation.RIGHT
	$AnimatedSprite2D.play()

# Changed _process to _physics_process
func _physics_process(delta):
	# Apply the gravity.
	velocity.y += gravity * delta

	if Input.is_action_just_pressed("Mouse click"):
		var vec = get_global_mouse_position() - position
		print(rad_to_deg(vec.normalized().angle()))
	# Update the MovementState based on the collisions observed
	if movement_state == MovementState.AIRBORNE:
		# If she's airborne right now
		if is_on_floor():
			# .. and hits the floor, she's idle
			movement_state = MovementState.IDLE
		elif Input.is_action_pressed("Run right"):
			# Else you can still move her right
			orientation = Orientation.RIGHT
			velocity.x = speed
		elif Input.is_action_pressed("Run left"):
			# ... and left
			orientation = Orientation.LEFT
			velocity.x = -speed
		else:
			velocity.x = 0
	else:
		# Else we are not airborne right now
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

	# Handle Jump, only when on the floor
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		$JumpSound.play()
		movement_state = MovementState.AIRBORNE
		velocity.y = jump_speed
	
	# This code has not changed
	match (movement_state):
		MovementState.RUNNING:
			$AnimatedSprite2D.animation = "running"
		# This was added
		MovementState.AIRBORNE:
			$AnimatedSprite2D.animation = "jumping"
		_: # MovementState.IDLE
			$AnimatedSprite2D.animation = "idle"

	# Neither had this
	if orientation == Orientation.LEFT:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

	# Yet this is new
	move_and_slide()

