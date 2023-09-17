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
	if Input.is_action_pressed("Run right"):
		orientation = Orientation.RIGHT
		movement_state = MovementState.RUNNING
	elif Input.is_action_pressed("Run left"):
		orientation = Orientation.LEFT
		movement_state = MovementState.RUNNING
	else:
		movement_state = MovementState.IDLE

	match (movement_state):
		MovementState.RUNNING:
			$AnimatedSprite2D.animation = "running"
		_: # MovementState.IDLE
			$AnimatedSprite2D.animation = "idle"

	if orientation == Orientation.LEFT:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
