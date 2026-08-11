extends BdgSketchObject
## BdgCircle - Sketch Object: Circle
## Create a circle with a given radius. Defaults to centered at origin.
class_name BdgCircle

var radius: float
var arc_size: float

## Args: radius, arc_size (deg, default 360),
##       align: BdgEnums.Align | Array[int] (2 axes, default CENTER*2),
##       mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := 0.0
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	radius = args[0]
	arc_size = args[1] if args.size() > 1 and args[1] != null else 360.0
	if args.size() > 2 and args[2] != null:
		align = args[2]
	if args.size() > 3 and args[3] != null:
		mode = args[3]
	var face := BdgFace.make_circle(radius)
	_from_face(face, rotation, align, mode)
