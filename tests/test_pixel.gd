extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("/tmp/opencode/viewer_popup_shot.png")
	if img == null:
		print("no img")
		quit()
		return
	print("img size:", img.get_size())
	var blue_count := 0
	var white_text := 0
	for y in range(0, img.get_height(), 4):
		for x in range(0, img.get_width(), 4):
			var c: Color = img.get_pixel(x, y)
			if c.b > 0.5 and c.b > c.r + 0.2 and c.b > c.g + 0.15:
				blue_count += 1
			if c.r > 0.8 and c.g > 0.8 and c.b > 0.8:
				white_text += 1
	print("blue border pixels:", blue_count, " white text pixels:", white_text)
	quit()