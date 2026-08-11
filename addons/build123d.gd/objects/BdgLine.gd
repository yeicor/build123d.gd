extends BdgLineObject
## BdgLine - Line Object: Line
## Create a straight line between two points. Points may be Vector3 or [x, y, z] arrays.
class_name BdgLine

## Args: point1 (Vector3 | Array), point2 (Vector3 | Array), mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var p1: Vector3 = _to_v3(args[0])
	var p2: Vector3 = _to_v3(args[1])
	var mode := BdgEnums.Mode.ADD
	if args.size() > 2 and args[2] != null:
		mode = args[2]
	var edge := BdgEdge.make_line(p1, p2)
	_wrapped = edge._wrapped
	_register(mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	push_error("BdgLine: invalid point %s" % p)
	return Vector3.ZERO
