extends BdgShape
## BdgMixin1D - shared methods for 1D shapes (Edge, Wire).
## Mirrors build123d/topology/one_d.py Mixin1D.
class_name BdgMixin1D

## Total length of the shape
func length() -> float:
	if _wrapped == null or _wrapped.is_null():
		return 0.0
	var props := OcgGPropGProps.new()
	OcgBRepGProp.linear_properties(_wrapped, props, true, false)
	return props.mass()

func is_closed() -> bool:
	if _wrapped == null or _wrapped.is_null():
		return false
	return _wrapped.closed_k()

## Position at given parameter (0..1) along the curve. Uses the edge's Geom_Curve.
func position_at(position: float) -> Vector3:
	var c := _edge_curve_with_bounds()
	if c.is_empty() or c[0] == null:
		var bb := bounding_box()
		return bb.center() if bb != null else Vector3.ZERO
	var curve: OcgGeomCurve = c[0]
	var lo: float = c[1]
	var hi: float = c[2]
	var u := lo + position * (hi - lo)
	var p := curve.value(u)
	return BdgShape._gp_pnt_to_v3(p) if p != null else Vector3.ZERO

## Find normalized parameter (0..1) at given arclength distance along the curve.
func param_at_distance(dist: float) -> float:
	var c := _edge_curve_with_bounds()
	if c.is_empty():
		return 0.5
	var lo: float = c[1]
	var hi: float = c[2]
	var total_len := length()
	if total_len <= 1e-9:
		return 0.0
	var target_dist := clampf(dist, 0.0, total_len)
	if _wrapped != null and not _wrapped.is_null():
		var adapt := OcgBRepAdaptorCurve.from_g(_wrapped)
		if adapt != null:
			var absc := OcgGCPntsAbscissaPoint.from_E(adapt, target_dist, lo, 1e-6)
			if absc != null and absc.is_done():
				var u_raw := absc.parameter()
				return clampf((u_raw - lo) / (hi - lo), 0.0, 1.0)
	return clampf(dist / total_len, 0.0, 1.0)

func start_point() -> Vector3:
	return position_at(0.0)

func end_point() -> Vector3:
	return position_at(1.0)

## Tangent unit vector at parameter (0..1) along the curve.
func tangent_at(position: float) -> Vector3:
	var c := _edge_curve_with_bounds()
	if c.is_empty():
		return Vector3.ZERO
	var curve: OcgGeomCurve = c[0]
	var lo: float = c[1]
	var hi: float = c[2]
	var u := lo + position * (hi - lo)
	var d1 := BdgShape._gp_vec_to_v3(curve.eval_dn(u, 1))
	return d1.normalized() if d1.length_squared() > 1e-12 else Vector3.FORWARD

## Principal normal unit vector at parameter (0..1) along the curve.
func normal_at(position: float) -> Vector3:
	var c := _edge_curve_with_bounds()
	if c.is_empty():
		return Vector3.UP
	var curve: OcgGeomCurve = c[0]
	var lo: float = c[1]
	var hi: float = c[2]
	var u := lo + position * (hi - lo)
	var d1 := BdgShape._gp_vec_to_v3(curve.eval_dn(u, 1))
	var d2 := BdgShape._gp_vec_to_v3(curve.eval_dn(u, 2))
	var t := d1.normalized()
	var perp := d2 - t * d2.dot(t)
	if perp.length_squared() > 1e-10:
		return perp.normalized()
	# Fallback for straight lines
	var fallback := Vector3.UP if absf(t.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	return t.cross(fallback).normalized()

## Curvature (1 / radius) at parameter (0..1) along the curve.
func curvature_at(position: float) -> float:
	var c := _edge_curve_with_bounds()
	if c.is_empty():
		return 0.0
	var curve: OcgGeomCurve = c[0]
	var lo: float = c[1]
	var hi: float = c[2]
	var u := lo + position * (hi - lo)
	var d1 := BdgShape._gp_vec_to_v3(curve.eval_dn(u, 1))
	var d2 := BdgShape._gp_vec_to_v3(curve.eval_dn(u, 2))
	var l1 := d1.length()
	if l1 < 1e-8:
		return 0.0
	return d1.cross(d2).length() / (l1 * l1 * l1)

## Radius of curvature at parameter (0..1). INF if straight.
func radius_at(position: float) -> float:
	var k := curvature_at(position)
	return 1.0 / k if k > 1e-10 else INF

## Sample positions at given count or array of parameters (0..1).
func positions(count_or_params: Variant) -> Array[Vector3]:
	var result: Array[Vector3] = []
	if count_or_params is int:
		var n: int = count_or_params
		if n <= 1:
			return [center()]
		for i in n:
			result.append(position_at(float(i) / float(n - 1)))
	elif count_or_params is Array:
		for p in count_or_params:
			result.append(position_at(float(p)))
	return result

## Sample Locations along the curve (position + tangent orientation).
func locations(count_or_params: Variant) -> Array[BdgLocation]:
	var result: Array[BdgLocation] = []
	var params: Array[float] = []
	if count_or_params is int:
		var n: int = count_or_params
		if n <= 1:
			params = [0.5]
		else:
			for i in n:
				params.append(float(i) / float(n - 1))
	elif count_or_params is Array:
		for p in count_or_params:
			params.append(float(p))

	for u in params:
		var pos := position_at(u)
		var t := tangent_at(u)
		var n := normal_at(u)
		var b := t.cross(n).normalized()
		var basis := Basis(b, n, t)
		result.append(BdgLocation.new(pos, basis.get_rotation_quaternion()))
	return result

## center of the edge/wire
func center() -> Vector3:
	return position_at(0.5)

## Tessellate this 1D edge/wire into a polyline point array.
func tessellate_edge(tolerance: float = 0.02) -> PackedVector3Array:
	var pts := PackedVector3Array()
	var c := _edge_curve_with_bounds()
	if c.is_empty():
		var v_list := vertices()
		for v in v_list:
			pts.append(v.position() if v.has_method("position") else v.center())
		return pts

	var curve: OcgGeomCurve = c[0]
	var lo: float = c[1]
	var hi: float = c[2]
	var n_samples: int = 32

	if curve is OcgGeomLine:
		n_samples = 2
	elif curve is OcgGeomCircle or curve is OcgGeomTrimmedCurve:
		n_samples = 36
	else:
		n_samples = 48

	for i in range(n_samples):
		var u: float = lo + (float(i) / float(n_samples - 1)) * (hi - lo)
		var p := curve.value(u)
		if p != null:
			pts.append(Vector3(p.x(), p.y(), p.z()))

	return pts

## Get the underlying Geom_Curve of the (first) edge with its trimmed parameter bounds.
## Returns [curve, first_param, last_param] or [] if unavailable.
func _edge_curve_with_bounds() -> Array:
	var e := _first_edge()
	if e == null:
		return []
	var first := OcgStandardReal.new()
	var last := OcgStandardReal.new()
	var curve := OcgBRepTool.curve_F(e, first, last)
	if curve == null or curve.is_null():
		return []
	return [curve, first.get_value(), last.get_value()]

func _first_edge() -> OcgTopoDSEdge:
	if _wrapped == null or _wrapped.is_null():
		return null
	if int(_wrapped.shape_type()) == BdgEnums.ShapeType.EDGE:
		return _wrapped
	var exp := OcgTopExpExplorer.from_4(_wrapped, int(BdgEnums.ShapeType.EDGE), int(BdgEnums.ShapeType.SHAPE))
	if exp.more():
		return exp.current()
	return null
