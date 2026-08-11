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
