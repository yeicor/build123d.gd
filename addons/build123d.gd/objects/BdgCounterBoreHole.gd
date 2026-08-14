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
	counter_bore_radius = float(args[1])
	counter_bore_depth = float(args[2])
	depth = 100.0
	var md: int = BdgEnums.Mode.SUBTRACT

	if args.size() > 3 and args[3] != null:
		if args[3] is int and args.size() == 4:
			md = int(args[3])
		else:
			depth = float(args[3])

	if args.size() > 4 and args[4] != null:
		md = int(args[4])

	# Counterbore top flush at Z=0 extending down to -counter_bore_depth
	var cb_hole := BdgSolid.make_cylinder(counter_bore_radius, counter_bore_depth).translate(Vector3(0, 0, -counter_bore_depth))
	# Shaft hole extending from Z=0 down to -depth
	var shaft_hole := BdgSolid.make_cylinder(radius, depth).translate(Vector3(0, 0, -depth))
	var solid := cb_hole.fuse(shaft_hole)

	_wrapped = solid.wrapped()
