extends BdgPartObject
## BdgHole - Part Object: Hole
## Create a simple drilled hole (cylindrical subtractor).
class_name BdgHole

var radius: float
var depth: float

## Args: radius: float, depth: float = 100.0, mode: Mode = SUBTRACT
func _init(...args) -> void:
	super()
	if args.is_empty():
		return

	var r: float = float(args[0])
	var d: float = 100.0
	var md: int = BdgEnums.Mode.SUBTRACT
	var rot := Vector3.ZERO
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]

	if args.size() > 1 and args[1] != null:
		d = float(args[1])
	if args.size() > 2 and args[2] != null:
		md = int(args[2])

	radius = r
	depth = d

	var solid := BdgSolid.make_cylinder(r, d)
	_from_solid(solid, rot, align, md)
