extends Node

var BreakableTile = preload("res://terrains/breakable_tile.tscn")

var child_tiles = []

func _ready():
	for breakable_tile in child_tiles:
		add_child(breakable_tile)

func _process(_delta):
	if Input.is_action_just_pressed("Esc"):
		get_tree().quit()

func _on_player_cast_projectile(spell_class, direction, origin):
	var spell = spell_class.instantiate()
	add_child(spell)
	spell.rotation = direction
	spell.position = origin
	spell.velocity = Vector2.from_angle(direction) * 150.0


func _on_breakable_terrains_add_breakable_tile(position, texture, atlas_coords, hp, falls_down):
	var breakable_tile = BreakableTile.instantiate()
	breakable_tile.position = position
	breakable_tile.hp = hp
	breakable_tile.texture = texture
	breakable_tile.atlas_coords = atlas_coords
	breakable_tile.falls_down = falls_down
	child_tiles.append(breakable_tile)





