extends BdgMixin1D
## BdgEdge - a 1D curve segment wrapping OcgTopoDSEdge.
## Mirrors build123d/topology/one_d.py Edge.
class_name BdgEdge

func _init(...args) -> void:
	super(args[0] if args.size() == 1 else null)

## radius of an underlying circle or ellipse
func radius() -> float:
	var adaptor := OcgBRepAdaptorCurve.from_g(_wrapped)
	var t := adaptor.get_type()
	if t == OcgEnums.GeomAbs_CurveType.GeomAbs_Circle:
		return adaptor.circle().radius()
	elif t == OcgEnums.GeomAbs_CurveType.GeomAbs_Ellipse:
		return adaptor.ellipse().major_radius()
	push_error("Shape could not be reduced to a circle")
	return 0.0

## center of an underlying circle or ellipse geometry
func arc_center() -> Vector3:
	var adaptor := OcgBRepAdaptorCurve.from_g(_wrapped)
	var t := adaptor.get_type()
	if t == OcgEnums.GeomAbs_CurveType.GeomAbs_Circle:
		return BdgShape._gp_pnt_to_v3(adaptor.circle().position().location())
	elif t == OcgEnums.GeomAbs_CurveType.GeomAbs_Ellipse:
		return BdgShape._gp_pnt_to_v3(adaptor.ellipse().position().location())
	push_error("%d has no arc center" % t)
	return Vector3.ZERO

## linear edge between two points
static func make_line(point1: Vector3, point2: Vector3) -> BdgEdge:
	var mk := OcgBRepBuilderAPIMakeEdge.from_Wm(
		OcgGpPnt.from_6(point1.x, point1.y, point1.z),
		OcgGpPnt.from_6(point2.x, point2.y, point2.z))
	return BdgEdge.new(mk.edge())

## full or partial circle in a plane
static func make_circle(
	radius: float,
	plane: BdgPlane = null,
	start_angle: float = 360.0,
	end_angle: float = 360.0,
) -> BdgEdge:
	if plane == null:
		plane = BdgPlane.XY
	var circ := OcgGpCirc.from_L(_plane_to_ax2(plane), radius)
	if is_equal_approx(start_angle, end_angle):
		var mk := OcgBRepBuilderAPIMakeEdge.from_F(circ)
		return BdgEdge.new(mk.edge())
	else:
		var geom := OcgGCMakeArcOfCircle.from_Zi(circ, deg_to_rad(start_angle), deg_to_rad(end_angle), true)
		var mk := OcgBRepBuilderAPIMakeEdge.from_5(geom.value())
		return BdgEdge.new(mk.edge())

## three point arc
static func make_three_point_arc(p1: Vector3, p2: Vector3, p3: Vector3) -> BdgEdge:
	var mkarc := OcgGCMakeArcOfCircle.from_Z(
		OcgGpPnt.from_6(p1.x, p1.y, p1.z),
		OcgGpPnt.from_6(p2.x, p2.y, p2.z),
		OcgGpPnt.from_6(p3.x, p3.y, p3.z))
	var mk := OcgBRepBuilderAPIMakeEdge.from_5(mkarc.value())
	return BdgEdge.new(mk.edge())

static func make_arc_radius(p1: Vector3, p2: Vector3, radius: float, short_sagitta: bool = true) -> BdgEdge:
	return make_radius_arc(p1, p2, radius, short_sagitta)

## center arc (numeric arc_size in degrees, positive = CCW)
static func make_center_arc(
	center: Vector3,
	radius: float,
	start_angle: float,
	arc_size: float,
	plane: BdgPlane = null,
) -> BdgEdge:
	if plane == null:
		plane = BdgPlane.XY
	if absf(arc_size) >= 360.0:
		var plane2 := BdgPlane.new()
		plane2.origin = center
		plane2.x_dir = plane.x_dir
		plane2.y_dir = plane.y_dir
		plane2.z_dir = plane.z_dir
		return make_circle(radius, plane2)
	var a1 := deg_to_rad(start_angle)
	var a2 := deg_to_rad(start_angle + arc_size)
	var amid := deg_to_rad(start_angle + arc_size * 0.5)
	var xd := plane.x_dir
	var yd := plane.y_dir
	var pt := func(a: float) -> Vector3:
		return center + xd * (radius * cos(a)) + yd * (radius * sin(a))
	return make_three_point_arc(pt.call(a1), pt.call(amid), pt.call(a2))

