extends StaticBody2D

@export var hp : int
@export var textures : Array
@export var atlas_coords : Vector2
@export var collisigon : PackedVector2Array
@export var falls_down : bool = false
@export var velocity = Vector2.ZERO
@export var damage = 2;

var start_hp : float
var gravity_scale = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.set_texture(textures[0])
	$Sprite2D.region_rect = Rect2(atlas_coords.x * 15, atlas_coords.y * 15, 15, 15)
	$CollisionPolygon2D.polygon = collisigon
	start_hp = hp

func _process(delta):
	if gravity_scale > 0:
		var collision = move_and_collide(Vector2(0, gravity_scale * 100 * delta))
		if collision:
			var collider = collision.get_collider()
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
			queue_free()


func take_damage(dmg : int):
	if hp <= 0:
		if falls_down:
			gravity_scale = 1
		else:
			queue_free()
	else:
		hp -= dmg
	
	var perc = hp / start_hp
	if perc > .9:
		$Sprite2D.set_texture(textures[0])
	elif perc > .8:
		$Sprite2D.set_texture(textures[1])
	elif perc > .6:
		$Sprite2D.set_texture(textures[2])
	elif perc > .3:
		$Sprite2D.set_texture(textures[3])
	else:
		$Sprite2D.set_texture(textures[4])

func _on_visible_on_screen_notifier_2d_screen_exited():
	if gravity_scale > 0:
		queue_free()
