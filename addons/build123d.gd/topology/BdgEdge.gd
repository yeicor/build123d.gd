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
	var ccw := arc_size >= 0.0
	var a1 := deg_to_rad(start_angle)
	var a2 := deg_to_rad(start_angle + arc_size)
	var plane2 := BdgPlane.new()
	plane2.origin = center
	plane2.x_dir = plane.x_dir
	plane2.y_dir = plane.y_dir
	plane2.z_dir = plane.z_dir
	var circ := OcgGpCirc.from_L(_plane_to_ax2(plane2), radius)
	var sense := true
	var alpha1 := a1
	var alpha2 := a2
	if ccw:
		if alpha2 <= alpha1:
			alpha2 += 2.0 * PI
	else:
		alpha1 = a2
		alpha2 = a1
		sense = false
	var geom := OcgGCMakeArcOfCircle.from_Zi(circ, alpha1, alpha2, sense)
	var mk := OcgBRepBuilderAPIMakeEdge.from_5(geom.value())
	return BdgEdge.new(mk.edge())

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
	var perp := Vector3.UP if absf(chord_dir.y) < 0.999 else Vector3.RIGHT
	var rot_axis := chord_dir.cross(perp).normalized()
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
static func make_spline(points: Array) -> BdgEdge:
	var arr := OcgNCollectionArray1GpPnt.from_k(1, points.size())
	for i in points.size():
		var p: Vector3 = points[i]
		arr.set_value_v(i + 1, OcgGpPnt.from_6(p.x, p.y, p.z))
	var pnts := OcgNCollectionHArray1GpPnt.from_w(arr)
	var interp := OcgGeomAPIInterpolate.from_n(pnts, false, 1e-6)
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
