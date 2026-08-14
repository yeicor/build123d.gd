extends BdgLineObject
## BdgDoubleTangentArc - Line Object: Double Tangent Arc
## Create a smooth curve tangent to both the start and end tangent directions.
class_name BdgDoubleTangentArc

var point1: Vector3
var tangent1: Vector3
var point2: Vector3
var tangent2: Vector3

## Args:
##   (point1: Vector3, tangent1: Vector3, point2: Vector3, tangent2: Vector3, mode: Mode = ADD)
func _init(...args) -> void:
	super()
	var mode := BdgEnums.Mode.ADD
	if args.size() >= 4:
		point1 = _to_v3(args[0])
		tangent1 = _to_v3(args[1])
		point2 = _to_v3(args[2])
		tangent2 = _to_v3(args[3])
		if args.size() > 4 and args[4] != null:
			mode = args[4]
	else:
		push_error("BdgDoubleTangentArc: expected (point1, tangent1, point2, tangent2)")
		return

	var edge := BdgEdge.make_double_tangent_arc(point1, tangent1, point2, tangent2)
	if edge != null:
		_wrapped = edge._wrapped
	_register(mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	push_error("BdgDoubleTangentArc: invalid point %s" % str(p))
	return Vector3.ZERO
