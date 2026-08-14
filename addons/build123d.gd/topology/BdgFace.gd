extends BdgShape
## BdgFace - a 2D bounded surface wrapping OcgTopoDSFace.
## Mirrors build123d/topology/two_d.py Face.
class_name BdgFace

func _init(...args) -> void:
	super(args[0] if args.size() == 1 else null)

## create a face from an outer wire with optional hole wires
static func make_from_wires(outer_wire: BdgWire, inner_wires: Array = []) -> BdgFace:
	if outer_wire == null or outer_wire._wrapped == null or not outer_wire.is_closed():
		push_error("Face can only be created with closed wires")
		return null
	var mk := OcgBRepBuilderAPIMakeFace.from_y(outer_wire._wrapped, true)
	for w in inner_wires:
		if w is BdgShape and w._wrapped != null and not w.is_null():
			mk.add(w._wrapped)
		elif w is OcgTopoDSWire and not w.is_null():
			mk.add(w)
	if mk.is_done():
		var face := mk.face()
		var sf := OcgShapeFixFace.from_a(face)
		sf.fix_orientation_g()
		return BdgFace.new(sf.face())
	return null

## create a rectangle face centered on origin of plane
static func make_rect(width: float, height: float, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var ax3 := OcgGpAx3.from_v(BdgEdge._plane_to_ax2(plane))
	var pln := OcgGpPln.from_k(ax3)
	var mk := OcgBRepBuilderAPIMakeFace.from_A(pln, -width * 0.5, width * 0.5, -height * 0.5, height * 0.5)
	return BdgFace.new(mk.face())

## create a circle face in a plane
static func make_circle(radius: float, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var wire := BdgWire.make_circle(radius, plane)
	return make_from_wires(wire)

## create an elliptical face in a plane
static func make_ellipse(x_radius: float, y_radius: float, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var wire := BdgWire.make_ellipse(x_radius, y_radius, plane)
	return make_from_wires(wire)

## create a polygon face from a list of points in a plane
static func make_polygon(points: Array, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var wire := BdgWire.make_polygon(points, true)
	return make_from_wires(wire)

## create a regular polygon face (radius is the circumradius)
static func make_regular_polygon(radius: float, side_count: int, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var pts: Array = []
	for i in side_count:
		var ang := float(i) * 2.0 * PI / float(side_count)
		var local := Vector3(cos(ang), sin(ang), 0.0) * radius
		pts.append(plane.origin + plane.x_dir * local.x + plane.y_dir * local.y)
	return make_polygon(pts, plane)

## create a 2D slot face with semicircular ends
static func make_slot(length: float, width: float, rotation_deg: float = 0.0) -> BdgFace:
	var r := width * 0.5
	var d := maxf(0.0, (length - width) * 0.5)
	var rot_rad := deg_to_rad(rotation_deg)
	
	var p1 := Vector3(-d, -r, 0.0).rotated(Vector3.FORWARD, rot_rad)
	var p2 := Vector3(d, -r, 0.0).rotated(Vector3.FORWARD, rot_rad)
	var p3 := Vector3(d, r, 0.0).rotated(Vector3.FORWARD, rot_rad)
	var p4 := Vector3(-d, r, 0.0).rotated(Vector3.FORWARD, rot_rad)
	var arc1_mid := Vector3(d + r, 0.0, 0.0).rotated(Vector3.FORWARD, rot_rad)
	var arc2_mid := Vector3(-d - r, 0.0, 0.0).rotated(Vector3.FORWARD, rot_rad)
	
	var e1 := BdgEdge.make_line(p1, p2)
	var e2 := BdgEdge.make_three_point_arc(p2, arc1_mid, p3)
	var e3 := BdgEdge.make_line(p3, p4)
	var e4 := BdgEdge.make_three_point_arc(p4, arc2_mid, p1)
	
	var w := BdgWire.make_wire([e1, e2, e3, e4])
	return make_from_wires(w)

## create an isosceles triangle face (apex centered, base horizontal)
static func make_triangle(base: float, height: float, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var hb := base / 2.0
	var origin: Vector3 = plane.origin
	var x: Vector3 = plane.x_dir
	var y: Vector3 = plane.y_dir
	var pts := [
		origin + x * -hb,
		origin + x * hb,
		origin + y * height,
	]
	return make_polygon(pts, plane)

## create a trapezoid face
static func make_trapezoid(width: float, height: float, left_inset: float, right_inset: float, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var hw := width / 2.0
	var origin: Vector3 = plane.origin
	var x: Vector3 = plane.x_dir
	var y: Vector3 = plane.y_dir
	var pts := [
		origin + x * -hw,
		origin + x * hw,
		origin + x * (hw - right_inset) + y * height,
		origin + x * (-hw + left_inset) + y * height,
	]
	return make_polygon(pts, plane)

## create a rounded rectangle face
static func make_rounded_rect(width: float, height: float, radius: float, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var r := minf(minf(width, height) * 0.5, maxf(radius, 0.0))
	var hw := width / 2.0
	var hh := height / 2.0
	var origin: Vector3 = plane.origin
	var x: Vector3 = plane.x_dir
	var y: Vector3 = plane.y_dir
	var up: Vector3 = plane.z_dir

	var loc = func(u: float, v: float) -> Vector3:
		return origin + x * u + y * v

	var edges: Array = []
	if r <= 0.0:
		return make_rect(width, height, plane)
	# 4 straight segments + 4 quarter arcs, CCW starting at bottom-left
	edges.append(BdgEdge.make_line(loc.call(hw - r, -hh), loc.call(-hw + r, -hh)))
	edges.append(_quarter_arc(loc.call(-hw + r, -hh), loc.call(-hw, -hh + r), loc.call(-hw + r, -hh + r), x, y, plane))
	edges.append(BdgEdge.make_line(loc.call(-hw, -hh + r), loc.call(-hw, hh - r)))
	edges.append(_quarter_arc(loc.call(-hw, hh - r), loc.call(-hw + r, hh), loc.call(-hw + r, hh - r), x, y, plane))
	edges.append(BdgEdge.make_line(loc.call(-hw + r, hh), loc.call(hw - r, hh)))
	edges.append(_quarter_arc(loc.call(hw - r, hh), loc.call(hw, hh - r), loc.call(hw - r, hh - r), x, y, plane))
	edges.append(BdgEdge.make_line(loc.call(hw, hh - r), loc.call(hw, -hh + r)))
	edges.append(_quarter_arc(loc.call(hw, -hh + r), loc.call(hw - r, -hh), loc.call(hw - r, -hh + r), x, y, plane))
	var wire := BdgWire.make_wire(edges)
	return make_from_wires(wire)

## create a slot face (rounded ends) from an overall length and width
static func make_slot_center_to_center(center_to_center: float, height: float, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var r := height / 2.0
	var hh := center_to_center / 2.0
	var origin: Vector3 = plane.origin
	var x: Vector3 = plane.x_dir
	var y: Vector3 = plane.y_dir
	var up: Vector3 = plane.z_dir

	var loc = func(u: float, v: float) -> Vector3:
		return origin + x * u + y * v

	var edges: Array = []
	edges.append(BdgEdge.make_line(loc.call(hh, -r), loc.call(-hh, -r)))
	edges.append(BdgEdge.make_center_arc(loc.call(-hh, 0.0), r, -90.0, -180.0, plane))
	edges.append(BdgEdge.make_line(loc.call(-hh, r), loc.call(hh, r)))
	edges.append(BdgEdge.make_center_arc(loc.call(hh, 0.0), r, -90.0, 180.0, plane))
	var wire := BdgWire.make_wire(edges)
	return make_from_wires(wire)

## create a slot centered at `center`, symmetric, with an end arc centered at `point`
static func make_slot_center_point(center: Vector3, point: Vector3, height: float, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var d := point - center
	var dist := d.length()
	if dist <= 1e-6:
		push_error("Distance between center and point must be greater than 0")
		return null
	var face := make_slot_center_to_center(2.0 * dist, height, plane)
	var ang := rad_to_deg(d.angle_to(plane.x_dir))
	var cross := plane.x_dir.cross(d)
	if cross.dot(plane.z_dir) < 0.0:
		ang = -ang
	var axis := BdgAxis.new(center, plane.z_dir)
	return face.rotated_about(axis, ang).translate(center)

## create a slot along a circular center-line arc (band around the arc)
static func make_slot_arc(center: Vector3, radius: float, start_angle: float, arc_size: float, height: float, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var hw := height / 2.0
	var ro := radius + hw
	var ri := maxf(radius - hw, 0.0)
	var sa := start_angle
	var size := arc_size
	var origin: Vector3 = plane.origin
	var x: Vector3 = plane.x_dir
	var y: Vector3 = plane.y_dir

	var wp = func(ang: float, rr: float) -> Vector3:
		return origin + x * (cos(ang) * rr) + y * (sin(ang) * rr)

	var edges: Array = []
	edges.append(BdgEdge.make_center_arc(center, ro, sa, size, plane))
	var end_pt := wp.call(deg_to_rad(sa + size), radius)
	edges.append(BdgEdge.make_center_arc(end_pt, hw, sa + size, 180.0, plane))
	edges.append(BdgEdge.make_center_arc(center, ri, sa + size, -size, plane))
	var start_pt := wp.call(deg_to_rad(sa), radius)
	edges.append(BdgEdge.make_center_arc(start_pt, hw, sa + 180.0, 180.0, plane))
	var wire := BdgWire.make_wire(edges)
	return make_from_wires(wire)

## quarter circle arc from start to end around center in the plane
static func _quarter_arc(start: Vector3, end: Vector3, center: Vector3, x_dir: Vector3, y_dir: Vector3, plane: BdgPlane) -> BdgEdge:
	var r_vec := start - center
	var ang := atan2(r_vec.dot(y_dir), r_vec.dot(x_dir))
	var e_vec := end - center
	var end_ang := atan2(e_vec.dot(y_dir), e_vec.dot(x_dir))
	var sweep := rad_to_deg(end_ang - ang)
	while sweep > 180.0:
		sweep -= 360.0
	while sweep <= -180.0:
		sweep += 360.0
	return BdgEdge.make_center_arc(center, r_vec.length(), rad_to_deg(ang), sweep, plane)

## area of the face (excluding holes)
func area() -> float:
	if is_null():
		return 0.0
	var props := OcgGPropGProps.new()
	OcgBRepGProp.surface_properties_q(_wrapped, props, true, false)
	return props.mass()

## center of the face
func center() -> Vector3:
	var props := OcgGPropGProps.new()
	OcgBRepGProp.surface_properties_q(_wrapped, props, true, false)
	return BdgShape._gp_pnt_to_v3(props.centre_of_mass())

## normal of the face at its center
func normal() -> Vector3:
	var adaptor := OcgBRepAdaptorSurface.from_K(_wrapped, false)
	var umid := (adaptor.first_u_parameter() + adaptor.last_u_parameter()) / 2.0
	var vmid := (adaptor.first_v_parameter() + adaptor.last_v_parameter()) / 2.0
	var norm := OcgGpVec.new()
	var fprops := OcgBRepGPropFace.from_K(_wrapped, false)
	fprops.normal(umid, vmid, OcgGpPnt.new(), norm)
	return BdgShape._gp_vec_to_v3(norm)

## outer wire of the face
func outer_wire() -> BdgWire:
	if _wrapped == null or _wrapped.is_null():
		return null
	var tf := OcgTopoDSShape.cast_face(_wrapped)
	if tf == null or tf.is_null():
		var ws := wires()
		return ws[0] if not ws.is_empty() else null
	var wt := OcgBRepTools.outer_wire(tf)
	return BdgWire.new(wt) if wt != null and not wt.is_null() else null

## inner wires (hole boundaries) of the face
func inner_wires() -> Array:
	var outer := outer_wire()
	var inners: Array = []
	for w in wires():
		if outer != null and outer._wrapped != null and w._wrapped != null:
			if not w._wrapped.is_same(outer._wrapped):
				inners.append(w)
		else:
			inners.append(w)
	return inners

## Whether the underlying surface is a plane
func is_planar() -> bool:
	return geom_type() == BdgEnums.GeomType.PLANE

## Convert this planar face to a BdgPlane (origin at center, z_dir along normal)
func to_plane() -> BdgPlane:
	var n := normal()
	var c := center()
	var fallback := Vector3.UP if absf(n.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	var x := n.cross(fallback).normalized()
	return BdgPlane.new(c, x, n)

## Evaluate 3D surface point at normalized parameter (u: 0..1, v: 0..1)
func surface_point(u: float, v: float) -> Vector3:
	var adaptor := OcgBRepAdaptorSurface.from_K(_wrapped, false)
	var u_min := adaptor.first_u_parameter()
	var u_max := adaptor.last_u_parameter()
	var v_min := adaptor.first_v_parameter()
	var v_max := adaptor.last_v_parameter()
	var u_val := u_min + clampf(u, 0.0, 1.0) * (u_max - u_min)
	var v_val := v_min + clampf(v, 0.0, 1.0) * (v_max - v_min)
	var pnt: OcgGpPnt = adaptor.value(u_val, v_val)
	return BdgShape._gp_pnt_to_v3(pnt)

## The underlying surface geometry type name (e.g. "PLANE")
func geometry() -> String:
	var st := geom_type()
	match st:
		BdgEnums.GeomType.PLANE: return "PLANE"
		BdgEnums.GeomType.CYLINDER: return "CYLINDER"
		BdgEnums.GeomType.CONE: return "CONE"
		BdgEnums.GeomType.SPHERE: return "SPHERE"
		BdgEnums.GeomType.TORUS: return "TORUS"
		BdgEnums.GeomType.BEZIER: return "BEZIER"
		BdgEnums.GeomType.BSPLINE: return "BSPLINE"
		BdgEnums.GeomType.REVOLUTION: return "REVOLUTION"
		BdgEnums.GeomType.EXTRUSION: return "EXTRUSION"
		BdgEnums.GeomType.OFFSET: return "OFFSET"
	return "OTHER"
