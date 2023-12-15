extends Node

var fireball = preload("res://projectiles/fireball/fireball.png").get_image()
var fireball_dissipate : Array = []

var slime = preload("res://monsters/slime/green/5.png").get_image()
var slime_dissipate : Array = []

var crack_mask_0 = preload("res://surface_maps/crack-mask-0.png").get_image()
var crack_mask_1 = preload("res://surface_maps/crack-mask-1.png").get_image()
var crack_mask_2 = preload("res://surface_maps/crack-mask-2.png").get_image()
var crack_mask_3 = preload("res://surface_maps/crack-mask-3.png").get_image()
var crack_masks = [crack_mask_0, crack_mask_1, crack_mask_2, crack_mask_3]
var cracked_rendition_map : Dictionary = {}

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

func get_cracked_renditions(source_id: int, src_image : Image):
	if source_id in cracked_rendition_map:
		return cracked_rendition_map[source_id]
	print("Assert single invocation for get_cracked_renditions:" + str(source_id))
	# copy the source image into the rendition map
	cracked_rendition_map[source_id] = [ImageTexture.create_from_image(src_image)]

	# for each alpha mask we preloaded into the crack_masks array ...
	for crack_mask in crack_masks:
		# ... make a rendition with get_alpha_mask_rendition and add it to 
		# the dictionary using source_id as key
		cracked_rendition_map[source_id].append(get_alpha_mask_rendition(src_image, crack_mask)) 
	# of course return the dictionary
	return cracked_rendition_map[source_id]

func get_alpha_mask_rendition(src_image : Image, alpha_map : Image):
	# create a destination image with the same properties as the source image
	var dst_rendition = Image.create(src_image.get_width(), src_image.get_height(), false, src_image.get_format())

	# loop through all the pixels in the source image
	for x in range(src_image.get_width()):
		for y in range(src_image.get_height()):

			# Get the original color
			var src_color = src_image.get_pixel(x, y)

			# Get the color representing the amount of transparency to draw
			var alpha_color = alpha_map.get_pixel(x, y)

			# Calculate how much transparency this should be, by inverting
			# the alpha-amount of the mask's color
			var dest_alpha = 1.0 - alpha_color.a if 1.0 - alpha_color.a > 0.0 else 0.0

			# draw a pixel to the destination image based on the source pixel
			# and set the alpha to the lowest of these 2 alpha values:
			#  1. dest_alpha
			#  2. the alpha of the source pixel
			dst_rendition.set_pixel(x, y, Color(src_color.r, src_color.g, src_color.b, min(src_color.a, dest_alpha)))

	# return the destination image as an ImageTexture object
	return ImageTexture.create_from_image(dst_rendition)
