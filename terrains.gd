extends TileMap

func _ready():
	if get_meta("breakable"):
		print (name + " is breakable")
		print (name + "'s origin is: " + str(position))
		# Loop through the tile positions in our current (only) layer
		for cell in get_used_cells(0):
			print("Tile grid position:            " + str(cell))
			print("BreakableTile target position: " + str(Vector2i(position) + cell * tile_set.tile_size))
