extends BdgBuilder
## BdgBuildSketch - builder for 2D sketches.
## Mirrors build123d/build_sketch.py BuildSketch.
class_name BdgBuildSketch

const TAG := "BuildSketch"

func _init() -> void:
	_tag = TAG
	_primary = "face"

## The built sketch.
func sketch() -> BdgSketch:
	if _obj is BdgSketch:
		return _obj
	if _obj != null:
		return BdgSketch.new(_obj.wrapped(), _obj.faces())
	return null

func _add_to_context(obj: BdgShape, mode: int) -> void:
	obj_before = _obj
	to_combine = [obj]
	var faces_in: Array = []
	if obj is BdgCompound:
		faces_in = obj.faces()
	elif obj is BdgFace:
		faces_in = [obj]
	elif obj is BdgShape:
		faces_in = obj.faces()
	if faces_in.is_empty():
		push_error("BdgBuildSketch: no faces to add")
		return
	if mode == BdgEnums.Mode.PRIVATE:
		_track_op([], faces_in, [])
		return
	match mode:
		BdgEnums.Mode.ADD:
			if _obj == null:
				_obj = faces_in[0] if faces_in.size() == 1 else faces_in[0].fuse_all(faces_in.slice(1))
			else:
				_obj = _obj.fuse_all(faces_in)
		BdgEnums.Mode.SUBTRACT:
			if _obj == null:
				push_error("BdgBuildSketch: nothing to subtract from")
				return
			_obj = _obj.cut_all(faces_in)
		BdgEnums.Mode.INTERSECT:
			if _obj == null:
				push_error("BdgBuildSketch: nothing to intersect with")
				return
			_obj = _obj.intersect_all(faces_in)
		BdgEnums.Mode.REPLACE:
			_obj = BdgShape.make_compound_of(faces_in)
	if _obj != null and _obj is BdgCompound:
		_obj = BdgSketch.new(_obj.wrapped(), _obj.faces())
	_track_op([], faces_in, [])
