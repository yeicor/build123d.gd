extends BdgSketchObject
## BdgRectangleRounded - Sketch Object: Rounded Rectangle
## Create a rectangle with rounded corners defined by width, height and corner radius.
class_name BdgRectangleRounded

var width: float
var rectangle_height: float
var corner_radius: float

## Args: width, height, radius, rotation (deg about Z, default 0),
##       align: BdgEnums.Align | Array[int] (2 axes, default CENTER*2),
##       mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := 0.0
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	width = args[0]
	rectangle_height = args[1]
	corner_radius = args[2]
	if args.size() > 3 and args[3] != null:
		rotation = args[3]
	if args.size() > 4 and args[4] != null:
		align = args[4]
	if args.size() > 5 and args[5] != null:
		mode = args[5]
	var face := BdgFace.make_rounded_rect(width, rectangle_height, corner_radius)
	_from_face(face, rotation, align, mode)
