extends RefCounted
## BdgOpsSketch - Operations for 2D sketches and profiles.
## Mirrors build123d/operations_sketch.py.
class_name BdgOpsSketch

## Create a Face from one or more closed wires.
static func make_face(wires_or_edges: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgFace:
	var face: BdgFace = null
	if wires_or_edges is BdgWire:
		face = BdgFace.make_from_wires(wires_or_edges)
	elif wires_or_edges is Array:
		var wires: Array = []
		var edges: Array = []
		for item in wires_or_edges:
			if item is BdgWire:
				wires.append(item)
			elif item is BdgEdge:
				edges.append(item)
		if not wires.is_empty():
			var outer: BdgWire = wires[0]
			var inners := wires.slice(1)
			face = BdgFace.make_from_wires(outer, inners)
		elif not edges.is_empty():
			var w := BdgWire.make_wire(edges)
			if w != null:
				face = BdgFace.make_from_wires(w)

	if face != null and BdgBuilder.has_context(BdgBuildSketch.TAG):
		BdgBuilder.add_to_current(face, mode, BdgBuildSketch.TAG)
	return face

## 2D Convex Hull of points or shapes in the XY plane.
static func make_hull(points_or_shapes: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgFace:
	var raw_pts: Array[Vector3] = []
	if points_or_shapes is Array:
		for item in points_or_shapes:
			if item is Vector3:
				raw_pts.append(item)
			elif item is BdgShape:
				for v in (item as BdgShape).vertices():
					raw_pts.append(v.center())
	elif points_or_shapes is BdgShape:
		for v in (points_or_shapes as BdgShape).vertices():
			raw_pts.append(v.center())

	if raw_pts.size() < 3:
		push_error("make_hull requires at least 3 points")
		return null

	var hull_pts := _convex_hull_2d(raw_pts)
	if hull_pts.size() < 3:
		push_error("make_hull failed to form a polygon")
		return null

	var face := BdgFace.make_polygon(hull_pts)
	if face != null and BdgBuilder.has_context(BdgBuildSketch.TAG):
		BdgBuilder.add_to_current(face, mode, BdgBuildSketch.TAG)
	return face

## Trace a wire with a given line thickness to create a planar ribbon face.
static func trace(wire: BdgWire, distance: float, mode: int = BdgEnums.Mode.ADD) -> BdgFace:
	if wire == null or distance <= 0.0:
		push_error("trace: invalid wire or distance")
		return null

	var half := distance / 2.0
	var face: BdgFace = null
	if wire.is_closed():
		var outer := wire.offset_2d(half)
		var inner := wire.offset_2d(-half)
		if outer != null and inner != null:
			face = BdgFace.make_from_wires(outer, [inner])
	else:
		var es := wire.order_edges()
		var pts: Array[Vector3] = []
		for e in es:
			pts.append(e.start_point())
		if not es.is_empty():
			pts.append(es.back().end_point())
		# Build ribbon polygon along open polyline
		var left_pts: Array[Vector3] = []
		var right_pts: Array[Vector3] = []
		for i in pts.size():
			var p := pts[i]
			var t := Vector3.RIGHT
			if i == 0 and pts.size() > 1:
				t = (pts[1] - pts[0]).normalized()
			elif i == pts.size() - 1 and pts.size() > 1:
				t = (pts[i] - pts[i - 1]).normalized()
			elif pts.size() > 2:
				var t1 := (pts[i] - pts[i - 1]).normalized()
				var t2 := (pts[i + 1] - pts[i]).normalized()
				t = (t1 + t2).normalized()
			var n := Vector3.BACK.cross(t).normalized()
			left_pts.append(p + n * half)
			right_pts.append(p - n * half)
		right_pts.reverse()
		var ribbon_pts := left_pts + right_pts
		face = BdgFace.make_polygon(ribbon_pts)

	if face != null and BdgBuilder.has_context(BdgBuildSketch.TAG):
		BdgBuilder.add_to_current(face, mode, BdgBuildSketch.TAG)
	return face

## Full tangent rounding between two edges in a sketch.
static func full_round(sketch_or_face: Variant, edge1: BdgEdge, edge2: BdgEdge, radius: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgFace:
	var f: BdgFace = null
	if sketch_or_face is BdgFace:
		f = sketch_or_face
	elif sketch_or_face is BdgSketch:
		var fs := (sketch_or_face as BdgSketch).faces()
		if not fs.is_empty():
			f = fs[0]
	if f == null:
		push_error("full_round: face is required")
		return null

	var outer := f.outer_wire()
	if outer == null:
		return f

	var filleted := outer.fillet_2d(radius if radius > 0.0 else edge1.length() * 0.5)
	var result_face := BdgFace.make_from_wires(filleted, f.inner_wires())
	if result_face != null and BdgBuilder.has_context(BdgBuildSketch.TAG):
		BdgBuilder.add_to_current(result_face, mode, BdgBuildSketch.TAG)
	return result_face

## 2D Monotone Chain Convex Hull algorithm
static func _convex_hull_2d(pts: Array[Vector3]) -> Array[Vector3]:
	var sorted_pts := pts.duplicate()
	sorted_pts.sort_custom(func(a: Vector3, b: Vector3) -> bool:
		if is_equal_approx(a.x, b.x):
			return a.y < b.y
		return a.x < b.x
	)
	# Remove duplicates
	var unique: Array[Vector3] = []
	for p in sorted_pts:
		if unique.is_empty() or unique.back().distance_to(p) > 1e-6:
			unique.append(p)
	if unique.size() < 3:
		return unique

	var cross_2d := func(o: Vector3, a: Vector3, b: Vector3) -> float:
		return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)

	var lower: Array[Vector3] = []
	for p in unique:
		while lower.size() >= 2 and cross_2d.call(lower[lower.size() - 2], lower.back(), p) <= 0:
			lower.pop_back()
		lower.append(p)

	var upper: Array[Vector3] = []
	for i in range(unique.size() - 1, -1, -1):
		var p := unique[i]
		while upper.size() >= 2 and cross_2d.call(upper[upper.size() - 2], upper.back(), p) <= 0:
			upper.pop_back()
		upper.append(p)

	lower.pop_back()
	upper.pop_back()
	return lower + upper
