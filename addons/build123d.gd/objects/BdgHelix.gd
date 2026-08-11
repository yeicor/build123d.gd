extends BdgLineObject
## BdgHelix - Line Object: Helix
## Create a helix curve wrapped around a cylinder (or cone when angle != 0).
class_name BdgHelix

var pitch: float
var height: float
var radius: float

## Args: pitch, height, radius, center (Vector3, default 0), normal (Vector3, default -Z),
##       angle (deg, default 0), lefthand (bool, default false), mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var center := Vector3.ZERO
	var normal := Vector3.BACK
	var angle := 0.0
	var lefthand := false
	var mode := BdgEnums.Mode.ADD
	pitch = args[0]
	height = args[1]
	radius = args[2]
	if args.size() > 3 and args[3] != null:
		center = _to_v3(args[3])
	if args.size() > 4 and args[4] != null:
		normal = _to_v3(args[4])
	if args.size() > 5 and args[5] != null:
		angle = args[5]
	if args.size() > 6 and args[6] != null:
		lefthand = args[6]
	if args.size() > 7 and args[7] != null:
		mode = args[7]
	var edge := BdgEdge.make_helix(pitch, height, radius, center, normal, angle, lefthand)
	_wrapped = edge._wrapped
	_register(mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	push_error("BdgHelix: invalid point %s" % p)
	return Vector3.ZERO
