extends Area2D

@export var velocity = Vector2.ZERO


func _ready():
	$AnimatedSprite2D.play("default")

func _physics_process(delta):
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body):
	$AnimatedSprite2D.play("dissipate")
	$DissipateTimer.start()
	velocity *= 0.1

func _on_dissipate_timer_timeout():
	queue_free()
