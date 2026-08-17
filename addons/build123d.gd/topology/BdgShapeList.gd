extends RefCounted
## BdgShapeList - a list of BdgShape with CAD-specific filter/sort/group helpers.
## Mirrors build123d/topology/shape_core.py ShapeList.
class_name BdgShapeList

var _shapes: Array = []
var _iter_index := 0

# ---------------------------------------------------------------------------
# Construction / list protocol
# ---------------------------------------------------------------------------

func _init(...args) -> void:
	if args.size() == 1 and args[0] is Array:
		for s in args[0]:
			if s is BdgShape:
				_shapes.append(s)

func _iter_init(_iter) -> bool:
	_iter_index = 0
	return _iter_index < _shapes.size()

func _iter_next(_iter) -> bool:
	_iter_index += 1
	return _iter_index < _shapes.size()

func _iter_get(_iter) -> BdgShape:
	return _shapes[_iter_index]

func size() -> int:
	return _shapes.size()

func is_empty() -> bool:
	return _shapes.is_empty()

func at(i: int) -> BdgShape:
	return _shapes[i]

func get_all() -> Array:
	return _shapes.duplicate()

func append(shape: BdgShape) -> BdgShapeList:
	if shape != null:
		_shapes.append(shape)
	return self

func extend(other: BdgShapeList) -> BdgShapeList:
	for s in other:
		_shapes.append(s)
	return self

func slice(begin: int, end: int) -> BdgShapeList:
	return BdgShapeList.new(_shapes.slice(begin, end))

func first() -> BdgShape:
	return _shapes[0]

func last() -> BdgShape:
	return _shapes[-1]

## average of the centers of all objects
func center() -> Vector3:
	if _shapes.is_empty():
		return Vector3.ZERO
	var total := Vector3.ZERO
	for s in _shapes:
		total += s.center()
	return total / _shapes.size()

# ---------------------------------------------------------------------------
# Flatten accessors (all sub-shapes across the list)
# ---------------------------------------------------------------------------

func vertices() -> BdgShapeList:
	var out := BdgShapeList.new()
	for s in _shapes:
		out.extend(s.vertices())
	return out

func edges() -> BdgShapeList:
	var out := BdgShapeList.new()
	for s in _shapes:
		out.extend(s.edges())
	return out

func wires() -> BdgShapeList:
	var out := BdgShapeList.new()
	for s in _shapes:
		out.extend(s.wires())
	return out

func faces() -> BdgShapeList:
	var out := BdgShapeList.new()
	for s in _shapes:
		out.extend(s.faces())
	return out

func shells() -> BdgShapeList:
	var out := BdgShapeList.new()
	for s in _shapes:
		out.extend(s.shells())
	return out

func solids() -> BdgShapeList:
	var out := BdgShapeList.new()
	for s in _shapes:
		out.extend(s.solids())
	return out

func compounds() -> BdgShapeList:
	var out := BdgShapeList.new()
	for s in _shapes:
		out.extend(s.compounds())
	return out

## return the single vertex/edge/... or raise an error if not exactly one
func vertex() -> BdgShape:
	var vs := vertices()
	if vs.size() != 1:
		push_error("Expected exactly one vertex, found %d" % vs.size())
	return vs.first()

func edge() -> BdgShape:
	var es := edges()
	if es.size() != 1:
		push_error("Expected exactly one edge, found %d" % es.size())
	return es.first()

func wire() -> BdgShape:
	var ws := wires()
	if ws.size() != 1:
		push_error("Expected exactly one wire, found %d" % ws.size())
	return ws.first()

func face() -> BdgShape:
	var fs := faces()
	if fs.size() != 1:
		push_error("Expected exactly one face, found %d" % fs.size())
	return fs.first()

func shell() -> BdgShape:
	var ss := shells()
	if ss.size() != 1:
		push_error("Expected exactly one shell, found %d" % ss.size())
	return ss.first()

func solid() -> BdgShape:
	var ss := solids()
	if ss.size() != 1:
		push_error("Expected exactly one solid, found %d" % ss.size())
	return ss.first()

func compound() -> BdgShape:
	var cs := compounds()
	if cs.size() != 1:
		push_error("Expected exactly one compound, found %d" % cs.size())
	return cs.first()

## dissolve compounds to children, wires to edges, shells to faces; drop nulls
func expand() -> BdgShapeList:
	var out := BdgShapeList.new()
	for s in _shapes:
		if s.shape_type() == BdgEnums.ShapeType.COMPOUND:
			for child in s.get_top_level_shapes():
				out.extend(BdgShapeList.new([child]).expand())
		elif s.shape_type() == BdgEnums.ShapeType.SHELL:
			out.extend(s.faces())
		elif s.shape_type() == BdgEnums.ShapeType.WIRE:
			out.extend(s.edges())
		elif not s.is_null():
			out.append(s)
	return out

