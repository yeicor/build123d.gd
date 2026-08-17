extends BdgMixin1D
## BdgWire - a closed or open sequence of connected edges, wrapping OcgTopoDSWire.
## Mirrors build123d/topology/one_d.py Wire.
class_name BdgWire

func _init(...args) -> void:
	super(args[0] if args.size() == 1 else null)

## Create a wire from a list of edges/wires (must share endpoints)
static func make_wire(edges: Array) -> BdgWire:
	var mk := OcgBRepBuilderAPIMakeWire.new()
	for obj in edges:
		if obj is BdgEdge:
			if obj._wrapped != null and not obj._wrapped.is_null():
				var te := OcgTopoDSShape.cast_edge(obj._wrapped)
				if te != null:
					mk.add_g(te)
		elif obj is BdgWire:
			if obj._wrapped != null and not obj._wrapped.is_null():
				var tw := OcgTopoDSShape.cast_wire(obj._wrapped)
				if tw != null:
					mk.add_I(tw)
		elif obj is BdgShape:
			for e in (obj as BdgShape).edges():
				if e._wrapped != null and not e._wrapped.is_null():
					var te := OcgTopoDSShape.cast_edge(e._wrapped)
					if te != null:
						mk.add_g(te)
	if mk.is_done():
		return BdgWire.new(mk.wire())
	return null

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

## Create a bspline wire from control points and knot data (see BdgEdge.make_bspline)
static func make_bspline(control_points: Array, knots: Array, degree: int = 3, periodic: bool = false) -> BdgWire:
	var e := BdgEdge.make_bspline(control_points, knots, degree, periodic)
	if e == null:
		return null
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
		if w != null and not w.is_null():
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
		var L := radius / tan(half)
		var tp1 := cur - u1 * L
		var tp2 := cur + u2 * L
		t1[i] = tp1
		t2[i] = tp2
		var arc := BdgEdge.make_tangent_arc(tp1, u1, tp2)
		if arc != null and not arc.is_null():
			arc_edges.append(arc)

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

## 2D chamfer of planar wire corners (straight-line edges only).
## length: distance cut back from the corner. length2: optional asymmetric distance.
func chamfer_2d(length: float, length2: float = 0.0, vertices: Array = [], plane: BdgPlane = null) -> BdgWire:
	if length <= 0.0:
		push_error("chamfer_2d length must be positive")
		return self
	var l1 := length
	var l2 := length2 if length2 > 0.0 else length
	var chain := _ordered_points_edges()
	var pts: Array = chain[0]
	var es: Array = chain[1]
	if pts.size() < 3:
		push_error("chamfer_2d needs at least a 3-corner wire")
		return self
	if plane == null:
		plane = _fit_plane(pts)
	var n := pts.size()
	var is_loop := es.size() == n

	var chamfer_flags := {}
	if vertices.is_empty():
		for i in n:
			chamfer_flags[i] = true
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
				chamfer_flags[idx] = true
	if not is_loop:
		chamfer_flags.erase(0)
		chamfer_flags.erase(n - 1)

	var t1 := {}
	var t2 := {}
	var chamfer_edges: Array = []
	for i in n:
		if not chamfer_flags.has(i):
			continue
		if not is_loop and (i == 0 or i == n - 1):
			continue
		var prev: Vector3 = pts[(i - 1 + n) % n] if is_loop else pts[i - 1]
		var cur: Vector3 = pts[i]
		var nxt: Vector3 = pts[(i + 1) % n] if is_loop else pts[i + 1]
		var e_prev: BdgEdge = es[(i - 1 + n) % n] if is_loop else es[i - 1]
		var e_next: BdgEdge = es[i]
		if e_prev.geom_type() != BdgEnums.GeomType.LINE or e_next.geom_type() != BdgEnums.GeomType.LINE:
			push_warning("chamfer_2d only supports straight-line corners; skipping")
			continue
		var u1 := (cur - prev).normalized()
		var u2 := (nxt - cur).normalized()
		var tp1 := cur - u1 * l1
		var tp2 := cur + u2 * l2
		t1[i] = tp1
		t2[i] = tp2
		chamfer_edges.append(BdgEdge.make_line(tp1, tp2))

	var seg_edges: Array = []
	var seg_count := n if is_loop else n - 1
	for i in seg_count:
		var from_p: Vector3 = t2[i] if chamfer_flags.has(i) else pts[i]
		var to_p: Vector3 = t1[(i + 1) % n] if chamfer_flags.has((i + 1) % n) else pts[(i + 1) % n]
		if from_p.distance_to(to_p) > 1e-7:
			seg_edges.append(BdgEdge.make_line(from_p, to_p))

	var all_edges := seg_edges + chamfer_edges
	if all_edges.is_empty():
		return self
	var wires := BdgWire.combine(all_edges)
	return wires[0] if not wires.is_empty() else self

## Close this wire by adding an edge from its end point to its start point if open.
func close() -> BdgWire:
	if is_closed():
		return self
	var es := edges()
	if es.is_empty():
		return self
	var head: Vector3 = _edge_head()
	var tail: Vector3 = _edge_tail()
	if head.distance_to(tail) > 1e-6:
		var closing_edge := BdgEdge.make_line(tail, head)
		es.append(closing_edge)
	var wires := BdgWire.combine(es)
	return wires[0] if not wires.is_empty() else self

## Return edges ordered end-to-end sequentially.
func order_edges() -> Array:
	var chain := _ordered_points_edges()
	return chain[1]

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

## Stitch degenerate wire edges into a clean wire
func stitch() -> BdgWire:
	var es := edges()
	var clean_es: Array = []
	for e in es:
		if e.length() > 1e-6:
			clean_es.append(e)
	var wires := combine(clean_es)
	return wires[0] if not wires.is_empty() else self

## Remove degenerate 0-length edges from wire
func fix_degenerate_edges() -> BdgWire:
	return stitch()

## Compute 2D convex hull wire of planar vertices
static func make_convex_hull(points: Array, plane: BdgPlane = null) -> BdgWire:
	var pts_2d: Array[Vector2] = []
	var p := plane if plane != null else BdgPlane.XY
	for pt in points:
		var v: Vector3 = pt if pt is Vector3 else pt.center()
		var loc := p.to_local_coords(v)
		pts_2d.append(Vector2(loc.x, loc.y))
	var hull_2d := Geometry2D.convex_hull(pts_2d)
	var hull_3d: Array = []
	for p2 in hull_2d:
		hull_3d.append(p.from_local_coords(Vector3(p2.x, p2.y, 0.0)))
	return make_polygon(hull_3d, true)

## Order edges for chamfering
func order_chamfer_edges() -> Array:
	return order_edges()

## Trim wire to parameter sub-range (0..1)
func trim(start_param: float, end_param: float) -> BdgWire:
	var es := edges()
	if es.is_empty():
		return self
	var total_len := length()
	if total_len == 0.0:
		return self
	var cur_dist := 0.0
	var target_start := start_param * total_len
	var target_end := end_param * total_len
	var trimmed_es: Array = []
	for e in es:
		var edge := e as BdgEdge
		var elen: float = edge.length()
		if cur_dist + elen >= target_start and cur_dist <= target_end:
			var e_start := clampf((target_start - cur_dist) / elen, 0.0, 1.0)
			var e_end := clampf((target_end - cur_dist) / elen, 0.0, 1.0)
			var sub_e: BdgEdge = edge.trim(e_start, e_end)
			if sub_e != null and not sub_e.is_null():
				trimmed_es.append(sub_e)
		cur_dist += elen
	var wires := combine(trimmed_es)
	return wires[0] if not wires.is_empty() else self



