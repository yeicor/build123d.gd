extends BdgPartObject
## BdgCounterBoreHole - Part Object: Counterbore Hole
## Stepped counterbored hole for socket head screws extending downward along -Z from Z=0.
class_name BdgCounterBoreHole

var radius: float
var counter_bore_radius: float
var counter_bore_depth: float
var depth: float

## Args: radius, counter_bore_radius, counter_bore_depth, [depth=100.0, mode=SUBTRACT]
func _init(...args) -> void:
	super()
	if args.size() < 3:
		push_error("BdgCounterBoreHole: expected (radius, counter_bore_radius, counter_bore_depth)")
		return

	radius = float(args[0])
	depth = float(args[1])
	counter_bore_radius = float(args[2])
	counter_bore_depth = float(args[3]) if args.size() > 3 else 5.0
	var md: int = int(args[4]) if args.size() > 4 and args[4] != null else BdgEnums.Mode.SUBTRACT

	# Counterbore top flush at Z=0 extending down to -counter_bore_depth
	var cb_hole := BdgSolid.make_cylinder(counter_bore_radius, counter_bore_depth).translate(Vector3(0, 0, -counter_bore_depth))
	# Shaft hole extending from Z=0 down to -depth
	var shaft_hole := BdgSolid.make_cylinder(radius, depth).translate(Vector3(0, 0, -depth))
	var solid := cb_hole.fuse(shaft_hole)
	_from_solid(solid, Vector3.ZERO, BdgEnums.Align.NONE, md)