## radius arc: arc through two points with given radius
static func make_radius_arc(
	start_point: Vector3,
	end_point: Vector3,
	radius: float,
	short_sagitta: bool = true,
) -> BdgEdge:
	var chord := end_point - start_point
	var length := chord.length() / 2.0
	var radius_abs := absf(radius)
	if radius_abs * radius_abs < length * length:
		push_error("Arc radius is not large enough to reach the end point")
		return null
	var sagitta: float
	if short_sagitta:
		sagitta = radius_abs - sqrt(radius_abs * radius_abs - length * length)
	else:
		sagitta = -radius_abs - sqrt(radius_abs * radius_abs - length * length)
	if radius < 0.0:
		sagitta = -sagitta
	return make_sagitta_arc(start_point, end_point, sagitta)

## sagitta arc: arc through two points with given sagitta (arc height from chord)
static func make_sagitta_arc(
	start_point: Vector3,
	end_point: Vector3,
	sagitta: float,
) -> BdgEdge:
	var mid_point := (end_point + start_point) * 0.5
	var chord_dir := (end_point - start_point).normalized()
	var sag_vector := chord_dir * absf(sagitta)
	var rot_axis: Vector3
	if is_zero_approx(start_point.y) and is_zero_approx(end_point.y):
		rot_axis = Vector3(0, 1, 0)
	elif is_zero_approx(start_point.z) and is_zero_approx(end_point.z):
		rot_axis = Vector3(0, 0, 1)
	elif is_zero_approx(start_point.x) and is_zero_approx(end_point.x):
		rot_axis = Vector3(1, 0, 0)
	else:
		var perp := Vector3.UP if absf(chord_dir.y) < 0.999 else Vector3.RIGHT
		rot_axis = chord_dir.cross(perp).normalized()
	var sign := 1.0 if sagitta > 0.0 else -1.0
	var sag_point := mid_point + sag_vector.rotated(rot_axis, sign * PI / 2.0)
	return make_three_point_arc(start_point, sag_point, end_point)

## tangent arc

## tangent arc
static func make_tangent_arc(p1: Vector3, tangent_dir: Vector3, p2: Vector3) -> BdgEdge:
	var mkarc := OcgGCMakeArcOfCircle.from_k(
		OcgGpPnt.from_6(p1.x, p1.y, p1.z),
		OcgGpVec.from_6(tangent_dir.x, tangent_dir.y, tangent_dir.z),
		OcgGpPnt.from_6(p2.x, p2.y, p2.z))
	var mk := OcgBRepBuilderAPIMakeEdge.from_5(mkarc.value())
	return BdgEdge.new(mk.edge())

## bezier curve through control points (optionally rational with weights)
static func make_bezier(control_points: Array, weights: Array = []) -> BdgEdge:
	if control_points.size() < 2:
		push_error("At least two control points must be provided")
		return null
	var poles := OcgNCollectionArray1GpPnt.from_k(1, control_points.size())
	for i in control_points.size():
		var p: Vector3 = control_points[i]
		poles.set_value_v(i + 1, OcgGpPnt.from_6(p.x, p.y, p.z))
	var curve: OcgGeomBezierCurve
	if not weights.is_empty():
		var pw := OcgNCollectionArray1Double.from_k(1, weights.size())
		for i in weights.size():
			pw.set_value_N(i + 1, weights[i])
		curve = OcgGeomBezierCurve.from_u(poles, pw)
	else:
		curve = OcgGeomBezierCurve.from_w(poles)
	var mk := OcgBRepBuilderAPIMakeEdge.from_5(curve)
	return BdgEdge.new(mk.edge())

