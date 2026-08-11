extends BdgBuilder
## BdgBuildSketch - builder for 2D sketches.
## Mirrors build123d/build_sketch.py BuildSketch.
class_name BdgBuildSketch

const TAG := "BuildSketch"

func _init() -> void:
	_tag = TAG

## The built sketch.
func sketch() -> BdgSketch:
	if _obj is BdgSketch:
		return _obj
	if _obj != null:
		return BdgSketch.new(_obj.wrapped(), _obj.faces())
	return null

## All faces of the sketch.
func faces() -> Array:
	return [] if _obj == null else _obj.faces()

## All edges of the sketch.
func edges() -> Array:
	return [] if _obj == null else _obj.edges()

func _add_to_context(obj: BdgShape, mode: int) -> void:
	var faces: Array = []
	if obj is BdgCompound:
		faces = obj.faces()
	elif obj is BdgFace:
		faces = [obj]
	elif obj is BdgShape:
		faces = obj.faces()
	if faces.is_empty():
		push_error("BdgBuildSketch: no faces to add")
		return
	match mode:
		BdgEnums.Mode.ADD:
			if _obj == null:
				_obj = faces[0] if faces.size() == 1 else faces[0].fuse_all(faces.slice(1))
			else:
				_obj = _obj.fuse_all(faces)
		BdgEnums.Mode.SUBTRACT:
			if _obj == null:
				push_error("BdgBuildSketch: nothing to subtract from")
				return
			_obj = _obj.cut_all(faces)
		BdgEnums.Mode.INTERSECT:
			if _obj == null:
				push_error("BdgBuildSketch: nothing to intersect with")
				return
			_obj = _obj.intersect_all(faces)
		BdgEnums.Mode.REPLACE:
			_obj = BdgShape.make_compound_of(faces)
	if _obj != null and _obj is BdgCompound:
		_obj = BdgSketch.new(_obj.wrapped(), _obj.faces())
