extends BdgLineObject
## BdgRadiusArc - Line Object: Radius Arc
## Create a circular arc defined by two points and a radius.
class_name BdgRadiusArc

var start_point: Vector3
var end_point: Vector3
var radius: float

## Args: start_point, end_point (Vector3 | Array), radius,
##       short_sagitta (bool, default true), mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var short_sagitta := true
	var mode := BdgEnums.Mode.ADD
	start_point = _to_v3(args[0])
	end_point = _to_v3(args[1])
	radius = args[2]
	if args.size() > 3 and args[3] != null:
		short_sagitta = args[3]
	if args.size() > 4 and args[4] != null:
		mode = args[4]
	var edge := BdgEdge.make_radius_arc(start_point, end_point, radius, short_sagitta)
	if edge == null:
		return
	_wrapped = edge._wrapped
	_register(mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	push_error("BdgRadiusArc: invalid point %s" % p)
	return Vector3.ZERO
