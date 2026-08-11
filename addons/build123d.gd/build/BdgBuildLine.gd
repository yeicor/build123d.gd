extends BdgBuilder
## BdgBuildLine - builder for 1D curves (wires/edges).
## Mirrors build123d/build_line.py BuildLine.
class_name BdgBuildLine

const TAG := "BuildLine"

func _init() -> void:
	_tag = TAG

## The built wire/curve.
func curve() -> BdgShape:
	return _obj

## All edges of the built line.
func edges() -> Array:
	return [] if _obj == null else _obj.edges()

## The built wire (edges fused into a single wire when possible).
func wire() -> BdgWire:
	if _obj is BdgWire:
		return _obj
	return null

func _add_to_context(obj: BdgShape, mode: int) -> void:
	var edges: Array = []
	if obj is BdgCompound:
		edges = obj.edges()
	elif obj is BdgEdge:
		edges = [obj]
	elif obj is BdgShape:
		edges = obj.edges()
	if edges.is_empty():
		push_error("BdgBuildLine: no edges to add")
		return
	match mode:
		BdgEnums.Mode.ADD:
			if _obj == null:
				_obj = edges[0] if edges.size() == 1 else BdgShape.make_compound_of(edges)
			else:
				_obj = BdgShape.make_compound_of([_obj] + edges)
		BdgEnums.Mode.REPLACE:
			_obj = BdgShape.make_compound_of(edges)
	if _obj != null and _obj is BdgCompound:
		var wire := BdgWire.make_wire(_obj.edges())
		if wire != null:
			_obj = wire
