extends BdgPartObject
## BdgHexNut - Part Object: Hexagonal Nut
## Create an ISO/DIN standard hexagonal nut with central threaded bore hole.
class_name BdgHexNut

var thread_radius: float
var width: float
var height: float

## Args: thread_radius: float, width: float = 0.0, height: float = 0.0, mode: Mode = ADD
func _init(...args) -> void:
	super()
	if args.is_empty():
		return

	var r: float = float(args[0])
	var w: float = r * 3.4 # across flats
	var h: float = r * 1.6 # thickness
	var md: int = BdgEnums.Mode.ADD

	if args.size() > 1 and args[1] != null and float(args[1]) > 0.0:
		w = float(args[1])
	if args.size() > 2 and args[2] != null and float(args[2]) > 0.0:
		h = float(args[2])
	if args.size() > 3 and args[3] != null:
		md = int(args[3])

	thread_radius = r
	width = w
	height = h

	var outer_hex := BdgFace.make_regular_polygon(w * 0.5 / cos(PI / 6.0), 6).extrude(Vector3(0, 0, h))
	var bore := BdgSolid.make_cylinder(r, h + 2.0).translate(Vector3(0, 0, -1.0))
	var nut := outer_hex.cut(bore)

	_from_solid(nut, Vector3.ZERO, [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.CENTER], md)
