extends TileMap

signal add_breakable_tile(
	position     : Vector2, 
	texture      : Texture2D, 
	atlas_coords : Vector2i,
	collisigon   : PackedVector2Array,
	hp           : int, 
	falls_down   : bool
)

func _ready():
	visible = false

	for tile in get_used_cells(0):
		var source_id = get_cell_source_id(0, tile)
		var tileset_source : TileSetAtlasSource = tile_set.get_source(source_id)
		var tile_atlas_coords = get_cell_atlas_coords(0, tile)
		var tile_data = tileset_source.get_tile_data(tile_atlas_coords, 0)
		emit_signal(
			"add_breakable_tile",
			tile * 15,
			tileset_source.texture,
			tile_atlas_coords,
			tile_data.get_collision_polygon_points(0, 0),
			get_meta("hp"),
			get_meta("falls_down")
		)
	queue_free()
