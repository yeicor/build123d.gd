extends BdgPartObject
## BdgBox - Part Object: Box
## Create a box defined by length, width, and height. Defaults to centered at the origin.
class_name BdgBox

var length: float
var width: float
var box_height: float

## Args: length, width, height, rotation: Vector3 (Euler deg) = ZERO,
##       align: BdgEnums.Align | Array[int] = CENTER*3, mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := Vector3.ZERO
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	length = args[0]
	width = args[1]
	box_height = args[2]
	if args.size() > 3 and args[3] != null:
		rotation = _as_rotation(args[3])
	if args.size() > 4 and args[4] != null:
		align = args[4]
	if args.size() > 5 and args[5] != null:
		mode = args[5]
	var solid := BdgSolid.make_box(length, width, box_height)
	_from_solid(solid, rotation, align, mode)

static func _as_rotation(r: Variant) -> Vector3:
	if r is Vector3:
		return r
	if r is Array:
		return Vector3(float(r[0]), float(r[1]), float(r[2]))
	return Vector3.ZERO