## build a compound of every shape in this list
func build_compound() -> BdgShape:
	return BdgShape.make_compound_of(_shapes)

# ---------------------------------------------------------------------------
# Filter
# ---------------------------------------------------------------------------

## filter by Callable(shape)->bool, BdgAxis, BdgPlane, or BdgEnums.GeomType.
## reverse=true inverts the predicate.
func filter_by(filter_by, reverse: bool = false, tolerance: float = 1e-5) -> BdgShapeList:
	var predicate: Callable
	if filter_by is Callable:
		predicate = filter_by
	elif filter_by is BdgAxis:
		predicate = _axis_parallel_predicate(filter_by, tolerance)
	elif filter_by is BdgPlane:
		predicate = _plane_parallel_predicate(filter_by, tolerance)
	elif filter_by is int:
		predicate = func(obj: BdgShape) -> bool:
			return obj.geom_type() == filter_by
	else:
		push_error("Unsupported filter_by predicate: %s" % filter_by)
		return BdgShapeList.new()

	var out := BdgShapeList.new()
	for s in _shapes:
		var hit := predicate.call(s)
		if hit != reverse:
			out.append(s)
	return out

## filter and sort by the position of centers along an axis
func filter_by_position(axis: BdgAxis, minimum: float, maximum: float, include_min: bool = true, include_max: bool = true) -> BdgShapeList:
	var out := BdgShapeList.new()
	for s in _shapes:
		var pos := _axis_coord(axis, s.center())
		var lo_ok := (pos >= minimum) if include_min else (pos > minimum)
		var hi_ok := (pos <= maximum) if include_max else (pos < maximum)
		if lo_ok and hi_ok:
			out.append(s)
	return out.sort_by(axis)

func _axis_parallel_predicate(axis: BdgAxis, tolerance: float) -> Callable:
	return func(shape: BdgShape) -> bool:
		var shape_axis := _shape_axis(shape)
		if shape_axis == null:
			return false
		return _axes_parallel(axis, shape_axis, tolerance)

func _plane_parallel_predicate(plane: BdgPlane, tolerance: float) -> Callable:
	return func(shape: BdgShape) -> bool:
		var plane_axis := BdgAxis.new(plane.origin, plane.z_dir)
		match shape.shape_type():
			BdgEnums.ShapeType.FACE:
				if shape.geom_type() != BdgEnums.GeomType.PLANE:
					return false
				return _axes_parallel(plane_axis, BdgAxis.new(shape.center(), shape.normal()), tolerance)
			BdgEnums.ShapeType.WIRE:
				for e in shape.edges():
					if not _plane_parallel_edge(plane, e, tolerance):
						return false
				return true
			BdgEnums.ShapeType.EDGE:
				return _plane_parallel_edge(plane, shape, tolerance)
		return false

func _plane_parallel_edge(plane: BdgPlane, edge: BdgShape, tolerance: float) -> bool:
	match edge.geom_type():
		BdgEnums.GeomType.LINE:
			return absf(plane.distance(edge.call("start_point"))) < tolerance \
				and absf(plane.distance(edge.call("end_point"))) < tolerance
		BdgEnums.GeomType.CIRCLE:
			var arc_center: Vector3 = edge.call("arc_center")
			var start: Vector3 = edge.call("start_point")
			var tangent: Vector3 = edge.call("tangent_at", 0.0)
			var radial := (start - arc_center).normalized()
			var circle_normal := tangent.cross(radial).normalized()
			return absf(plane.distance(arc_center)) < tolerance \
				and _axes_parallel(BdgAxis.new(arc_center, circle_normal), BdgAxis.new(plane.origin, plane.z_dir), tolerance)
	return false

# ---------------------------------------------------------------------------
# Sort / group
# ---------------------------------------------------------------------------

## sort by Callable(shape)->float, BdgAxis, or BdgEnums.SortBy
func sort_by(sort_by, reverse: bool = false) -> BdgShapeList:
	var key_fn: Callable
	if sort_by is Callable:
		key_fn = sort_by
	elif sort_by is BdgAxis:
		key_fn = func(obj: BdgShape) -> float:
			return _axis_coord(sort_by, obj.center())
	elif sort_by is int:
		key_fn = _sort_key(sort_by)
	else:
		push_error("Unsupported sort_by criteria: %s" % sort_by)
		return BdgShapeList.new()

	var items := _shapes.duplicate()
	_sort_with_key(items, key_fn, reverse)
	return BdgShapeList.new(items)

