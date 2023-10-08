extends Node

var fireball = preload("res://projectiles/fireball/fireball.png").get_image()
var fireball_dissipate : Array = []

var slime = preload("res://monsters/slime/green/5.png").get_image()
var slime_dissipate : Array = []

func _ready():
	slime_dissipate = get_dissipate_renditions(slime, 10, 2, 0.9)
	fireball_dissipate = get_dissipate_renditions(fireball, 15, 1, 0.5)

	
# Return a list of dissipating image renditions as an ImageTexture-Array
# - src_rendition is the original Image
# - amount is the amount of times to repeat the rendition effect
# - scatter is the chance of a pixel being rendered again in a given rendeition
# - fade is the factor by which the alpha channel transparency should be reduced 
# in each rendition
func get_dissipate_renditions(src_rendition : Image, amount : int = 14, scatter : int = 1, fade : float = 0.5):
	var renditions = []
	for n in range(amount):
		# Create a new Image instance with the same properties as the source image
		var dst_rendition = Image.create(src_rendition.get_width(), src_rendition.get_height(), false, src_rendition.get_format())
		# Loop through all the pixels
		for x in range(src_rendition.get_width()):
			for y in range(src_rendition.get_height()):
				# Get the original color
				var src_color = src_rendition.get_pixel(x, y)
				# Copy the source pixel if the random int between 0 and scatter
				# hits one
				if randi_range(0, scatter) == 1:
					# Copy the pixel, reduce opacity by factor fade
					dst_rendition.set_pixel(x, y, Color(src_color.r, src_color.g, src_color.b, src_color.a * fade))
		
		# append this rendition to result array
		renditions.append(ImageTexture.create_from_image(dst_rendition))
		# overwrite the src_rendition variable with a new empty image
		src_rendition = Image.create(src_rendition.get_width(), src_rendition.get_height(), false, src_rendition.get_format())
		# copy the current rendition into this variable entirely to be
		# manipulated in the next iteration
		src_rendition.copy_from(dst_rendition)
	# return the list of amount renditions
	return renditions
