extends BdgPartObject
## BdgSphere - Part Object: Sphere
## Create a sphere with a given radius. Defaults to centered at the origin.
class_name BdgSphere

var radius: float
var arc_size1: float
var arc_size2: float
var arc_size3: float

## Args: radius, arc_size1 (deg, default -90), arc_size2 (deg, default 90),
##       arc_size3 (deg, default 360), rotation: Vector3 = ZERO,
##       align: BdgEnums.Align | Array[int] = CENTER*3, mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := Vector3.ZERO
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	radius = args[0]
	arc_size1 = args[1] if args.size() > 1 and args[1] != null else -90.0
	arc_size2 = args[2] if args.size() > 2 and args[2] != null else 90.0
	arc_size3 = args[3] if args.size() > 3 and args[3] != null else 360.0
	if args.size() > 4 and args[4] != null:
		rotation = BdgBox._as_rotation(args[4])
	if args.size() > 5 and args[5] != null:
		align = args[5]
	if args.size() > 6 and args[6] != null:
		mode = args[6]
	var solid := BdgSolid.make_sphere(radius, BdgPlane.XY, arc_size1, arc_size2, arc_size3)
	_from_solid(solid, rotation, align, mode)
