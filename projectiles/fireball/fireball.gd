extends Area2D

# Initialize the fireball with zero speed (x = 0, y = 0)
@export var velocity = Vector2.ZERO

func _physics_process(delta):
	# Update position by velocity-vector
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
