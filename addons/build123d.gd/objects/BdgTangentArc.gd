extends BdgLineObject
## BdgTangentArc - Line Object: Tangent Arc
## Create a circular arc defined by two points and a start tangent.
class_name BdgTangentArc

var start_point: Vector3
var end_point: Vector3
var tangent: Vector3

## Args: start_point, tangent, end_point (Vector3 | Array), mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var mode := BdgEnums.Mode.ADD
	start_point = _to_v3(args[0])
	tangent = _to_v3(args[1])
	end_point = _to_v3(args[2])
	if args.size() > 3 and args[3] != null:
		mode = args[3]
	var edge := BdgEdge.make_tangent_arc(start_point, tangent, end_point)
	_wrapped = edge._wrapped
	_register(mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	push_error("BdgTangentArc: invalid point %s" % p)
	return Vector3.ZERO
