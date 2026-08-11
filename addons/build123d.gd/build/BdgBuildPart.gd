extends BdgBuilder
## BdgBuildPart - builder for 3D parts.
## Mirrors build123d/build_part.py BuildPart.
class_name BdgBuildPart

const TAG := "BuildPart"

func _init() -> void:
	_tag = TAG
	_primary = "solid"

## The built 3D part.
func part() -> BdgPart:
	if _obj is BdgPart:
		return _obj
	if _obj != null:
		return BdgPart.new(_obj.wrapped(), _obj.solids())
	return null

func _add_to_context(obj: BdgShape, mode: int) -> void:
	obj_before = _obj
	to_combine = [obj]
	var solids_in: Array = []
	if obj is BdgCompound:
		solids_in = obj.solids()
	elif obj is BdgSolid:
		solids_in = [obj]
	elif obj is BdgShape:
		solids_in = obj.solids()
	if solids_in.is_empty():
		push_error("BdgBuildPart: no solids to add")
		return
	if mode == BdgEnums.Mode.PRIVATE:
		_track_op([], [], solids_in)
		return
	match mode:
		BdgEnums.Mode.ADD:
			if _obj == null:
				_obj = solids_in[0] if solids_in.size() == 1 else solids_in[0].fuse_all(solids_in.slice(1))
			else:
				_obj = _obj.fuse_all(solids_in)
		BdgEnums.Mode.SUBTRACT:
			if _obj == null:
				push_error("BdgBuildPart: nothing to subtract from")
				return
			_obj = _obj.cut_all(solids_in)
		BdgEnums.Mode.INTERSECT:
			if _obj == null:
				push_error("BdgBuildPart: nothing to intersect with")
				return
			_obj = _obj.intersect_all(solids_in)
		BdgEnums.Mode.REPLACE:
			_obj = BdgShape.make_compound_of(solids_in)
	if _obj != null and _obj is BdgCompound:
		_obj = BdgPart.new(_obj.wrapped(), _obj.solids())
	_track_op([], [], solids_in)
