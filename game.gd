extends Node

var BreakableTile = preload("res://tiles/breakable_tile.tscn")

func _on_player_cast_projectile(spell_class, direction, origin):
	var spell = spell_class.instantiate()
	add_child(spell)
	spell.rotation = direction
	spell.position = origin
	spell.velocity = Vector2.from_angle(direction) * 150.0


func _on_breakable_terrains_add_breakable_tile(target_pos, texture, texture_pos, collisigon):
	var new_tile : StaticBody2D = BreakableTile.instantiate()
	new_tile.position = target_pos
	add_child.call_deferred(new_tile)
	print("Target position of BreakableTile:   " + str(target_pos))
	print("Atlas texture resource dir:         " + str(texture.resource_path))
	print("Position of this tile in the atlas: " + str(texture_pos))
	print("Collision polygon of this tile:     " + str(collisigon))
