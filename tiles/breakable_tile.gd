extends StaticBody2D

@export var hp          : float = 10.0
@export var texture     : Texture2D
@export var texture_pos : Vector2i
@export var collisigon  : PackedVector2Array

func _ready():
	$Sprite2D.set_texture(texture)
	$Sprite2D.region_rect = Rect2(texture_pos.x, texture_pos.y, 15, 15)
	$CollisionPolygon2D.polygon = collisigon


func take_damage(dmg : float):
	hp -= dmg
	if hp <= 0:
		queue_free()
