extends Area2D

# Initialize the fireball with zero speed (x = 0, y = 0)
@export var velocity = Vector2.ZERO

func _ready():
	print(TextureRenditions.singleton_test)

func _physics_process(delta):
	# Update position by velocity-vector
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	# start the new timer in stead of calling queue_free here
	$DissipateTimer.start()
	# slow it down to 1/10th the speed
	velocity *= 0.1

func _on_dissipate_timer_timeout():
	queue_free()
