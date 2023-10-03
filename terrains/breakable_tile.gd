extends Area2D

@export var hp : int
@export var texture : Texture2D
@export var atlas_coords : Vector2
@export var falls_down : bool = false
@export var velocity = Vector2.ZERO
@export var damage = 2;

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.set_texture(texture)
	$Sprite2D.region_rect = Rect2(atlas_coords.x * 15, atlas_coords.y * 15, 15, 15)

func _physics_process(delta):
	# Update position by velocity-vector
	if velocity:
		position += velocity * delta

func take_damage(dmg : int):
	if hp <= 0:
		if falls_down:
			velocity.y = 100
		else:
			queue_free()
	else:
		hp -= dmg

func _on_visible_on_screen_notifier_2d_screen_exited():
	if velocity.y > 0:
		queue_free()

func _on_body_entered(body):
	if velocity.y > 0:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
