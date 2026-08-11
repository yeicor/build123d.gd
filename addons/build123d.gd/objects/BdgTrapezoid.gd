extends BdgSketchObject
## BdgTrapezoid - Sketch Object: Trapezoid
## Create a trapezoid with a given width, height and side insets.
class_name BdgTrapezoid

var width: float
var trapezoid_height: float
var left_inset: float
var right_inset: float

## Args: width, height, left_inset, right_inset, rotation (deg about Z, default 0),
##       align: BdgEnums.Align | Array[int] (2 axes, default CENTER*2),
##       mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := 0.0
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	width = args[0]
	trapezoid_height = args[1]
	left_inset = args[2]
	right_inset = args[3]
	if args.size() > 4 and args[4] != null:
		rotation = args[4]
	if args.size() > 5 and args[5] != null:
		align = args[5]
	if args.size() > 6 and args[6] != null:
		mode = args[6]
	var face := BdgFace.make_trapezoid(width, trapezoid_height, left_inset, right_inset)
	_from_face(face, rotation, align, mode)
