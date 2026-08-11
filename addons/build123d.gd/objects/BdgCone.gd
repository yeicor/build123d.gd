extends BdgPartObject
## BdgCone - Part Object: Cone
## Create a cone defined by bottom radius, top radius, and height.
class_name BdgCone

var bottom_radius: float
var top_radius: float
var height: float
var arc_size: float

## Args: bottom_radius, top_radius, height, arc_size (deg, default 360),
##       rotation: Vector3 = ZERO, align: BdgEnums.Align | Array[int] = CENTER*3,
##       mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := Vector3.ZERO
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	bottom_radius = args[0]
	top_radius = args[1]
	height = args[2]
	arc_size = args[3] if args.size() > 3 and args[3] != null else 360.0
	if args.size() > 4 and args[4] != null:
		rotation = BdgBox._as_rotation(args[4])
	if args.size() > 5 and args[5] != null:
		align = args[5]
	if args.size() > 6 and args[6] != null:
		mode = args[6]
	var solid := BdgSolid.make_cone(bottom_radius, top_radius, height, BdgPlane.XY, arc_size)
	_from_solid(solid, rotation, align, mode)
