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
