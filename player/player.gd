extends RigidBody2D

const WALK_ACCEL = 500.0
const WALK_DEACCEL = 500.0
const WALK_MAX_VELOCITY = 140.0
const AIR_ACCEL = 100.0
const AIR_DEACCEL = 100.0
const JUMP_VELOCITY = 380
const STOP_JUMP_FORCE = 450.0
const MAX_FLOOR_AIRBORNE_TIME = 0.15

var anim = ""
var siding_left = false
var jumping = false
var stopping_jump = false

var floor_h_velocity = 0.0

var airborne_time = 1e20
var shoot_time = 1e20

func _ready():
	$AnimatedSprite2D.play()

# -> FIXME: rewrite to longer name: state
func _integrate_forces(s):
	# -> FIXME: rewrite to longer names: velocity
	var lv = s.get_linear_velocity()
	# -> is step the same as delta in the _process func?
	var step = s.get_step()

	var new_anim = anim
	var new_siding_left = siding_left
	
	# I'm keeping my own InputMap names
	var move_left = Input.is_action_pressed("Run left")
	var move_right = Input.is_action_pressed("Run right")
	var jump = Input.is_action_pressed("Jump")
	
	# Deapply prev floor velocity.
	# -> is this one of those bits that will become apparent later?
	lv.x -= floor_h_velocity
	floor_h_velocity = 0.0

	# Find the floor (a contact with upwards facing collision normal).
	# -> looks like very reusable code for _anything_ landing..
	var found_floor = false
	var floor_index = -1
	
	for x in range(s.get_contact_count()):
		var ci = s.get_contact_local_normal(x)

		if ci.dot(Vector2(0, -1)) > 0.6:
			found_floor = true
			floor_index = x

	if found_floor:
		airborne_time = 0.0
	else:
		airborne_time += step # Time it spent in the air -> since last iteration?

	# -> looks like a 15ms delay for some smoothness?
	var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME

	# Process jump -> this looks pretty intuitive
	if jumping:
		if lv.y > 0:
			# Set off the jumping flag if going down.
			jumping = false
		elif not jump:
			stopping_jump = true

		if stopping_jump:
			lv.y += STOP_JUMP_FORCE * step


	if on_floor:
		# Process logic when character is on floor.
		if move_left and not move_right:
			# accelerate to max velocity 
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= WALK_ACCEL * step
		elif move_right and not move_left:
			# accelerate to max velocity 
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += WALK_ACCEL * step
		else:
			# decelerate down to 0 velocity
			var xv = abs(lv.x)
			xv -= WALK_DEACCEL * step
			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv

		# Check jump.
		# -> Ok so this is the moment the jump is initiated
		if not jumping and jump:
			lv.y = -JUMP_VELOCITY
			jumping = true
			stopping_jump = false
			$JumpSound.play()

		# Check siding -> rewrite to orientation so I can understand better?
		if lv.x < 0 and move_left:
			new_siding_left = true
		elif lv.x > 0 and move_right:
			new_siding_left = false
		if jumping:
			new_anim = "jumping"
		elif abs(lv.x) < 0.1:
			new_anim = "idle"
		else:
			# -> keeping my own names
			new_anim = "running"
	else:
		# Process logic when the character is in the air.
		if move_left and not move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= AIR_ACCEL * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += AIR_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= AIR_DEACCEL * step

			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv

		# -> so we dropped a lot of cases here, we only have jumping
		# -> for the moment
		new_anim = "jumping"

	# Update siding -> I really don't recognise that word; TODO: look it up
	if new_siding_left != siding_left:
		if new_siding_left:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false

		siding_left = new_siding_left

	# Change animation.
	if new_anim != anim:
		anim = new_anim
		$AnimatedSprite2D.animation = new_anim

	# Apply floor velocity.
	if found_floor:
		floor_h_velocity = s.get_contact_collider_velocity_at_position(floor_index).x
		lv.x += floor_h_velocity

	# Finally, apply gravity and set back the linear velocity.
	lv += s.get_total_gravity() * step
	s.set_linear_velocity(lv)

