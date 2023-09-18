extends RigidBody2D

enum Orientation   { LEFT, RIGHT }
enum MovementState { IDLE, RUNNING, AIRBORNE }

# We will want to debug these states, let's export them as well
@export var movement_state : int
@export var orientation   : int

var can_detect_landing : bool

func _ready():
	movement_state = MovementState.IDLE
	orientation    = Orientation.RIGHT
	$AnimatedSprite2D.play()
	contact_monitor = true
	max_contacts_reported = 4
	gravity_scale = 1.5
	can_detect_landing = true


func _integrate_forces(state):
	if movement_state == MovementState.AIRBORNE:
		if can_detect_landing:
			for x in range(state.get_contact_count()):
				var ci = state.get_contact_local_normal(x)
				if ci.dot(Vector2(0, -1)) == 1.0:
					print("found floor")
					movement_state = MovementState.IDLE
				else:
					set_axis_velocity(Vector2(0, 0))
					apply_central_impulse(state.get_contact_local_normal(x) * 50)
					
func _physics_process(delta):
	# If user wants to jump, start the MockAirTimer and change the movement state to airborne
	if Input.is_action_just_pressed("Jump") and movement_state != MovementState.AIRBORNE:
		$JumpSound.play() # the new line
		movement_state = MovementState.AIRBORNE
		set_axis_velocity(Vector2(0, -400.0))
		$MockAirTimer.start()
		can_detect_landing = false
	


	if movement_state == MovementState.AIRBORNE:
		if Input.is_action_pressed("Run right"):
			orientation = Orientation.RIGHT
			set_axis_velocity(Vector2(80.0, 0))
		elif Input.is_action_pressed("Run left"):
			orientation = Orientation.LEFT
			set_axis_velocity(Vector2(-80.0, 0))
	else:
		if Input.is_action_pressed("Run right"):
			orientation = Orientation.RIGHT
			movement_state = MovementState.RUNNING
			set_axis_velocity(Vector2(120.0, 0.0))
		elif Input.is_action_pressed("Run left"):
			orientation = Orientation.LEFT
			movement_state = MovementState.RUNNING
			set_axis_velocity(Vector2(-120.0, 0.0))
		else:
			movement_state = MovementState.IDLE
			set_axis_velocity(Vector2(0.0, 0.0))

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
	can_detect_landing = true
