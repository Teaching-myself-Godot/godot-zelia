extends Area2D

enum Orientation   { LEFT, RIGHT }
enum MovementState { IDLE, RUNNING, AIRBORNE }

# We will want to debug these states, let's export them as well
@export var movement_state : int
@export var orientation   : int


func _ready():
	movement_state = MovementState.IDLE
	orientation    = Orientation.RIGHT
	$AnimatedSprite2D.play()

func _process(delta):
	# If user wants to jump, start the MockAirTimer and change the movement state to airborne
	if Input.is_action_just_pressed("Jump") and movement_state != MovementState.AIRBORNE:
		$JumpSound.play() # the new line
		$MockAirTimer.start()
		movement_state = MovementState.AIRBORNE
		

	if Input.is_action_pressed("Run right"):
		orientation = Orientation.RIGHT
		# Only change movement state to running if not airborne
		movement_state = MovementState.RUNNING if movement_state != MovementState.AIRBORNE else MovementState.AIRBORNE
	elif Input.is_action_pressed("Run left"):
		orientation = Orientation.LEFT
		# Only change movement state to running if not airborne
		movement_state = MovementState.RUNNING if movement_state != MovementState.AIRBORNE else MovementState.AIRBORNE
	else:
		# Only change movement state to idle if not airborne
		movement_state = MovementState.IDLE    if movement_state != MovementState.AIRBORNE else MovementState.AIRBORNE

	match (movement_state):
		MovementState.RUNNING:
			$AnimatedSprite2D.animation = "running"
		# This was added
		MovementState.AIRBORNE:
			$AnimatedSprite2D.animation = "jumping"
		_: # MovementState.IDLE
			$AnimatedSprite2D.animation = "idle"

	if orientation == Orientation.LEFT:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false


func _on_mock_air_timer_timeout():
	movement_state = MovementState.IDLE
