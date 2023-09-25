extends Area2D

# Initialize the fireball with zero speed (x = 0, y = 0)
@export var velocity = Vector2.ZERO

func _ready():
	# Start playing the "default" animation
	$AnimatedSprite2D.play("default")
	# Add a new animation to the SpriteFrames instance of the $AnimatedSprite2D node
	$AnimatedSprite2D.sprite_frames.add_animation("dissipate")
	# Loop through all rendition images in the global singleton fireball_dissipate
	for rendition in TextureRenditions.fireball_dissipate:
		# Add them as a frame to 
		$AnimatedSprite2D.sprite_frames.add_frame("dissipate", rendition)

func _physics_process(delta):
	# Update position by velocity-vector
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	# play the dissipate animation we coded
	$AnimatedSprite2D.play("dissipate")
	# start the new timer in stead of calling queue_free here
	$DissipateTimer.start()
	# slow it down to 1/10th the speed
	velocity *= 0.1

func _on_dissipate_timer_timeout():
	queue_free()
