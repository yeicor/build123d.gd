extends BdgPartObject
## BdgSocketHeadCapScrew - Part Object: Socket Head Cap Screw (SHCS)
## Create a socket head cap screw with cylindrical head and hexagonal socket.
class_name BdgSocketHeadCapScrew

var thread_radius: float
var length: float
var head_radius: float
var head_height: float
var socket_size: float

## Args: thread_radius: float, length: float, head_radius: float = 0.0, head_height: float = 0.0, socket_size: float = 0.0, mode: Mode = ADD
func _init(...args) -> void:
	super()
	if args.size() < 2:
		push_error("BdgSocketHeadCapScrew: expected (thread_radius, length)")
		return

	var r: float = float(args[0])
	var l: float = float(args[1])
	var hr: float = r * 1.5
	var hh: float = r * 2.0
	var ss: float = r * 1.6 # socket hex across-flats
	var md: int = BdgEnums.Mode.ADD

	if args.size() > 2 and args[2] != null and float(args[2]) > 0.0:
		hr = float(args[2])
	if args.size() > 3 and args[3] != null and float(args[3]) > 0.0:
		hh = float(args[3])
	if args.size() > 4 and args[4] != null and float(args[4]) > 0.0:
		ss = float(args[4])
	if args.size() > 5 and args[5] != null:
		md = int(args[5])

	thread_radius = r
	length = l
	head_radius = hr
	head_height = hh
	socket_size = ss

	var head_cyl := BdgSolid.make_cylinder(hr, hh)
	var hex_socket := BdgFace.make_regular_polygon(ss * 0.5 / cos(PI / 6.0), 6).extrude(Vector3(0, 0, hh * 0.6 + 0.1)).translate(Vector3(0, 0, hh * 0.4))
	var head := head_cyl.cut(hex_socket)
	var shank := BdgSolid.make_cylinder(r, l).translate(Vector3(0, 0, -l))
	var screw := head.fuse(shank)

	_from_solid(screw, Vector3.ZERO, [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.NONE], md)