## spline interpolating through points
static func make_spline(points: Array, tangents: Array = [], scale: bool = true) -> BdgEdge:
	var arr := OcgNCollectionArray1GpPnt.from_k(1, points.size())
	for i in points.size():
		var p: Vector3 = points[i]
		arr.set_value_v(i + 1, OcgGpPnt.from_6(p.x, p.y, p.z))
	var pnts := OcgNCollectionHArray1GpPnt.from_w(arr)
	var interp := OcgGeomAPIInterpolate.from_n(pnts, false, 1e-6)
	if tangents.size() >= 2:
		var t0_v: Vector3 = tangents[0]
		var t1_v: Vector3 = tangents[1]
		var t0 := OcgGpVec.from_6(t0_v.x, t0_v.y, t0_v.z)
		var t1 := OcgGpVec.from_6(t1_v.x, t1_v.y, t1_v.z)
		interp.load_Y(t0, t1, scale)
	interp.perform()
	var mk := OcgBRepBuilderAPIMakeEdge.from_5(interp.curve())
	return BdgEdge.new(mk.edge())

## Create an exact B-spline edge from control points (poles) and knot data.
## Repeated knot values are collapsed into multiplicities.
static func make_bspline(
	control_points: Array,
	knots: Array,
	degree: int = 3,
	periodic: bool = false,
) -> BdgEdge:
	if knots.is_empty():
		push_error("make_bspline needs at least one knot")
		return null
	var unique_knots: Array = [knots[0]]
	var multiplicities: Array = [1]
	for k in knots.slice(1):
		if absf(float(k) - float(unique_knots[-1])) < 1e-6:
			multiplicities[multiplicities.size() - 1] = int(multiplicities[multiplicities.size() - 1]) + 1
		else:
			unique_knots.append(k)
			multiplicities.append(1)
	var poles := OcgNCollectionArray1GpPnt.from_k(1, control_points.size())
	for i in control_points.size():
		var p: Vector3 = control_points[i]
		poles.set_value_v(i + 1, OcgGpPnt.from_6(p.x, p.y, p.z))
	var knots_arr := OcgNCollectionArray1Double.from_k(1, unique_knots.size())
	for i in unique_knots.size():
		knots_arr.set_value_N(i + 1, float(unique_knots[i]))
	var mult_arr := OcgNCollectionArray1Int.from_k(1, multiplicities.size())
	for i in multiplicities.size():
		mult_arr.set_value_Z(i + 1, int(multiplicities[i]))
	var spline := OcgGeomBSplineCurve.from_2(poles, knots_arr, mult_arr, degree, periodic)
	if spline == null:
		push_error("make_bspline failed to create spline geometry")
		return null
	var mk := OcgBRepBuilderAPIMakeEdge.from_5(spline)
	return BdgEdge.new(mk.edge())

## line between two reference edges at a fractional distance (default center)
static func make_mid_way(first: BdgEdge, second: BdgEdge, middle: float = 0.5) -> BdgEdge:
	if first == null or second == null or first.is_null() or second.is_null():
		push_error("make_mid_way: edges must be valid")
		return null
	# flip second edge if parallel and opposite, so the mid-way line isn't truncated
	var flip: bool = first.tangent_at(0.0).dot(second.tangent_at(0.0)) < -1e-6
	var p0 := make_line(
		first.position_at(0.0), second.position_at(1.0 if flip else 0.0)
	).position_at(middle)
	var p1 := make_line(
		first.position_at(1.0), second.position_at(0.0 if flip else 1.0)
	).position_at(middle)
	return make_line(p0, p1)

## full or partial parabola in a plane centered at origin (angle in degrees)
static func make_parabola(
	focal_length: float,
	plane: BdgPlane = null,
	start_angle: float = 0.0,
	end_angle: float = 90.0,
	angular_direction: int = BdgEnums.AngularDirection.COUNTER_CLOCKWISE,
) -> BdgEdge:
	if plane == null:
		plane = BdgPlane.XY
	var parab := OcgGpParab.from_L(_plane_to_ax2(plane), focal_length)
	var geom := OcgGCMakeArcOfParabola.from_v(
		parab,
		deg_to_rad(start_angle),
		deg_to_rad(end_angle),
		angular_direction == BdgEnums.AngularDirection.COUNTER_CLOCKWISE,
	)
	var mk := OcgBRepBuilderAPIMakeEdge.from_5(geom.value())
	return BdgEdge.new(mk.edge())

