extends BdgPartObject
## BdgTorus - Part Object: Torus
## Create a torus with major and minor radii. Defaults to centered at the origin.
class_name BdgTorus

var major_radius: float
var minor_radius: float
var start_angle: float
var end_angle: float
var major_angle: float

## Args: major_radius, minor_radius, start_angle (deg, default 0), end_angle (deg, default 360),
##       major_angle (deg, default 360), rotation: Vector3 = ZERO,
##       align: BdgEnums.Align | Array[int] = CENTER*3, mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := Vector3.ZERO
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	major_radius = args[0]
	minor_radius = args[1]
	start_angle = args[2] if args.size() > 2 and args[2] != null else 0.0
	end_angle = args[3] if args.size() > 3 and args[3] != null else 360.0
	major_angle = args[4] if args.size() > 4 and args[4] != null else 360.0
	if args.size() > 5 and args[5] != null:
		rotation = BdgBox._as_rotation(args[5])
	if args.size() > 6 and args[6] != null:
		align = args[6]
	if args.size() > 7 and args[7] != null:
		mode = args[7]
	var solid := BdgSolid.make_torus(
		major_radius, minor_radius, BdgPlane.XY, start_angle, end_angle, major_angle
	)
	_from_solid(solid, rotation, align, mode)
