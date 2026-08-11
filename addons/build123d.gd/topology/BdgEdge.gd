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
	var pnts := OcgNCollectionHArray1GpPnt.from_k(1, points.size())
	var arr := pnts.array1()
	for i in points.size():
		var p: Vector3 = points[i]
		arr.set_value_v(i + 1, OcgGpPnt.from_6(p.x, p.y, p.z))
	var interp := OcgGeomAPIInterpolate.from_n(pnts, false, 1e-6)
	interp.perform()
	var mk := OcgBRepBuilderAPIMakeEdge.from_5(interp.curve())
	return BdgEdge.new(mk.edge())

static func _plane_to_ax2(plane: BdgPlane) -> OcgGpAx2:
	var pnt := OcgGpPnt.from_6(plane.origin.x, plane.origin.y, plane.origin.z)
	var n := OcgGpDir.from_6(plane.z_dir.x, plane.z_dir.y, plane.z_dir.z)
	var vx := OcgGpDir.from_6(plane.x_dir.x, plane.x_dir.y, plane.x_dir.z)
	return OcgGpAx2.from_S(pnt, n, vx)
