extends BdgLineObject
## BdgThreePointArc - Line Object: Three Point Arc
## Create a circular arc defined by three points.
class_name BdgThreePointArc

var point1: Vector3
var point2: Vector3
var point3: Vector3

## Args: point1, point2, point3 (Vector3 | Array), mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var mode := BdgEnums.Mode.ADD
	point1 = _to_v3(args[0])
	point2 = _to_v3(args[1])
	point3 = _to_v3(args[2])
	if args.size() > 3 and args[3] != null:
		mode = args[3]
	var edge := BdgEdge.make_three_point_arc(point1, point2, point3)
	_wrapped = edge._wrapped
	_register(mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	push_error("BdgThreePointArc: invalid point %s" % p)
	return Vector3.ZERO