## full or partial hyperbola in a plane centered at origin (angle in degrees)
static func make_hyperbola(
	x_radius: float,
	y_radius: float,
	plane: BdgPlane = null,
	start_angle: float = 360.0,
	end_angle: float = 360.0,
	angular_direction: int = BdgEnums.AngularDirection.COUNTER_CLOCKWISE,
) -> BdgEdge:
	if plane == null:
		plane = BdgPlane.XY
	var ax1 := OcgGpAx1.from_n(_plane_to_pnt(plane), _plane_to_dir(plane))
	var hypr: OcgGpHypr
	var correction_angle := 0.0
	if y_radius > x_radius:
		correction_angle = 90.0 * PI / 180.0
		hypr = OcgGpHypr.from_l(_plane_to_ax2(plane), y_radius, x_radius)
		hypr = hypr.rotated(ax1, correction_angle)
	else:
		hypr = OcgGpHypr.from_l(_plane_to_ax2(plane), x_radius, y_radius)
	if is_equal_approx(start_angle, end_angle):
		var mk := OcgBRepBuilderAPIMakeEdge.from_Q(hypr)
		return BdgEdge.new(mk.edge())
	var a1 := deg_to_rad(start_angle) - correction_angle
	var a2 := deg_to_rad(end_angle) - correction_angle
	var geom := OcgGCMakeArcOfHyperbola.from_n(
		hypr,
		a1,
		a2,
		angular_direction == BdgEnums.AngularDirection.COUNTER_CLOCKWISE,
	)
	var mk := OcgBRepBuilderAPIMakeEdge.from_5(geom.value())
	return BdgEdge.new(mk.edge())

## full or partial ellipse in a plane (angle in degrees, CCW positive)
static func make_ellipse(
	x_radius: float,
	y_radius: float,
	plane: BdgPlane = null,
	start_angle: float = 360.0,
	end_angle: float = 360.0,
) -> BdgEdge:
	if plane == null:
		plane = BdgPlane.XY
	var ax1 := OcgGpAx1.from_n(_plane_to_pnt(plane), _plane_to_dir(plane))
	var correction_angle := 0.0
	var ellipse_gp: OcgGpElips
	if y_radius > x_radius:
		correction_angle = 90.0 * PI / 180.0
		ellipse_gp = OcgGpElips.from_l(_plane_to_ax2(plane), y_radius, x_radius)
		ellipse_gp = ellipse_gp.rotated(ax1, correction_angle)
	else:
		ellipse_gp = OcgGpElips.from_l(_plane_to_ax2(plane), x_radius, y_radius)
	if is_equal_approx(start_angle, end_angle):
		var mk := OcgBRepBuilderAPIMakeEdge.from_y(ellipse_gp)
		return BdgEdge.new(mk.edge())
	else:
		var a1 := deg_to_rad(start_angle) - correction_angle
		var a2 := deg_to_rad(end_angle) - correction_angle
		if a2 <= a1:
			a2 += 2.0 * PI
		var geom := OcgGCMakeArcOfEllipse.from_3(ellipse_gp, a1, a2, true)
		var mk := OcgBRepBuilderAPIMakeEdge.from_5(geom.value())
		return BdgEdge.new(mk.edge())

