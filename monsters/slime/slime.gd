extends CharacterBody2D

enum MovementState { AIRBORNE, FLOOR_BOUNCE, DYING }

const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var movement_state : int
var hp = 10
var damage = 1
func _ready():
	movement_state = MovementState.AIRBORNE
	$AnimatedSprite2D.sprite_frames.add_animation("dissipate")
	# Loop through all rendition images in the global singleton fireball_dissipate
	for rendition in TextureRenditions.green_slime_dissipate:
		# Add them as a frame to 
		$AnimatedSprite2D.sprite_frames.add_frame("dissipate", rendition)
	
	$AnimatedSprite2D.animation = "airborne"
	$AnimatedSprite2D.play()
	$FloorBounceCollisionShape.disabled = true
	$AirborneCollisionShape.disabled = false

# Set initial movement state
func set_movement_state():
	if movement_state == MovementState.DYING:
		$AirborneCollisionShape.disabled = true
		$FloorBounceCollisionShape.disabled = true
	elif is_on_floor():
		if movement_state == MovementState.AIRBORNE:
			$FloorBounceTimer.start()
			velocity.x = 0
		movement_state = MovementState.FLOOR_BOUNCE
		$FloorBounceCollisionShape.disabled = false
		$AirborneCollisionShape.disabled = true
	else:
		movement_state = MovementState.AIRBORNE
		$FloorBounceCollisionShape.disabled = true
		$AirborneCollisionShape.disabled = false	

func _physics_process(delta):
	velocity.y += gravity * delta
	
	set_movement_state()
	
	if movement_state == MovementState.DYING:
		velocity = Vector2(0, 0)
		$AnimatedSprite2D.animation = "dissipate"
	elif movement_state == MovementState.AIRBORNE:
		if is_on_wall():
			velocity.x = -100 if PlayerState.position.x < position.x else 100
		$AnimatedSprite2D.animation = "airborne"
	else:
		$AnimatedSprite2D.animation = "floor_bounce"

	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider.name == "Player":
			start_jump(-150)
			collider.take_damage(damage)
	
	move_and_slide()

func take_damage(damage : int):
	hp -= damage
	if hp <= 0:
		movement_state = MovementState.DYING
		$DissipateTimer.start()

func start_jump(init_velocity = JUMP_VELOCITY):
	$FloorBounceTimer.stop()
	velocity.y = init_velocity
	velocity.x = -100 if PlayerState.position.x < position.x else 100


func _on_floor_bounce_timer_timeout():
	start_jump()

func _on_dissipate_timer_timeout():
	queue_free()
