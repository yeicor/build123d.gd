extends BdgShape
## BdgMixin1D - shared methods for 1D shapes (Edge, Wire).
## Mirrors build123d/topology/one_d.py Mixin1D.
class_name BdgMixin1D

## Total length of the shape
func length() -> float:
	if is_null():
		return 0.0
	var props := OcgGPropGProps.new()
	OcgBRepGProp.linear_properties(_wrapped, props, true, false)
	return props.mass()

func is_closed() -> bool:
	return _wrapped.closed_k()

## Position at given parameter (0..1) along the curve. Uses the edge's Geom_Curve.
func position_at(position: float) -> Vector3:
	var c := _edge_curve_with_bounds()
	if c.is_empty():
		return Vector3.ZERO
	var curve: OcgGeomCurve = c[0]
	var lo: float = c[1]
	var hi: float = c[2]
	var u := lo + position * (hi - lo)
	return BdgShape._gp_pnt_to_v3(curve.value(u))

func start_point() -> Vector3:
	return position_at(0.0)

func end_point() -> Vector3:
	return position_at(1.0)

func tangent_at(position: float) -> Vector3:
	var c := _edge_curve_with_bounds()
	if c.is_empty():
		return Vector3.ZERO
	var curve: OcgGeomCurve = c[0]
	var lo: float = c[1]
	var hi: float = c[2]
	var u := lo + position * (hi - lo)
	return BdgShape._gp_vec_to_v3(curve.eval_dn(u, 1)).normalized()

## center of the edge/wire
func center() -> Vector3:
	return position_at(0.5)

## Get the underlying Geom_Curve of the (first) edge with its trimmed parameter bounds.
## Returns [curve, first_param, last_param] or [] if unavailable.
func _edge_curve_with_bounds() -> Array:
	var e := _first_edge()
	if e == null:
		return []
	var first := OcgStandardReal.new()
	var last := OcgStandardReal.new()
	var curve := OcgBRepTool.curve_F(e, first, last)
	if curve == null:
		return []
	return [curve, first.get_value(), last.get_value()]

func _first_edge() -> OcgTopoDSEdge:
	if is_null():
		return null
	if int(_wrapped.shape_type()) == BdgEnums.ShapeType.EDGE:
		return _wrapped
	var exp := OcgTopExpExplorer.from_4(_wrapped, int(BdgEnums.ShapeType.EDGE), int(BdgEnums.ShapeType.SHAPE))
	if exp.more():
		return exp.current()
	return null
