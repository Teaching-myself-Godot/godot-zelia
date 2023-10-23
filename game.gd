extends Node

var BreakableTile = preload("res://tiles/breakable_tile.tscn")

func _on_player_cast_projectile(spell_class, direction, origin):
	var spell = spell_class.instantiate()
	add_child(spell)
	spell.rotation = direction
	spell.position = origin
	spell.velocity = Vector2.from_angle(direction) * 150.0


func _on_breakable_terrains_add_breakable_tile(
	target_pos  : Vector2,
	texture     : Texture2D,
	texture_pos : Vector2i,
	collisigon  : PackedVector2Array
):
	var new_tile = BreakableTile.instantiate()
	new_tile.position    = target_pos
	new_tile.texture     = texture
	new_tile.texture_pos = texture_pos
	new_tile.collisigon  = collisigon
	add_child.call_deferred(new_tile)
