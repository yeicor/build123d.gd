extends BdgLineObject
## BdgBezier - Line Object: Bezier
## Create a bezier curve through control points (optionally rational with weights).
class_name BdgBezier

var control_points: Array
var weights: Array

## Args: control_points (Array of Vector3 | Array), weights (Array of float, optional),
##       mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var mode := BdgEnums.Mode.ADD
	if args.is_empty():
		push_error("BdgBezier requires control points")
		return
	var pts: Array = args[0]
	var wts: Array = args[1] if args.size() > 1 and args[1] != null else []
	var md_arg := 2 if args.size() > 2 else -1
	if md_arg != -1 and args[md_arg] != null:
		mode = args[md_arg]
	var edge := BdgEdge.make_bezier(_to_v3_array(pts), wts)
	if edge == null:
		return
	_wrapped = edge._wrapped
	_register(mode)

func _to_v3_array(pts: Array) -> Array:
	var out: Array = []
	for p in pts:
		out.append(_to_v3(p))
	return out

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	push_error("BdgBezier: invalid point %s" % p)
	return Vector3.ZERO
