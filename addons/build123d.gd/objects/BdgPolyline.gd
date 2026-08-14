extends BdgLineObject
## BdgPolyline - Line Object: Polyline
## Create a series of connected straight line segments through points.
class_name BdgPolyline

var points: Array[Vector3] = []
var is_closed_polyline: bool = false

## Args:
##   (points: Array[Vector3], close: bool = false, mode: Mode = ADD)
##   (*pts: Vector3, close: bool = false, mode: Mode = ADD)
func _init(...args) -> void:
	super()
	var mode := BdgEnums.Mode.ADD
	var pts: Array[Vector3] = []
	var close := false

	if args.size() == 1 and args[0] is Array:
		for p in args[0]:
			pts.append(_to_v3(p))
	elif args.size() >= 2 and args[0] is Array:
		for p in args[0]:
			pts.append(_to_v3(p))
		if args[1] is bool:
			close = args[1]
		if args.size() > 2 and args[2] != null:
			mode = args[2]
	else:
		# Multiple arguments passed directly
		var i := 0
		while i < args.size():
			if args[i] is Vector3:
				pts.append(args[i])
			elif args[i] is Array and (args[i] as Array).size() >= 3 and (args[i][0] is float or args[i][0] is int):
				pts.append(_to_v3(args[i]))
			elif args[i] is bool:
				close = args[i]
			elif args[i] is int:
				mode = args[i]
			i += 1

	if pts.size() < 2:
		push_error("BdgPolyline requires at least 2 points")
		return

	points = pts
	is_closed_polyline = close

	var edges: Array = []
	for j in range(pts.size() - 1):
		edges.append(BdgEdge.make_line(pts[j], pts[j + 1]))
	if close and pts[0].distance_to(pts[-1]) > 1e-6:
		edges.append(BdgEdge.make_line(pts[-1], pts[0]))

	var compound := BdgShape.make_compound_of(edges)
	_wrapped = compound._wrapped
	_register(mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	push_error("BdgPolyline: invalid point %s" % str(p))
	return Vector3.ZERO
