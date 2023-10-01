extends Node

func _on_player_cast_projectile(spell_class, direction, origin):
	var spell = spell_class.instantiate()
	add_child(spell)
	spell.rotation = direction
	spell.position = origin
	spell.velocity = Vector2.from_angle(direction) * 150.0

