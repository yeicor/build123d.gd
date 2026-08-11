extends BdgSketchObject
## BdgEllipse - Sketch Object: Ellipse
## Create an ellipse with given radii, centered at origin. Defaults to full ellipse.
class_name BdgEllipse

var x_radius: float
var y_radius: float

## Args: x_radius, y_radius, rotation (deg about Z, default 0),
##       align: BdgEnums.Align | Array[int] (2 axes, default CENTER*2),
##       mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := 0.0
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	x_radius = args[0]
	y_radius = args[1]
	if args.size() > 2 and args[2] != null:
		rotation = args[2]
	if args.size() > 3 and args[3] != null:
		align = args[3]
	if args.size() > 4 and args[4] != null:
		mode = args[4]
	var face := BdgFace.make_ellipse(x_radius, y_radius)
	_from_face(face, rotation, align, mode)
