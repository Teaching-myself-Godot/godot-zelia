extends Area2D

# Initialize the fireball with zero speed (x = 0, y = 0)
@export var velocity = Vector2.ZERO
@export var damage = 2
var done = false

var dissipation_shader = preload("res://dissipation_shader.gdshader")


var dissipate_fade = 0.0
var dissipate_scatter = 0.0
func _ready():
	var material : ShaderMaterial = $Sprite2D.material
	material.shader = dissipation_shader.duplicate()
	
#	# Start playing the "default" animation
#	$AnimatedSprite2D.play("default")
#
#	if "dissipate" not in $AnimatedSprite2D.sprite_frames.get_animation_names():
#		# Add a new animation to the SpriteFrames instance of the $AnimatedSprite2D node
#		$AnimatedSprite2D.sprite_frames.add_animation("dissipate")
#		# Loop through all rendition images in the global singleton fireball_dissipate
#		for rendition in TextureRenditions.fireball_dissipate:
#			# Add them as a frame to 
#			$AnimatedSprite2D.sprite_frames.add_frame("dissipate", rendition)

func _physics_process(delta):
	# Update position by velocity-vector
	if velocity:
		position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	# play the dissipate animation we coded
#	$AnimatedSprite2D.play("dissipate")
	# start the new timer in stead of calling queue_free here
	$DissipateTimer.start()
	# slow it down to 1/10th the speed
	velocity = 0
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _on_dissipate_timer_timeout():
	dissipate_fade += 0.1
	dissipate_scatter += 0.1
	var material : ShaderMaterial = $Sprite2D.material
	material.set_shader_parameter("fade", dissipate_fade)
	material.set_shader_parameter("scatter", dissipate_scatter)
	