## helix wrapped around a cylindrical (or conical when angle != 0) surface
static func make_helix(
	pitch: float,
	height: float,
	radius: float,
	center: Vector3 = Vector3.ZERO,
	normal: Vector3 = Vector3.BACK,
	angle: float = 0.0,
	lefthand: bool = false,
) -> BdgEdge:
	var ax3 := OcgGpAx3.from_S(_pnt(center), _dir(normal), OcgGpDir.from_6(1.0, 0.0, 0.0))
	var surf: OcgGeomSurface
	if is_zero_approx(angle):
		surf = OcgGeomCylindricalSurface.from_O(ax3, radius)
	else:
		surf = OcgGeomConicalSurface.from_6(ax3, deg_to_rad(angle), radius)
	var line_sign := -1.0 if lefthand else 1.0
	var line_dir := Vector3(line_sign * 2.0 * PI, pitch, 0.0).normalized()
	var line_len := (height / line_dir.y) / cos(deg_to_rad(angle))
	var helix_line := OcgGeom2dLine.from_K(OcgGpPnt2d.new(), OcgGpDir2d.from_V(line_dir.x, line_dir.y))
	var helix_curve := OcgGeom2dTrimmedCurve.from_S(helix_line, 0.0, line_len)
	var mk := OcgBRepBuilderAPIMakeEdge.from_H(helix_curve, surf)
	var edge := mk.edge()
	OcgBRepLib.build_curves3d_5(edge, 1e-9, 14, 0)
	return BdgEdge.new(edge)

## double tangent arc: smooth curve from p1 (along tangent1) to p2 (along tangent2)
static func make_double_tangent_arc(p1: Vector3, tangent1: Vector3, p2: Vector3, tangent2: Vector3) -> BdgEdge:
	var arr := OcgNCollectionArray1GpPnt.from_k(1, 2)
	arr.set_value_v(1, OcgGpPnt.from_6(p1.x, p1.y, p1.z))
	arr.set_value_v(2, OcgGpPnt.from_6(p2.x, p2.y, p2.z))
	var pnts := OcgNCollectionHArray1GpPnt.from_w(arr)
	var interp := OcgGeomAPIInterpolate.from_n(pnts, false, 1e-6)
	var t1 := OcgGpVec.from_6(tangent1.x, tangent1.y, tangent1.z)
	var t2 := OcgGpVec.from_6(tangent2.x, tangent2.y, tangent2.z)
	interp.load_Y(t1, t2, true)
	interp.perform()
	if not interp.is_done():
		push_error("make_double_tangent_arc: interpolation failed")
		return null
	var mk := OcgBRepBuilderAPIMakeEdge.from_5(interp.curve())
	return BdgEdge.new(mk.edge())

## jern arc: circular arc from start point along initial tangent with given radius and arc_size (degrees)
static func make_jern_arc(
	start: Vector3,
	tangent: Vector3,
	radius: float,
	arc_size: float,
	plane: BdgPlane = null,
) -> BdgEdge:
	var p := plane if plane != null else BdgPlane.XY
	var normal := p.z_dir
	var t := tangent.normalized()
	var perp := normal.cross(t).normalized()
	if arc_size < 0.0:
		perp = -perp
	var center := start + perp * absf(radius)
	var from_center := start - center
	var dx := from_center.dot(p.x_dir)
	var dy := from_center.dot(p.y_dir)
	var start_angle := rad_to_deg(atan2(dy, dx))
	return make_center_arc(center, absf(radius), start_angle, arc_size, p)

## elliptical center arc: arc of an ellipse around center
static func make_elliptical_center_arc(
	center: Vector3,
	x_radius: float,
	y_radius: float,
	start_angle: float = 0.0,
	end_angle: float = 90.0,
	plane: BdgPlane = null,
	angular_direction: int = BdgEnums.AngularDirection.COUNTER_CLOCKWISE,
) -> BdgEdge:
	var p := BdgPlane.new()
	if plane != null:
		p.origin = center
		p.x_dir = plane.x_dir
		p.y_dir = plane.y_dir
		p.z_dir = plane.z_dir
	else:
		p.origin = center
		p.x_dir = Vector3.RIGHT
		p.y_dir = Vector3.UP
		p.z_dir = Vector3.BACK
	return make_ellipse(x_radius, y_radius, p, start_angle, end_angle)

