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

## Is this wire closed (a loop)?
func is_manifold() -> bool:
	return is_closed()
