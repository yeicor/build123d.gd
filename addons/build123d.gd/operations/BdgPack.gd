extends RefCounted
## BdgPack - 2D Nesting and Bin-Packing Algorithm.
## Positions a collection of shapes onto a rectangular sheet with padding.
## Mirrors build123d/pack.py pack.
class_name BdgPack

## Pack objects into a 2D sheet (sheet_width x sheet_height) with padding.
## Returns Array of relocated BdgShape objects.
static func pack(objects: Array, sheet_width: float, sheet_height: float, padding: float = 2.0) -> Array:
	var result: Array = []
	if objects.is_empty():
		return result

	# Extract items with bounding box dimensions
	var items: Array = []
	for obj in objects:
		if obj is BdgShape:
			var s: BdgShape = obj
			var bbox := s.bounding_box()
			var w := (bbox.max.x - bbox.min.x) + padding * 2.0
			var h := (bbox.max.y - bbox.min.y) + padding * 2.0
			items.append({
				"shape": s,
				"w": w,
				"h": h,
				"bbox": bbox,
			})

	# Sort descending by height for shelf packing algorithm
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["h"] > b["h"]
	)

	var cur_x := padding
	var cur_y := padding
	var row_h := 0.0

	for item in items:
		var s: BdgShape = item["shape"]
		var w: float = item["w"]
		var h: float = item["h"]
		var bbox: BdgBoundBox = item["bbox"]

		if cur_x + w > sheet_width - padding:
			# Move to next row
			cur_x = padding
			cur_y += row_h + padding
			row_h = 0.0

		if cur_y + h > sheet_height - padding:
			push_warning("BdgPack.pack: shape exceeds sheet dimensions")

		# Calculate target offset
		var target_min_x := cur_x + padding
		var target_min_y := cur_y + padding
		var dx := target_min_x - bbox.min.x
		var dy := target_min_y - bbox.min.y

		var relocated := s.translate(Vector3(dx, dy, 0.0))
		result.append(relocated)

		cur_x += w
		row_h = maxf(row_h, h)

	return result
