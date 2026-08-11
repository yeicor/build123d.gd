extends BdgSketchObject
## BdgTriangle - Sketch Object: Triangle
## Create an isosceles triangle with a given base and height (apex centered).
class_name BdgTriangle

var base: float
var height: float

## Args: base, height, rotation (deg about Z, default 0),
##       align: BdgEnums.Align | Array[int] (2 axes, default CENTER*2),
##       mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := 0.0
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	base = args[0]
	height = args[1]
	if args.size() > 2 and args[2] != null:
		rotation = args[2]
	if args.size() > 3 and args[3] != null:
		align = args[3]
	if args.size() > 4 and args[4] != null:
		mode = args[4]
	var face := BdgFace.make_triangle(base, height)
	_from_face(face, rotation, align, mode)
