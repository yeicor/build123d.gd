extends BdgBuilder
## BdgBuildLine - builder for 1D curves (wires/edges).
## Mirrors build123d/build_line.py BuildLine.
class_name BdgBuildLine

const TAG := "BuildLine"

func _init() -> void:
	_tag = TAG
	_primary = "edge"

## The built line (a Curve/Wire of the collected edges).
func line() -> BdgShape:
	return _obj

## The built wire/curve.
func curve() -> BdgShape:
	return _obj

func _add_to_context(obj: BdgShape, mode: int) -> void:
	obj_before = _obj
	to_combine = [obj]
	var edges_in: Array = []
	if obj is BdgCompound:
		edges_in = obj.edges()
	elif obj is BdgEdge:
		edges_in = [obj]
	elif obj is BdgShape:
		edges_in = obj.edges()
	if edges_in.is_empty():
		push_error("BdgBuildLine: no edges to add")
		return
	if mode == BdgEnums.Mode.PRIVATE:
		_track_op(edges_in, [], [])
		return
	match mode:
		BdgEnums.Mode.ADD:
			if _obj == null:
				_obj = edges_in[0] if edges_in.size() == 1 else BdgShape.make_compound_of(edges_in)
			else:
				_obj = BdgShape.make_compound_of([_obj] + edges_in)
		BdgEnums.Mode.SUBTRACT:
			if _obj == null:
				push_error("BdgBuildLine: nothing to subtract from")
				return
			var keep: Array = []
			for e in _obj.edges():
				var remove := false
				for t in edges_in:
					if e._wrapped != null and t._wrapped != null and e._wrapped.is_same(t._wrapped):
						remove = true
						break
				if not remove:
					keep.append(e)
			_obj = BdgShape.make_compound_of(keep)
		BdgEnums.Mode.REPLACE:
			_obj = BdgShape.make_compound_of(edges_in)
	if _obj != null and _obj is BdgCompound:
		var wire := BdgWire.make_wire(_obj.edges())
		if wire != null:
			_obj = wire
	_track_op(edges_in, [], [])
