extends BdgLineObject
## BdgJernArc - Line Object: Jern Arc
## Create a circular arc from a start point, initial tangent direction, radius, and arc sweep (degrees).
class_name BdgJernArc

var start_point: Vector3
var tangent: Vector3
var radius: float
var arc_size: float

## Args:
##   (start: Vector3, tangent: Vector3, radius: float, arc_size: float, plane: BdgPlane = null, mode: Mode = ADD)
func _init(...args) -> void:
	super()
	var mode := BdgEnums.Mode.ADD
	var st := Vector3.ZERO
	var tg := Vector3.RIGHT
	var r := 1.0
	var size := 90.0
	var pl: BdgPlane = null

	if args.size() >= 4:
		st = _to_v3(args[0])
		tg = _to_v3(args[1])
		r = float(args[2])
		size = float(args[3])
		if args.size() > 4 and args[4] != null:
			pl = args[4]
		if args.size() > 5 and args[5] != null:
			mode = args[5]
	else:
		push_error("BdgJernArc: expected (start, tangent, radius, arc_size, ...)")
		return

	start_point = st
	tangent = tg
	radius = r
	arc_size = size

	var edge := BdgEdge.make_jern_arc(st, tg, r, size, pl)
	if edge != null:
		_wrapped = edge._wrapped
	_register(mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	return Vector3.ZERO
