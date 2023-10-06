extends TileMap

signal add_breakable_tile(
	position     : Vector2, 
	textures     : Array, 
	atlas_coords : Vector2i,
	collisigon   : PackedVector2Array,
	hp           : int, 
	falls_down   : bool,
	damage       : int
)

func _ready():
	if get_meta("breakable") or get_meta("falls_down"):
		visible = false

		for tile in get_used_cells(0):
			var source_id = get_cell_source_id(0, tile)
			var tileset_source : TileSetAtlasSource = tile_set.get_source(source_id)
			var renditions = []
			if get_meta("breakable"):
				renditions = TextureRenditions.get_cracked_renditions(source_id, tileset_source.texture.get_image())
			else:
				renditions = TextureRenditions.get_fall_crack_renditions(source_id, tileset_source.texture.get_image())
			var tile_atlas_coords = get_cell_atlas_coords(0, tile)
			var tile_data = tileset_source.get_tile_data(tile_atlas_coords, 0)
			emit_signal(
				"add_breakable_tile",
				tile * 15,
				renditions,
				tile_atlas_coords,
				tile_data.get_collision_polygon_points(0, 0),
				get_meta("hp"),
				get_meta("falls_down"),
				get_meta("damage")
			)
		queue_free()
