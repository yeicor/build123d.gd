extends BdgPartObject
## BdgCounterSinkHole - Part Object: Countersunk Hole
## Create a countersunk conical hole for flathead screws.
class_name BdgCounterSinkHole

var radius: float
var depth: float
var counter_sink_radius: float
var counter_sink_angle: float

## Args: radius: float, depth: float, counter_sink_radius: float, counter_sink_angle: float = 90.0, mode: Mode = SUBTRACT
func _init(...args) -> void:
	super()
	if args.size() < 3:
		push_error("BdgCounterSinkHole: expected (radius, depth, counter_sink_radius)")
		return

	var r: float = float(args[0])
	var d: float = float(args[1])
	var cs_r: float = float(args[2])
	var cs_ang: float = 90.0
	var md: int = BdgEnums.Mode.SUBTRACT

	if args.size() > 3 and args[3] != null:
		cs_ang = float(args[3])
	if args.size() > 4 and args[4] != null:
		md = int(args[4])

	radius = r
	depth = d
	counter_sink_radius = cs_r
	counter_sink_angle = cs_ang

	var cs_height := (cs_r - r) / tan(deg_to_rad(cs_ang * 0.5))

	var main_hole := BdgSolid.make_cylinder(r, d)
	var cone := BdgSolid.make_cone(r, cs_r, cs_height).translate(Vector3(0, 0, d - cs_height))
	var solid := main_hole.fuse(cone)

	_from_solid(solid, Vector3.ZERO, [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.CENTER], md)
