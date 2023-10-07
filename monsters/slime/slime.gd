extends CharacterBody2D

enum MovementState { AIRBORNE, FLOOR_BOUNCE }

var movement_state : int

# We want the level designer to be able to modify stuff like this.
@export var JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	# assume it starts out hanging in the air
	movement_state = MovementState.AIRBORNE

	# start up the correct animated sprite sprite frames for that state
	$AnimatedSprite2D.animation = "airborne"
	$AnimatedSprite2D.play()

func _physics_process(delta):
	velocity.y += gravity * delta
	move_and_slide()
