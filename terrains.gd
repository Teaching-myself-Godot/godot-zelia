extends TileMap

func _ready():
	if get_meta("breakable"):
		print (name + " is breakable")
		print (name + "'s origin is: " + str(position))
		# Loop through the tile positions in our current (only) layer
		for cell in get_used_cells(0):
			print("Tile grid position:            " + str(cell))
			print("BreakableTile target position: " + str(Vector2i(position) + cell * tile_set.tile_size))
			var source_id = get_cell_source_id(0, cell)
			var tileset_source : TileSetAtlasSource = tile_set.get_source(source_id)
			print("TileSetAtlasSource:            " + tileset_source.resource_name)
			var tile_atlas_coords = get_cell_atlas_coords(0, cell)
			print("tile_atlas_coords:             " + str(tile_atlas_coords * tile_set.tile_size))
			print("texture:                       " + tileset_source.texture.resource_path)
