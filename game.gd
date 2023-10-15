extends Node

func _on_player_cast_projectile(spell_class, direction, origin):
	var spell = spell_class.instantiate()
	add_child(spell)
	spell.rotation = direction
	spell.position = origin
	spell.velocity = Vector2.from_angle(direction) * 150.0


func _on_breakable_terrains_add_breakable_tile(target_pos, texture, texture_pos, collisigon):
	print("Target position of BreakableTile:   " + str(target_pos))
	print("Atlas texture resource dir:         " + str(texture.resource_path))
	print("Position of this tile in the atlas: " + str(texture_pos))
	print("Collision polygon of this tile:     " + str(collisigon))
