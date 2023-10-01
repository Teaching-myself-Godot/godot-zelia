extends CharacterBody2D

enum Orientation   { LEFT, RIGHT }
enum MovementState { IDLE, RUNNING, AIRBORNE, CASTING, FAINTED }

# I removed the exports for now, no debugging needed at the moment
var movement_state : int
var orientation    : int

@export var cast_angle : float

# Get the gravity from the project settings so you can sync with rigid body nodes.
# NOTE: I changed the default from 980 to 1300, Zelia jumps high yet falls fast.
var gravity    = ProjectSettings.get_setting("physics/2d/default_gravity")
# The most realistic speed for Zelia's feet
var speed      = 120.0
# Funnily the original game had jump_speed set to -4.0 and gravity to 13.0
var jump_speed = -400.0

var hp = 10.0

# Preload the Fireball class, used to identify it in cast_projectile
var Fireball = preload("res://projectiles/fireball/fireball.tscn")

# Cast a projectile spell (like Fireball) in direction, from origin
signal cast_projectile(spell_class, direction : Vector2, origin : Vector2)

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

# Set initial movement state
func set_movement_state():
	if movement_state == MovementState.FAINTED:
		velocity = Vector2(0,0)
	elif Input.is_action_pressed("Fireball button"):
		movement_state = MovementState.CASTING
		set_cast_angle()
	elif is_on_floor():
		movement_state = MovementState.IDLE
	else:
		movement_state = MovementState.AIRBORNE

# She cannot run or move on x-axis in the air while casting
# base her orientation on the angle of casting as well
func handle_casting():
	velocity.x = 0
	if cast_angle > -(PI * 0.5) and cast_angle < PI * 0.5:
		orientation = Orientation.RIGHT
	else:
		orientation = Orientation.LEFT

func handle_airborne():
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

func take_damage(damage : float):
	if hp > 0:
		hp -= damage
	if hp <= 0:
		movement_state = MovementState.FAINTED
		$CollisionShape2D.disabled = true
		$RespawnTimer.start()



func handle_jumping():
	# Handle Jump, only when on the floor
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		$JumpSound.play()
		movement_state = MovementState.AIRBORNE
		velocity.y = jump_speed

func handle_movement_state():
	if movement_state == MovementState.FAINTED:
		pass
	elif movement_state == MovementState.CASTING:
		handle_casting()
	elif movement_state == MovementState.AIRBORNE:
		handle_airborne()
	else:
		handle_running()
		handle_jumping()

# Determine the casting sprite name based on decimal degrees
func get_casting_sprite(deg) -> String:
	var casting_left  = (deg > 120 and deg < 180) or (deg > -180 and deg < -120)
	var casting_right = deg > -60  and deg < 60
	var casting_up    = deg > -160 and deg < 0
	var casting_down  = deg > 30   and deg < 160

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
		MovementState.FAINTED:
			$AnimatedSprite2D.animation = "dying"
		_: # MovementState.IDLE
			$AnimatedSprite2D.animation = "idle"

# Determine sprite-flip based on orientation
func flip_current_sprite():
	if orientation == Orientation.LEFT:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

# No changes here
func _ready():
	movement_state = MovementState.IDLE
	orientation    = Orientation.RIGHT
	$AnimatedSprite2D.play()
	PlayerState.respawn_point = position

# Changed _process to _physics_process
func _physics_process(delta):
	# Apply the gravity.
	velocity.y += gravity * delta

	# Set, and handle movement state 
	set_movement_state()
	handle_movement_state()

	# Set the correct sprite based on movement state
	set_current_sprite()

	# Determine sprite-flip based on orientation
	flip_current_sprite()

	# Apply 2d physics engine's movement 
	move_and_slide()

func _process(_delta):
	PlayerState.position = position

# Spawn a fireball every 100ms if Fireball button is held
func _on_fireball_interval_timer_timeout():
	if movement_state == MovementState.CASTING:
		# Signal that a fireball should be cast at casting angle and 
		# from Player's hands
		var origin = position + Vector2(14, 0).rotated(cast_angle) + Vector2(0, 2)
		cast_projectile.emit(Fireball, cast_angle, origin)


func _on_respawn_timer_timeout():
	position = PlayerState.respawn_point
	hp = 10
	$CollisionShape2D.disabled = false
	movement_state = MovementState.IDLE
