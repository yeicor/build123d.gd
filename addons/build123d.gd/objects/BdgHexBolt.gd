extends BdgPartObject
## BdgHexBolt - Part Object: Hex Head Bolt / Screw
## Create a hexagonal head bolt with shank.
class_name BdgHexBolt

var thread_radius: float
var length: float
var head_width: float
var head_height: float

## Args: thread_radius: float, length: float, head_width: float = 0.0, head_height: float = 0.0, mode: Mode = ADD
func _init(...args) -> void:
	super()
	if args.size() < 2:
		push_error("BdgHexBolt: expected (thread_radius, length)")
		return

	var r: float = float(args[0])
	var l: float = float(args[1])
	var hw: float = r * 3.4 # standard ISO hex bolt across-flats width
	var hh: float = r * 1.3 # standard head height
	var md: int = BdgEnums.Mode.ADD

	if args.size() > 2 and args[2] != null and float(args[2]) > 0.0:
		hw = float(args[2])
	if args.size() > 3 and args[3] != null and float(args[3]) > 0.0:
		hh = float(args[3])
	if args.size() > 4 and args[4] != null:
		md = int(args[4])

	thread_radius = r
	length = l
	head_width = hw
	head_height = hh

	var hex_head := BdgFace.make_regular_polygon(hw * 0.5 / cos(PI / 6.0), 6).extrude(Vector3(0, 0, hh))
	var shank := BdgSolid.make_cylinder(r, l).translate(Vector3(0, 0, -l))
	var bolt := hex_head.fuse(shank)

	_from_solid(bolt, Vector3.ZERO, [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.NONE], md)