## group by Callable, BdgAxis, or BdgEnums.SortBy; returns Array of BdgShapeList
func group_by(group_by, reverse: bool = false, tol_digits: int = 6) -> Array:
	var key_fn: Callable
	if group_by is Callable:
		key_fn = group_by
	elif group_by is BdgAxis:
		key_fn = func(obj: BdgShape) -> float:
			return _round(_axis_coord(group_by, obj.center()), tol_digits)
	elif group_by is int:
		var base := _sort_key(group_by)
		key_fn = func(obj: BdgShape) -> float:
			return _round(base.call(obj), tol_digits)
	else:
		push_error("Unsupported group_by criteria: %s" % group_by)
		return []

	var groups: Dictionary = {}
	var order: Array = []
	for s in _shapes:
		var key = key_fn.call(s)
		if not groups.has(key):
			groups[key] = BdgShapeList.new()
			order.append(key)
		groups[key].append(s)
	order.sort()
	if reverse:
		order.reverse()
	var result: Array = []
	for k in order:
		result.append(groups[k])
	return result

func _sort_key(sort_by: int) -> Callable:
	match sort_by:
		BdgEnums.SortBy.LENGTH:
			return func(obj: BdgShape) -> float:
				return obj.call("length") if obj.has_method("length") else 0.0
		BdgEnums.SortBy.AREA:
			return func(obj: BdgShape) -> float:
				return obj.area() if obj.has_method("area") else 0.0
		BdgEnums.SortBy.VOLUME:
			return func(obj: BdgShape) -> float:
				return obj.volume()
		BdgEnums.SortBy.DISTANCE:
			return func(obj: BdgShape) -> float:
				return obj.center().length()
		BdgEnums.SortBy.X:
			return func(obj: BdgShape) -> float:
				return obj.center().x
		BdgEnums.SortBy.Y:
			return func(obj: BdgShape) -> float:
				return obj.center().y
		BdgEnums.SortBy.Z:
			return func(obj: BdgShape) -> float:
				return obj.center().z
	return func(obj: BdgShape) -> float:
		return obj.center().z

## Sort shapes by distance to a target point/shape
func sort_by_distance(target: Variant, reverse: bool = false) -> BdgShapeList:
	var target_pt := Vector3.ZERO
	if target is Vector3:
		target_pt = target
	elif target is BdgShape:
		target_pt = target.center()
	return sort_by(func(obj: BdgShape) -> float:
		return obj.center().distance_to(target_pt), reverse)


# ---------------------------------------------------------------------------
# Distances
# ---------------------------------------------------------------------------

## minimum distance between the shapes of this list and another list
func distance_to(other: BdgShapeList) -> float:
	return distance_to_with_closest_points(other)["distance"]

## minimum distance and the closest point pairs (via BRepExtrema_DistShapeShape)
func distance_to_with_closest_points(other: BdgShapeList) -> Dictionary:
	var best := INF
	var best_points: Array = []
	for a in _shapes:
		for b in other:
			var d := _shape_distance(a, b)
			if d < best:
				best = d
				best_points = [a.center(), b.center()]
	if best == INF:
		return {"distance": 0.0, "closest_points": []}
	return {"distance": best, "closest_points": best_points}

func _shape_distance(a: BdgShape, b: BdgShape) -> float:
	var ext := OcgBRepExtremaDistShapeShape.from_q(
		a.wrapped(), b.wrapped(),
		OcgEnums.Extrema_ExtFlag.Extrema_ExtFlag_MINMAX,
		OcgEnums.Extrema_ExtAlgo.Extrema_ExtAlgo_Grad,
		OcgMessageProgressRange.new())
	if ext == null or not ext.is_done():
		return a.center().distance_to(b.center())
	return ext.value()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _round(v: Variant, digits: int):
	if v is float:
		return snappedf(v, pow(10.0, -digits))
	return v

func _sort_with_key(items: Array, key_fn: Callable, reverse: bool) -> void:
	items.sort_custom(func(a: BdgShape, b: BdgShape) -> bool:
		var ka: Variant = key_fn.call(a)
		var kb: Variant = key_fn.call(b)
		return (ka < kb) if not reverse else (ka > kb)
	)

## signed coordinate of a point along an axis direction from its origin
func _axis_coord(axis: BdgAxis, p: Vector3) -> float:
	return (p - axis.position).dot(axis.direction)

func _axes_parallel(a: BdgAxis, b: BdgAxis, tolerance: float) -> bool:
	if a == null or b == null:
		return false
	return a.wrapped().is_parallel(b.wrapped(), tolerance * (PI / 180.0))

## axis of a planar face (normal) or a linear edge (tangent); else null
func _shape_axis(shape: BdgShape) -> BdgAxis:
	if shape.shape_type() == BdgEnums.ShapeType.FACE and shape.geom_type() == BdgEnums.GeomType.PLANE:
		return BdgAxis.new(shape.center(), shape.call("normal"))
	elif shape.shape_type() == BdgEnums.ShapeType.EDGE and shape.geom_type() == BdgEnums.GeomType.LINE:
		return BdgAxis.new(shape.call("start_point"), shape.call("tangent_at", 0.0))
	return null

func _to_string() -> String:
	return "ShapeList(%s)" % _shapes
