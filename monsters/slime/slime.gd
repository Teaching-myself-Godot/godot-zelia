extends CharacterBody2D

enum MovementState { AIRBORNE, FLOOR_BOUNCE, DYING }

var movement_state : int
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# We want the level designer to be able to modify stuff like this.
@export var JUMP_VELOCITY = -400.0
@export var X_VELOCITY = 100
@export var hp = 10
@export var damage = 1

func take_damage(dmg : int):
	hp -= dmg
	if hp <= 0:
		movement_state = MovementState.DYING
		$DissipateTimer.start()


# enable the collision shape that matches the current movement state
func pick_collision_shape_for_movement_state():
	match (movement_state):
		MovementState.AIRBORNE:
			$AirborneCollisionShape.disabled = false
			$FloorBounceCollisionShape.disabled = true
		MovementState.FLOOR_BOUNCE:
			$AirborneCollisionShape.disabled = true
			$FloorBounceCollisionShape.disabled = false
		MovementState.DYING:
			$AirborneCollisionShape.disabled = true
			$FloorBounceCollisionShape.disabled = true

func _ready():
	# assume it starts out hanging in the air
	movement_state = MovementState.AIRBORNE
	
	# enable the collision shape that matches the movement state
	pick_collision_shape_for_movement_state()

	# start up the correct animated sprite sprite frames for that state
	$AnimatedSprite2D.animation = "airborne"
	$AnimatedSprite2D.play()
	# The sprite_frames of $AnimatedSprite2D is a singleton, so after calling 
	# add_animation one time, it exists for all other instances
	if "dissipate" not in $AnimatedSprite2D.sprite_frames.get_animation_names():
		# Add a new animation to the SpriteFrames instance of the $AnimatedSprite2D node
		$AnimatedSprite2D.sprite_frames.add_animation("dissipate")
		# Loop through all rendition images in the global singleton
		for rendition in TextureRenditions.slime_dissipate:
			# Add them as a frame to 
			$AnimatedSprite2D.sprite_frames.add_frame("dissipate", rendition)

func set_movement_state():
	if movement_state == MovementState.DYING:
		pass
	elif is_on_floor():
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

func start_jump(init_velocity = JUMP_VELOCITY):
	$FloorBounceTimer.stop()
	velocity.y = init_velocity
	follow_player()

func pick_sprite_for_movement_state():
	match(movement_state):
		MovementState.FLOOR_BOUNCE:
			$AnimatedSprite2D.animation = "floor_bounce"
		MovementState.AIRBORNE:
			$AnimatedSprite2D.animation = "airborne"
		MovementState.DYING:
			$AnimatedSprite2D.animation = "dissipate"

func damage_player():
	# detect collisions based on collision count
	for i in get_slide_collision_count():
		# get current colliding other thing
		var collider = get_slide_collision(i).get_collider()
		# test if other thing is the Player
		if collider and collider.name == "Player":
			# make the player take damage
			collider.take_damage(damage)
			start_jump(-150)

func handle_movement_state():
	if movement_state == MovementState.DYING:
		velocity = Vector2(0, 0)
	elif is_on_wall():
		follow_player()

	pick_collision_shape_for_movement_state()
	pick_sprite_for_movement_state()
	damage_player()



func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta
	# Set, and handle movement state 
	set_movement_state()
	handle_movement_state()

	move_and_slide()

func _on_floor_bounce_timer_timeout():
	start_jump()


func _on_dissipate_timer_timeout():
	queue_free()
