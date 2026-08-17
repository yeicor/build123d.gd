extends BdgShape
## BdgCompound - a collection of shapes, wrapping OcgTopoDSCompound.
## Mirrors build123d/topology/composite.py Compound.
class_name BdgCompound

var children: Array = []

func _init(...args) -> void:
	super(args[0] if args.size() >= 1 else null)
	if args.size() >= 2 and args[1] is Array:
		children = args[1]

## create a compound from shapes
static func make_compound(shapes: Array) -> BdgCompound:
	return BdgShape.make_compound_of(shapes)

func center() -> Vector3:
	return center_of_mass()

## Check if children in compound intersect each other
func do_children_intersect() -> bool:
	var ch := children if not children.is_empty() else solids()
	for i in range(ch.size()):
		for j in range(i + 1, ch.size()):
			if ch[i] is BdgShape and ch[j] is BdgShape:
				if ch[i].distance_to(ch[j]) < 1e-6:
					return true
	return false

## Construct 3D RGB XYZ axis triad compound
static func make_triad(axis_length: float = 10.0) -> BdgCompound:
	var x_axis := BdgEdge.make_line(Vector3.ZERO, Vector3(axis_length, 0, 0))
	var y_axis := BdgEdge.make_line(Vector3.ZERO, Vector3(0, axis_length, 0))
	var z_axis := BdgEdge.make_line(Vector3.ZERO, Vector3(0, 0, axis_length))
	x_axis.copy_attributes_to(x_axis)
	x_axis._color = BdgColor.new("red")
	y_axis._color = BdgColor.new("green")
	z_axis._color = BdgColor.new("blue")
	return make_compound([x_axis, y_axis, z_axis])

## Extract flat array of child shapes
func unwrap() -> Array:
	if not children.is_empty():
		return children
	var sub: Array = []
	for s in solids(): sub.append(s)
	for f in faces(): sub.append(f)
	for e in edges(): sub.append(e)
	return sub

## Project compound onto 2D viewport plane
func project_to_viewport(plane: BdgPlane = null) -> BdgCompound:
	var p := plane if plane != null else BdgPlane.XY
	var proj_shapes: Array = []
	for s in unwrap():
		if s is BdgEdge:
			proj_shapes.append(s.project_to_shape(p))
	return make_compound(proj_shapes)

