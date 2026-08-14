extends SceneTree

func _init() -> void:
	var hl := BdgHexLocations.new(10.0, 25, 25)
	print("count: ", hl.locations.size())
	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF
	for l in hl.locations:
		var p: Vector3 = (l as BdgLocation).position
		min_x = minf(min_x, p.x)
		max_x = maxf(max_x, p.x)
		min_y = minf(min_y, p.y)
		max_y = maxf(max_y, p.y)
	print("x range: %.6f .. %.6f" % [min_x, max_x])
	print("y range: %.6f .. %.6f" % [min_y, max_y])
	quit()
