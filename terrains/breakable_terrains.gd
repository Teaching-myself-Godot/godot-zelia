extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	for tile in get_used_cells(0):
		var source_id = get_cell_source_id(0, tile)
		var tileset_source = tile_set.get_source(source_id)
		var tile_atlas_coords = get_cell_atlas_coords(0, tile)
		print(tile)
		print(tileset_source.texture)
		print(tile_atlas_coords)
		print(get_meta("hp"))

