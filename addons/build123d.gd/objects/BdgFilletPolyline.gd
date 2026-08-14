extends BdgLineObject
## BdgFilletPolyline - Line Object: Fillet Polyline
## Create a polyline with filleted corners of a given radius.
class_name BdgFilletPolyline

var points: Array[Vector3] = []
var radius: float = 0.0
var is_closed_polyline: bool = false

## Args:
##   (points: Array[Vector3], radius: float, close: bool = false, mode: Mode = ADD)
func _init(...args) -> void:
	super()
	var mode := BdgEnums.Mode.ADD
	var pts: Array[Vector3] = []
	var r := 0.0
	var close := false

	if args.size() >= 2 and args[0] is Array:
		for p in args[0]:
			pts.append(BdgPolyline._to_v3(p))
		r = float(args[1])
		if args.size() > 2 and args[2] is bool:
			close = args[2]
		if args.size() > 3 and args[3] != null:
			mode = args[3]
	else:
		push_error("BdgFilletPolyline: expected (points: Array, radius: float, ...)")
		return

	if pts.size() < 3:
		push_error("BdgFilletPolyline requires at least 3 points")
		return

	points = pts
	radius = r
	is_closed_polyline = close

	var wire := BdgWire.make_polygon(pts, close)
	if wire == null:
		push_error("BdgFilletPolyline: failed to create base polygon")
		return

	var filleted := wire.fillet_2d(r)
	if filleted != null:
		_wrapped = filleted._wrapped
	else:
		_wrapped = wire._wrapped

	_register(mode)
