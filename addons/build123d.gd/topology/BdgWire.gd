extends BdgMixin1D
## BdgWire - a closed or open sequence of connected edges, wrapping OcgTopoDSWire.
## Mirrors build123d/topology/one_d.py Wire.
class_name BdgWire

func _init(...args) -> void:
	super(args[0] if args.size() == 1 else null)

## Create a wire from a list of edges (must share endpoints)
static func make_wire(edges: Array) -> BdgWire:
	var mk := OcgBRepBuilderAPIMakeWire.new()
	for e in edges:
		mk.add_g(e._wrapped)
	return BdgWire.new(mk.wire())

## Create a wire from a sequence of points as straight segments
static func make_polygon(points: Array, close: bool = true) -> BdgWire:
	if points.size() < 2:
		push_error("make_polygon needs at least 2 points")
		return null
	var mk := OcgBRepBuilderAPIMakePolygon.new()
	for i in points.size():
		var p: Vector3 = points[i]
		mk.add_N(OcgGpPnt.from_6(p.x, p.y, p.z))
	if close:
		mk.close()
	return BdgWire.new(mk.wire())

## 2D offset of this planar wire (positive = grow outward, negative = inward).
## Returns a new BdgWire (or null on failure).
func offset_2d(
	distance: float,
	kind: int = OcgEnums.GeomAbs_JoinType.GeomAbs_Arc,
	closed: bool = true,
) -> BdgWire:
	var builder := OcgBRepOffsetAPIMakeOffset.from_e(_wrapped, kind, not closed)
	builder.add_wire(_wrapped)
	builder.perform(distance, 0.0)
	if not builder.is_done():
		push_error("BdgWire.offset_2d failed")
		return null
	var result := builder.shape()
	if result.shape_type() != BdgEnums.ShapeType.WIRE:
		push_error("BdgWire.offset_2d did not produce a wire")
		return null
	return BdgWire.new(result)

## Create a circle wire in a plane
static func make_circle(radius: float, plane: BdgPlane = null) -> BdgWire:
	if plane == null:
		plane = BdgPlane.XY
	var e := BdgEdge.make_circle(radius, plane)
	var mk := OcgBRepBuilderAPIMakeWire.new()
	mk.add_g(e._wrapped)
	return BdgWire.new(mk.wire())

## Create a rectangular wire
static func make_rect(width: float, height: float, plane: BdgPlane = null) -> BdgWire:
	if plane == null:
		plane = BdgPlane.XY
	var hw := width / 2.0
	var hh := height / 2.0
	var origin: Vector3 = plane.origin
	var x: Vector3 = plane.x_dir
	var y: Vector3 = plane.y_dir
	var corners := [
		origin + x * -hw + y * -hh,
		origin + x * hw + y * -hh,
		origin + x * hw + y * hh,
		origin + x * -hw + y * hh,
	]
	return make_polygon(corners, true)

## Create an elliptical wire in a plane
static func make_ellipse(x_radius: float, y_radius: float, plane: BdgPlane = null) -> BdgWire:
	if plane == null:
		plane = BdgPlane.XY
	var e := BdgEdge.make_ellipse(x_radius, y_radius, plane)
	var mk := OcgBRepBuilderAPIMakeWire.new()
	mk.add_g(e._wrapped)
	return BdgWire.new(mk.wire())

## Create a spline wire through points
static func make_spline(points: Array, periodic: bool = false) -> BdgWire:
	var e := BdgEdge.make_spline(points)
	var mk := OcgBRepBuilderAPIMakeWire.new()
	mk.add_g(e._wrapped)
	return BdgWire.new(mk.wire())

## Create a bezier wire through control points
static func make_bezier(control_points: Array) -> BdgWire:
	var e := BdgEdge.make_bezier(control_points)
	var mk := OcgBRepBuilderAPIMakeWire.new()
	mk.add_g(e._wrapped)
	return BdgWire.new(mk.wire())

