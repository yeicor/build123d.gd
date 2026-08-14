extends BdgSketchObject
## BdgSuperellipse - Sketch Object: Superellipse (Lamé curve / Squircle)
## Create a superellipse face defined by x_radius, y_radius, and power exponent.
class_name BdgSuperellipse

var x_radius: float
var y_radius: float
var exponent: float

## Args:
##   (x_radius: float, y_radius: float, exponent: float, count: int = 120, rotation: float = 0.0, align: Align = CENTER, mode: Mode = ADD)
func _init(...args) -> void:
	super()
	if args.size() < 3:
		push_error("BdgSuperellipse: expected (x_radius, y_radius, exponent, ...)")
		return

	x_radius = float(args[0])
	y_radius = float(args[1])
	exponent = float(args[2])

	var count := 120
	var rot := 0.0
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var md := BdgEnums.Mode.ADD

	if args.size() > 3 and args[3] != null:
		count = int(args[3])
	if args.size() > 4 and args[4] != null:
		rot = float(args[4])
	if args.size() > 5 and args[5] != null:
		align = args[5]
	if args.size() > 6 and args[6] != null:
		md = int(args[6])

	var p := 2.0 / exponent
	var pts: Array[Vector3] = []
	for i in count:
		var t := float(i) * 2.0 * PI / float(count)
		var ct := cos(t)
		var st := sin(t)
		var x := signf(ct) * x_radius * pow(absf(ct), p)
		var y := signf(st) * y_radius * pow(absf(st), p)
		pts.append(Vector3(x, y, 0.0))

	var wire := BdgWire.make_spline(pts, true)
	if wire == null or not wire.is_closed():
		wire = BdgWire.make_polygon(pts, true)

	var face := BdgFace.make_from_wires(wire)
	_from_face(face, rot, align, md)
