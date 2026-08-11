extends BdgLineObject
## BdgSpline - Line Object: Spline
## Create a spline interpolating through a sequence of points.
class_name BdgSpline

var points: Array

## Args: points (Array of Vector3 | Array, possibly nested), mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var mode := BdgEnums.Mode.ADD
	if args.is_empty():
		push_error("BdgSpline requires points")
		return
	var pts: Array = args[0]
	if args.size() > 1 and args[1] != null:
		mode = args[1]
	var edge := BdgEdge.make_spline(_flatten(pts))
	_wrapped = edge._wrapped
	_register(mode)

func _flatten(pts: Array) -> Array:
	var out: Array = []
	for p in pts:
		if p is Array:
			out.append_array(_flatten(p))
		else:
			out.append(_to_v3(p))
	return out

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	push_error("BdgSpline: invalid point %s" % p)
	return Vector3.ZERO
