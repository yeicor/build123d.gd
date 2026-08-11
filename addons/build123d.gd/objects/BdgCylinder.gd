extends BdgPartObject
## BdgCylinder - Part Object: Cylinder
## Create a cylinder with a given radius and height. Defaults to centered at the origin.
class_name BdgCylinder

var radius: float
var height: float
var arc_size: float

## Args: radius, height, arc_size (deg, default 360), rotation: Vector3 = ZERO,
##       align: BdgEnums.Align | Array[int] = CENTER*3, mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := Vector3.ZERO
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	radius = args[0]
	height = args[1]
	arc_size = args[2] if args.size() > 2 and args[2] != null else 360.0
	if args.size() > 3 and args[3] != null:
		rotation = BdgBox._as_rotation(args[3])
	if args.size() > 4 and args[4] != null:
		align = args[4]
	if args.size() > 5 and args[5] != null:
		mode = args[5]
	var solid := BdgSolid.make_cylinder(radius, height, BdgPlane.XY, arc_size)
	_from_solid(solid, rotation, align, mode)
