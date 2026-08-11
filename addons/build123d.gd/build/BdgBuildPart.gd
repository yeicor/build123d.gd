extends BdgBuilder
## BdgBuildPart - builder for 3D parts.
## Mirrors build123d/build_part.py BuildPart.
class_name BdgBuildPart

const TAG := "BuildPart"

func _init() -> void:
	_tag = TAG

## The built 3D part.
func part() -> BdgPart:
	if _obj is BdgPart:
		return _obj
	if _obj != null:
		return BdgPart.new(_obj.wrapped(), _obj.solids())
	return null

## All faces of the current part.
func faces() -> Array:
	return [] if _obj == null else _obj.faces()

## All solids of the current part.
func solids() -> Array:
	return [] if _obj == null else _obj.solids()

## All edges of the current part.
func edges() -> Array:
	return [] if _obj == null else _obj.edges()

func _add_to_context(obj: BdgShape, mode: int) -> void:
	var solids: Array = []
	if obj is BdgCompound:
		solids = obj.solids()
	elif obj is BdgSolid:
		solids = [obj]
	elif obj is BdgShape:
		solids = obj.solids()
	if solids.is_empty():
		push_error("BdgBuildPart: no solids to add")
		return
	match mode:
		BdgEnums.Mode.ADD:
			if _obj == null:
				_obj = solids[0] if solids.size() == 1 else solids[0].fuse_all(solids.slice(1))
			else:
				_obj = _obj.fuse_all(solids)
		BdgEnums.Mode.SUBTRACT:
			if _obj == null:
				push_error("BdgBuildPart: nothing to subtract from")
				return
			_obj = _obj.cut_all(solids)
		BdgEnums.Mode.INTERSECT:
			if _obj == null:
				push_error("BdgBuildPart: nothing to intersect with")
				return
			_obj = _obj.intersect_all(solids)
		BdgEnums.Mode.REPLACE:
			_obj = BdgShape.make_compound_of(solids)
	if _obj != null and _obj is BdgCompound:
		_obj = BdgPart.new(_obj.wrapped(), _obj.solids())
