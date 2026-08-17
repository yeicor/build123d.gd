extends BdgLineObject
## BdgIntersectingLine - Line Object: Intersecting Line
## Create a straight line starting at a point, extending along a direction until it intersects another shape.
class_name BdgIntersectingLine

var start_point: Vector3
var direction: Vector3
var end_point: Vector3

## Args:
##   (start: Vector3, direction: Vector3, other: BdgShape, mode: Mode = ADD)
func _init(...args) -> void:
	super()
	var mode := BdgEnums.Mode.ADD
	if args.size() < 3:
		push_error("BdgIntersectingLine: expected (start: Vector3, direction: Vector3, other: BdgShape)")
		return

	start_point = _to_v3(args[0])
	direction = _to_v3(args[1]).normalized()
	var other: BdgShape = args[2] as BdgShape
	if args.size() > 3 and args[3] != null:
		mode = args[3]

	if other == null or other.is_null():
		push_error("BdgIntersectingLine: target other shape is null")
		return

	# Build a long ray line
	var ray_len := 1e5
	var ray_edge := BdgEdge.make_line(start_point, start_point + direction * ray_len)

	var hit_point := Vector3.ZERO
	var hit_found := false

	if other is BdgEdge:
		var hits := ray_edge.find_intersection(other)
		if not hits.is_empty():
			hit_point = hits[0]["point"]
			hit_found = true
	else:
		# For faces/solids/wires/compounds, intersect with other edges or section
		for e in other.edges():
			var hits := ray_edge.find_intersection(e)
			if not hits.is_empty():
				var p: Vector3 = hits[0]["point"]
				var dist: float = (p - start_point).dot(direction)
				if dist > 1e-6:
					hit_point = p
					hit_found = true
					break

		if not hit_found:
			# Try distance extrema
			var pts: Array = []
			if other is BdgShape:
				var res: Array = (other as BdgShape).distance_to_with_closest_points(ray_edge)
				if res.size() >= 3:
					pts = [res[1], res[2]]
			elif other != null and other.has_method("distance_to_with_closest_points"):
				var res_val: Variant = other.call("distance_to_with_closest_points", ray_edge)
				if res_val is Array and (res_val as Array).size() >= 3:
					pts = [(res_val as Array)[1], (res_val as Array)[2]]
				elif res_val is Dictionary:
					pts = (res_val as Dictionary).get("closest_points", [])


			if not pts.is_empty():
				hit_point = pts[0]
				hit_found = true


	if not hit_found:
		hit_point = start_point + direction * 10.0

	end_point = hit_point
	var line := BdgEdge.make_line(start_point, end_point)
	if line != null:
		_wrapped = line._wrapped

	_register(mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	return Vector3.ZERO
