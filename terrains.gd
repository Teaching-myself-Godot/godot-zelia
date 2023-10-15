extends TileMap

signal add_breakable_tile(
	position     : Vector2i, 
	texture      : Texture2D, 
	texture_pos  : Vector2i,
	# collisigon is my personal shorthand for "collision polygon"
	collisigon   : PackedVector2Array
)


func _ready():
	if get_meta("breakable"):
		# Loop through the tile positions in our current (only) layer
		for cell in get_used_cells(0):
			var source_id = get_cell_source_id(0, cell)
			var tileset_source : TileSetAtlasSource = tile_set.get_source(source_id)
			var tile_atlas_coords = get_cell_atlas_coords(0, cell)
			var tile_data = tileset_source.get_tile_data(tile_atlas_coords, 0)
			emit_signal(
				"add_breakable_tile",
				Vector2i(position) + cell * tile_set.tile_size,
				tileset_source.texture,
				tile_atlas_coords * tile_set.tile_size,
				tile_data.get_collision_polygon_points(0, 0)
			)