## Trim this edge to parameter range (0..1)
func trim(start_param: float, end_param: float) -> BdgEdge:
	var c := _edge_curve_with_bounds()
	if c.is_empty():
		return null
	var curve: OcgGeomCurve = c[0]
	var lo: float = c[1]
	var hi: float = c[2]
	var u1 := lo + clampf(start_param, 0.0, 1.0) * (hi - lo)
	var u2 := lo + clampf(end_param, 0.0, 1.0) * (hi - lo)
	var mk := OcgBRepBuilderAPIMakeEdge.from_A(curve, u1, u2)
	return BdgEdge.new(mk.edge())

## Find geometric intersections between this edge and another edge.
## Returns Array of Dictionaries: [{"point": Vector3, "param_self": float, "param_other": float, "distance": float}]
func find_intersection(other: BdgEdge, tolerance: float = 1e-5) -> Array:
	var results: Array = []
	var c1 := _edge_curve_with_bounds()
	var c2 := other._edge_curve_with_bounds()
	if c1.is_empty() or c2.is_empty():
		return results
	var curve1: OcgGeomCurve = c1[0]
	var curve2: OcgGeomCurve = c2[0]
	var ext := OcgGeomAPIExtremaCurveCurve.from_o(
		curve1, curve2, c1[1], c1[2], c2[1], c2[2]
	)
	if ext == null:
		return results
	for i in range(1, ext.nb_extrema() + 1):
		var d := ext.distance(i)
		if d <= tolerance:
			var p1 := OcgGpPnt.new()
			var p2 := OcgGpPnt.new()
			ext.points(i, p1, p2)
			var u1 := OcgStandardReal.new()
			var u2 := OcgStandardReal.new()
			ext.parameters(i, u1, u2)
			var param_self: float = (u1.get_value() - c1[1]) / (c1[2] - c1[1]) if c1[2] != c1[1] else 0.0
			var param_other: float = (u2.get_value() - c2[1]) / (c2[2] - c2[1]) if c2[2] != c2[1] else 0.0
			results.append({
				"point": BdgShape._gp_pnt_to_v3(p1),
				"param_self": param_self,
				"param_other": param_other,
				"distance": d,
			})
	return results

## Project this edge onto a target shape surface along a direction.
## Returns Array of BdgEdge projected onto the shape.
func project_to_shape(target: BdgShape, direction: Vector3 = Vector3.ZERO) -> Array:
	if is_null() or target == null or target.is_null():
		return []
	var proj_dir := direction.normalized() if direction != Vector3.ZERO else Vector3.BACK
	var d := OcgGpDir.from_6(proj_dir.x, proj_dir.y, proj_dir.z)
	var proj := OcgBRepProjProjection.from_X(_wrapped, target._wrapped, d)
	var edges_out: Array = []
	if proj != null and proj.is_done():
		while proj.more():
			var wire := proj.current()
			var w_shape := BdgShape.cast(wire)
			for e in w_shape.edges():
				edges_out.append(e)
			proj.next()
	return edges_out

static func _plane_to_pnt(plane: BdgPlane) -> OcgGpPnt:
	return OcgGpPnt.from_6(plane.origin.x, plane.origin.y, plane.origin.z)

static func _plane_to_dir(plane: BdgPlane) -> OcgGpDir:
	return OcgGpDir.from_6(plane.z_dir.x, plane.z_dir.y, plane.z_dir.z)

static func _pnt(p: Vector3) -> OcgGpPnt:
	return OcgGpPnt.from_6(p.x, p.y, p.z)

static func _dir(d: Vector3) -> OcgGpDir:
	return OcgGpDir.from_6(d.x, d.y, d.z)

static func _plane_to_ax2(plane: BdgPlane) -> OcgGpAx2:
	var pnt := OcgGpPnt.from_6(plane.origin.x, plane.origin.y, plane.origin.z)
	var n := OcgGpDir.from_6(plane.z_dir.x, plane.z_dir.y, plane.z_dir.z)
	var vx := OcgGpDir.from_6(plane.x_dir.x, plane.x_dir.y, plane.x_dir.z)
	return OcgGpAx2.from_S(pnt, n, vx)
