extends BdgCompound
## BdgPart - a 3D model to be printed or machined. Mirrors build123d/topology/composite.py Part.
class_name BdgPart

func _init(...args) -> void:
	super(args[0] if args.size() >= 1 else null, args[1] if args.size() >= 2 and args[1] is Array else [])
