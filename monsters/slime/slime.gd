extends CharacterBody2D

enum MovementState { AIRBORNE, FLOOR_BOUNCE }

var movement_state : int
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# We want the level designer to be able to modify stuff like this.
@export var JUMP_VELOCITY = -400.0
@export var X_VELOCITY = 100
@export var hp = 10

func take_damage(dmg : int):
	hp -= dmg
	print("Ouch! hp = " + str(hp))

# enable the collision shape that matches the current movement state
func pick_collision_shape_for_movement_state():
	match (movement_state):
		MovementState.AIRBORNE:
			$AirborneCollisionShape.disabled = false
			$FloorBounceCollisionShape.disabled = true
		MovementState.FLOOR_BOUNCE:
			$AirborneCollisionShape.disabled = true
			$FloorBounceCollisionShape.disabled = false

func _ready():
	# assume it starts out hanging in the air
	movement_state = MovementState.AIRBORNE
	
	# enable the collision shape that matches the movement state
	pick_collision_shape_for_movement_state()

	# start up the correct animated sprite sprite frames for that state
	$AnimatedSprite2D.animation = "airborne"
	$AnimatedSprite2D.play()

func set_movement_state():
	if is_on_floor():
		if movement_state == MovementState.AIRBORNE:
			velocity.x = 0
			$FloorBounceTimer.start()
		movement_state = MovementState.FLOOR_BOUNCE
	else:
		movement_state = MovementState.AIRBORNE

func follow_player():
	if PlayerState.position.x < position.x:
		velocity.x = -X_VELOCITY
	else:
		velocity.x = X_VELOCITY

func start_jump():
	velocity.y = JUMP_VELOCITY
	follow_player()

func pick_sprite_for_movement_state():
	match(movement_state):
		MovementState.FLOOR_BOUNCE:
			$AnimatedSprite2D.animation = "floor_bounce"
		MovementState.AIRBORNE:
			$AnimatedSprite2D.animation = "airborne"

func handle_movement_state():
	# keep trying to reach the player, even when bumping against the wall
	if is_on_wall():
		follow_player()

	pick_collision_shape_for_movement_state()
	pick_sprite_for_movement_state()

func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta
	# Set, and handle movement state 
	set_movement_state()
	handle_movement_state()

	
	move_and_slide()

func _on_floor_bounce_timer_timeout():
	start_jump()
