extends BdgLineObject
## BdgCenterArc - Line Object: Center Arc
## Create a circular arc defined by a center point and radius.
class_name BdgCenterArc

var center_point: Vector3
var radius: float

## Args: center (Vector3 | Array), radius, start_angle (deg, default 0),
##       arc_size (deg, default 360, positive = CCW), mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var start_angle := 0.0
	var arc_size := 360.0
	var mode := BdgEnums.Mode.ADD
	center_point = _to_v3(args[0])
	radius = args[1]
	if args.size() > 2 and args[2] != null:
		start_angle = args[2]
	if args.size() > 3 and args[3] != null:
		arc_size = args[3]
	if args.size() > 4 and args[4] != null:
		mode = args[4]
	var edge := BdgEdge.make_center_arc(center_point, radius, start_angle, arc_size)
	_wrapped = edge._wrapped
	_register(mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	push_error("BdgCenterArc: invalid center %s" % p)
	return Vector3.ZERO