## Create a helix wire (see BdgEdge.make_helix for arguments)
static func make_helix(
	pitch: float,
	height: float,
	radius: float,
	center: Vector3 = Vector3.ZERO,
	normal: Vector3 = Vector3.BACK,
	angle: float = 0.0,
	lefthand: bool = false,
) -> BdgWire:
	var e := BdgEdge.make_helix(pitch, height, radius, center, normal, angle, lefthand)
	var mk := OcgBRepBuilderAPIMakeWire.new()
	mk.add_g(e._wrapped)
	return BdgWire.new(mk.wire())

## Combine a list of edges into wires (connected chains).
## Returns an array of BdgWire.
static func combine(edges: Array) -> Array:
	var wires: Array = []
	var remaining := edges.duplicate()
	while not remaining.is_empty():
		var start := remaining.pop_front()
		var mk := OcgBRepBuilderAPIMakeWire.new()
		mk.add_g(start._wrapped)
		var progressed := true
		while progressed and not remaining.is_empty():
			progressed = false
			var partial := BdgWire.new(mk.wire())
			var tail: Vector3 = partial._edge_tail()
			var head: Vector3 = partial._edge_head()
			for i in remaining.size():
				var e: BdgEdge = remaining[i]
				if _points_equal(e.start_point(), tail) or _points_equal(e.end_point(), tail):
					var edge_to_add: BdgEdge = e if _points_equal(e.start_point(), tail) else BdgEdge.new(e.reversed()._wrapped)
					mk.add_g(edge_to_add._wrapped)
					remaining.remove_at(i)
					progressed = true
					break
				elif _points_equal(e.end_point(), head) or _points_equal(e.start_point(), head):
					var edge_to_add: BdgEdge = e if _points_equal(e.end_point(), head) else BdgEdge.new(e.reversed()._wrapped)
					var new_mk := OcgBRepBuilderAPIMakeWire.new()
					new_mk.add_g(edge_to_add._wrapped)
					var tail_edges := BdgWire.new(mk.wire()).edges()
					for te in tail_edges:
						new_mk.add_g(te._wrapped)
					mk = new_mk
					remaining.remove_at(i)
					progressed = true
					break
		var w := mk.wire()
		if not w.is_null():
			wires.append(BdgWire.new(w))
	return wires

## 2D fillet of planar wire corners (straight-line edges only).
## vertices: Array of Vector3 (or BdgVertex) corners to fillet; empty = all corners.
## Returns a new BdgWire (or self if nothing to do / on error).
func fillet_2d(radius: float, vertices: Array = [], plane: BdgPlane = null) -> BdgWire:
	if radius <= 0.0:
		push_error("fillet_2d radius must be positive")
		return self
	var chain := _ordered_points_edges()
	var pts: Array = chain[0]
	var es: Array = chain[1]
	if pts.size() < 3:
		push_error("fillet_2d needs at least a 3-corner wire")
		return self
	if plane == null:
		plane = _fit_plane(pts)
	var n := pts.size()
	var is_loop := es.size() == n

	var fillet_flags := {}
	if vertices.is_empty():
		for i in n:
			fillet_flags[i] = true
	else:
		for v in vertices:
			var vp: Vector3 = v if v is Vector3 else v.center()
			var idx := -1
			var best_d := 1e9
			for i in n:
				var d: float = pts[i].distance_to(vp)
				if d < best_d:
					best_d = d
					idx = i
			if idx >= 0 and best_d < 1e-3:
				fillet_flags[idx] = true
	if not is_loop:
		fillet_flags.erase(0)
		fillet_flags.erase(n - 1)

	var t1 := {}
	var t2 := {}
	var arc_edges: Array = []
	for i in n:
		if not fillet_flags.has(i):
			continue
		# open wires: only interior points are real corners
		if not is_loop and (i == 0 or i == n - 1):
			continue
		var prev: Vector3 = pts[(i - 1 + n) % n] if is_loop else pts[i - 1]
		var cur: Vector3 = pts[i]
		var nxt: Vector3 = pts[(i + 1) % n] if is_loop else pts[i + 1]
		var e_prev: BdgEdge = es[(i - 1 + n) % n] if is_loop else es[i - 1]
		var e_next: BdgEdge = es[i]
		if e_prev.geom_type() != BdgEnums.GeomType.LINE or e_next.geom_type() != BdgEnums.GeomType.LINE:
			push_warning("fillet_2d only supports straight-line corners; skipping")
			continue
		var u1 := (cur - prev).normalized()
		var u2 := (nxt - cur).normalized()
		var phi := acos(clampf(-u1.dot(u2), -1.0, 1.0))
		if phi < 1e-4:
			continue
		var half := phi / 2.0
		var center := cur + (-u1 + u2).normalized() * (radius / sin(half))
		var L := radius / tan(half)
		var tp1 := cur - u1 * L
		var tp2 := cur + u2 * L
		t1[i] = tp1
		t2[i] = tp2
		var dx := plane.x_dir
		var dy := plane.y_dir
		var a1 := atan2((tp1 - center).dot(dy), (tp1 - center).dot(dx))
		var a2 := atan2((tp2 - center).dot(dy), (tp2 - center).dot(dx))
		var d := a2 - a1
		while d > PI:
			d -= 2.0 * PI
		while d < -PI:
			d += 2.0 * PI
		if absf(d) < 1e-6:
			continue
		arc_edges.append(BdgEdge.make_center_arc(center, radius, rad_to_deg(a1), rad_to_deg(d), plane))

	var seg_edges: Array = []
	var seg_count := n if is_loop else n - 1
	for i in seg_count:
		var from_p: Vector3 = t2[i] if fillet_flags.has(i) else pts[i]
		var to_p: Vector3 = t1[(i + 1) % n] if fillet_flags.has((i + 1) % n) else pts[(i + 1) % n]
		if from_p.distance_to(to_p) > 1e-7:
			seg_edges.append(BdgEdge.make_line(from_p, to_p))

	var all_edges := seg_edges + arc_edges
	if all_edges.is_empty():
		return self
	var wires := BdgWire.combine(all_edges)
	return wires[0] if not wires.is_empty() else self

