extends StaticBody2D

@export var hp          : float = 10.0
@export var texture     : Texture2D
@export var texture_pos : Vector2i
@export var collisigon  : PackedVector2Array

var start_hp            : float
var cracked_renditions  : Array

func _ready():
	cracked_renditions = TextureRenditions.get_cracked_renditions(texture.get_rid().get_id(), texture.get_image())
	$Sprite2D.set_texture(cracked_renditions[0])
	$Sprite2D.region_rect = Rect2(texture_pos.x, texture_pos.y, 15, 15)
	$CollisionPolygon2D.polygon = collisigon
	start_hp = hp

func take_damage(dmg : float):
	hp -= dmg
	if hp <= 0:
		queue_free()
	
	var perc = hp / start_hp
	if perc > .9:
		$Sprite2D.set_texture(cracked_renditions[0])
	elif perc > .8:
		$Sprite2D.set_texture(cracked_renditions[1])
	elif perc > .6:
		$Sprite2D.set_texture(cracked_renditions[2])
	elif perc > .3:
		$Sprite2D.set_texture(cracked_renditions[3])
	else:
		$Sprite2D.set_texture(cracked_renditions[4])
