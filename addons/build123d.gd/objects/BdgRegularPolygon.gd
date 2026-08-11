extends BdgSketchObject
## BdgRegularPolygon - Sketch Object: Regular Polygon
## Create a regular polygon with a given circumradius and side count.
class_name BdgRegularPolygon

var radius: float
var side_count: int

## Args: radius, side_count, rotation (deg about Z, default 0),
##       align: BdgEnums.Align | Array[int] (2 axes, default CENTER*2),
##       mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := 0.0
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	radius = args[0]
	side_count = args[1]
	if args.size() > 2 and args[2] != null:
		rotation = args[2]
	if args.size() > 3 and args[3] != null:
		align = args[3]
	if args.size() > 4 and args[4] != null:
		mode = args[4]
	var face := BdgFace.make_regular_polygon(radius, side_count)
	_from_face(face, rotation, align, mode)