## Order the wire edges into a closed chain. Returns [points, edges] where
## edges[i] runs exactly from points[i] to points[(i+1) % n].
func _ordered_points_edges() -> Array:
	var es := edges()
	if es.is_empty():
		return [[], []]
	var start: BdgEdge = es[0]
	var pts := [start.start_point(), start.end_point()]
	var ordered := [start]
	var remaining := es.slice(1)
	var cur_end := start.end_point()
	while not remaining.is_empty():
		var found := false
		for i in remaining.size():
			var e: BdgEdge = remaining[i]
			if _points_equal(e.start_point(), cur_end):
				pts.append(e.end_point())
				cur_end = e.end_point()
				ordered.append(e)
				remaining.remove_at(i)
				found = true
				break
			elif _points_equal(e.end_point(), cur_end):
				pts.append(e.start_point())
				cur_end = e.start_point()
				ordered.append(BdgEdge.new(e.reversed()._wrapped))
				remaining.remove_at(i)
				found = true
				break
		if not found:
			break
	if pts.size() > 1 and _points_equal(pts[0], pts[pts.size() - 1]):
		pts.pop_back()
	return [pts, ordered]

## Fit a plane to the first non-collinear triple of points
static func _fit_plane(pts: Array) -> BdgPlane:
	var p0: Vector3 = pts[0]
	for i in range(1, pts.size() - 1):
		var a: Vector3 = pts[i] - p0
		var b: Vector3 = pts[i + 1] - p0
		var z: Vector3 = a.cross(b)
		if z.length() > 1e-9:
			var pl := BdgPlane.new()
			pl.origin = p0
			pl.x_dir = a.normalized()
			pl.z_dir = z.normalized()
			pl.y_dir = pl.z_dir.cross(pl.x_dir)
			return pl
	return BdgPlane.XY

static func _points_equal(a: Vector3, b: Vector3) -> bool:
	return a.distance_to(b) < 1e-6

func _edge_tail() -> Vector3:
	var es := edges()
	return es[es.size() - 1].end_point() if not es.is_empty() else Vector3.ZERO

func _edge_head() -> Vector3:
	var es := edges()
	return es[0].start_point() if not es.is_empty() else Vector3.ZERO

## Is this wire closed (a loop)?
func is_manifold() -> bool:
	return is_closed()
