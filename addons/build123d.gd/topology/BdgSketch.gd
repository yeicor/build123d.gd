extends BdgCompound
## BdgSketch - a 2D profile used for sketches/extrusions. Mirrors build123d/topology/composite.py Sketch.
class_name BdgSketch

func _init(...args) -> void:
	super(args[0] if args.size() >= 1 else null, args[1] if args.size() >= 2 and args[1] is Array else [])
