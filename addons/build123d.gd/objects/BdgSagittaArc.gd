extends BdgLineObject
## BdgSagittaArc - Line Object: Sagitta Arc
## Create a circular arc defined by two points and the sagitta (arc height from chord).
class_name BdgSagittaArc

var start_point: Vector3
var end_point: Vector3
var sagitta: float

## Args: start_point, end_point (Vector3 | Array), sagitta, mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var mode := BdgEnums.Mode.ADD
	start_point = _to_v3(args[0])
	end_point = _to_v3(args[1])
	sagitta = args[2]
	if args.size() > 3 and args[3] != null:
		mode = args[3]
	var edge := BdgEdge.make_sagitta_arc(start_point, end_point, sagitta)
	if edge == null:
		return
	_wrapped = edge._wrapped
	_register(mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	push_error("BdgSagittaArc: invalid point %s" % p)
	return Vector3.ZERO
