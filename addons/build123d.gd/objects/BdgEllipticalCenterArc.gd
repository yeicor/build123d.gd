extends BdgLineObject
## BdgEllipticalCenterArc - Line Object: Elliptical Center Arc
## Create an elliptical arc defined by center, major/minor radii, start and end angles (degrees).
class_name BdgEllipticalCenterArc

var arc_center: Vector3
var x_radius: float
var y_radius: float
var start_angle: float
var end_angle: float

## Args:
##   (center: Vector3, x_radius: float, y_radius: float, start_angle: float = 0.0, end_angle: float = 90.0, plane: BdgPlane = null, mode: Mode = ADD)
func _init(...args) -> void:
	super()
	var mode := BdgEnums.Mode.ADD
	var cnt := Vector3.ZERO
	var xr := 1.0
	var yr := 1.0
	var a1 := 0.0
	var a2 := 90.0
	var pl: BdgPlane = null

	if args.size() >= 3:
		cnt = _to_v3(args[0])
		xr = float(args[1])
		yr = float(args[2])
		if args.size() > 3 and args[3] != null:
			a1 = float(args[3])
		if args.size() > 4 and args[4] != null:
			a2 = float(args[4])
		if args.size() > 5 and args[5] != null:
			pl = args[5]
		if args.size() > 6 and args[6] != null:
			mode = args[6]
	else:
		push_error("BdgEllipticalCenterArc: expected (center, x_radius, y_radius, ...)")
		return

	arc_center = cnt
	x_radius = xr
	y_radius = yr
	start_angle = a1
	end_angle = a2

	var edge := BdgEdge.make_elliptical_center_arc(cnt, xr, yr, a1, a2, pl)
	if edge != null:
		_wrapped = edge._wrapped
	_register(mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	return Vector3.ZERO
