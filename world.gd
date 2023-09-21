extends TileMap

func _process(delta):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_player_cast_fire_magic(Fireball, direction, location):
	var fireball = Fireball.instantiate()
	add_child(fireball)
	fireball.rotation = direction
	fireball.position = location
	fireball.velocity = Vector2.from_angle(direction) * 150.0
