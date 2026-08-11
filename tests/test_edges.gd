extends SceneTree

var checks := 0
var failures := 0

func check(cond: bool, name: String) -> void:
	checks += 1
	if not cond:
		failures += 1
		printerr("FAIL: " + name)
	else:
		print("ok: " + name)

func _init():
	_test_ellipse()
	_test_helix()
	_test_center_arc()
	_test_radius_sagitta_arc()
	_test_wire_factories()
	_test_face_factories()
	_test_slots()
	_test_objects()
	_test_operations()
	_test_fillet()
	_test_bspline_loft()
	print("edges tests: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)

func _test_ellipse() -> bool:
	var e := BdgEdge.make_ellipse(10.0, 5.0, BdgPlane.XY)
	check(e != null, "make_ellipse creates edge")
	check(e.is_closed(), "full ellipse is closed")
	var arc := BdgEdge.make_ellipse(10.0, 5.0, BdgPlane.XY, 0.0, 90.0)
	check(arc != null and not arc.is_closed(), "partial ellipse not closed")
	var e_y := BdgEdge.make_ellipse(5.0, 10.0, BdgPlane.XY)
	check(e_y != null and e_y.is_closed(), "y-major ellipse created")
	return failures == 0

func _test_helix() -> bool:
	var h := BdgEdge.make_helix(2.0, 10.0, 5.0)
	check(h != null, "helix creates edge")
	check(h.length() > 0.0, "helix has length")
	var hl := BdgEdge.make_helix(2.0, 10.0, 5.0, Vector3.ZERO, Vector3.BACK, 0.0, true)
	check(hl != null and hl.length() > 0.0, "lefthand helix created")
	return failures == 0

func _test_center_arc() -> bool:
	var a := BdgEdge.make_center_arc(Vector3.ZERO, 10.0, 0.0, 90.0)
	check(a != null, "center arc creates edge")
	check(absf(a.length() - 5.0 * PI) < 0.001, "90deg arc length ~= pi*r/2, got %f" % a.length())
	var a2 := BdgEdge.make_center_arc(Vector3.ZERO, 10.0, 0.0, 360.0)
	check(a2.is_closed(), "360 center arc closed")
	return failures == 0

func _test_radius_sagitta_arc() -> bool:
	var r := BdgEdge.make_radius_arc(Vector3(-5, 0, 0), Vector3(5, 0, 0), 10.0)
	check(r != null, "radius arc created")
	check(absf(r.length() - 10.0 * PI / 3.0) < 0.01, "radius arc length ok, got %f" % r.length())
	var s := BdgEdge.make_sagitta_arc(Vector3(-5, 0, 0), Vector3(5, 0, 0), 2.0)
	check(s != null, "sagitta arc created")
	return failures == 0

func _test_wire_factories() -> bool:
	var w := BdgWire.make_ellipse(8.0, 4.0, BdgPlane.XY)
	check(w != null and w.is_closed(), "wire ellipse closed")
	var h := BdgWire.make_helix(1.0, 5.0, 3.0)
	check(h != null and h.length() > 0.0, "wire helix created")
	var sp := BdgWire.make_spline([Vector3.ZERO, Vector3(1, 2, 0), Vector3(3, 0, 0)])
	check(sp != null, "wire spline created")
	var bz := BdgWire.make_bezier([Vector3.ZERO, Vector3(1, 3, 0), Vector3(3, 0, 0)])
	check(bz != null, "wire bezier created")
	return failures == 0

func _test_face_factories() -> bool:
	var poly := BdgFace.make_regular_polygon(10.0, 6)
	check(poly != null and not poly.is_null(), "regular polygon face")
	check(absf(poly.area() - 3.0 * sqrt(3.0) / 2.0 * 100.0) < 0.1, "hexagon area, got %f" % poly.area())
	var tri := BdgFace.make_triangle(10.0, 8.0)
	check(tri != null and absf(tri.area() - 40.0) < 0.01, "triangle area")
	var trap := BdgFace.make_trapezoid(10.0, 8.0, 2.0, 2.0)
	check(trap != null and absf(trap.area() - 64.0) < 0.01, "trapezoid area, got %f" % trap.area())
	var rr := BdgFace.make_rounded_rect(20.0, 10.0, 3.0)
	check(rr != null, "rounded rect created")
	var rr_area := rr.area()
	var expected := 200.0 - (4.0 - PI) * 9.0
	check(absf(rr_area - expected) < 0.1, "rounded rect area, got %f expected %f" % [rr_area, expected])
	var el := BdgFace.make_ellipse(8.0, 4.0)
	check(el != null and absf(el.area() - PI * 32.0) < 0.1, "ellipse face area")
	return failures == 0

func _test_slots() -> bool:
	var s := BdgFace.make_slot_center_to_center(10.0, 4.0)
	check(s != null and not s.is_null(), "slot c2c created")
	var slot_area := s.area()
	var expected := 40.0 + PI * 4.0
	check(absf(slot_area - expected) < 0.1, "slot c2c area, got %f expected %f" % [slot_area, expected])
	var scp := BdgFace.make_slot_center_point(Vector3(1, 2, 0), Vector3(6, 2, 0), 4.0)
	check(scp != null, "slot center point created")
	var sa := BdgFace.make_slot_arc(Vector3.ZERO, 10.0, 0.0, 90.0, 4.0)
	check(sa != null and not sa.is_null(), "slot arc created")
	var sa_area := sa.area()
	var sa_expected := (PI / 4.0) * (144.0 - 64.0) + 2.0 * PI * 4.0 / 2.0
	check(absf(sa_area - sa_expected) < 0.5, "slot arc area, got %f expected %f" % [sa_area, sa_expected])
	return failures == 0

func _test_objects() -> bool:
	var ta := BdgThreePointArc.new(Vector3(-5, 0, 0), Vector3(0, 5, 0), Vector3(5, 0, 0))
	check(ta != null and ta.edges().size() == 1, "ThreePointArc object")
	var ca := BdgCenterArc.new(Vector3.ZERO, 10.0, 0.0, 90.0)
	check(ca != null and absf(ca.edges()[0].length() - 5.0 * PI) < 0.01, "CenterArc object length")
	var ra := BdgRadiusArc.new(Vector3(-5, 0, 0), Vector3(5, 0, 0), 10.0)
	check(ra != null, "RadiusArc object")
	var sag := BdgSagittaArc.new(Vector3(-5, 0, 0), Vector3(5, 0, 0), 2.0)
	check(sag != null, "SagittaArc object")
	var sp := BdgSpline.new([Vector3.ZERO, Vector3(1, 2, 0), Vector3(3, 0, 0)])
	check(sp != null, "Spline object")
	var bz := BdgBezier.new([Vector3.ZERO, Vector3(1, 3, 0), Vector3(3, 0, 0)])
	check(bz != null, "Bezier object")
	var hx := BdgHelix.new(1.0, 5.0, 3.0)
	check(hx != null and hx.edges()[0].length() > 0.0, "Helix object")
	var el := BdgEllipse.new(8.0, 4.0)
	check(el != null and el.faces().size() >= 1, "Ellipse sketch object")
	var rp := BdgRegularPolygon.new(10.0, 6)
	check(rp != null, "RegularPolygon sketch object")
	var rr := BdgRectangleRounded.new(20.0, 10.0, 3.0)
	check(rr != null, "RectangleRounded sketch object")
	var tr := BdgTriangle.new(10.0, 8.0)
	check(tr != null, "Triangle sketch object")
	var tp := BdgTrapezoid.new(10.0, 8.0, 2.0, 2.0)
	check(tp != null, "Trapezoid sketch object")
	var so := BdgSlotOverall.new(14.0, 4.0)
	check(so != null, "SlotOverall sketch object")
	var scc := BdgSlotCenterToCenter.new(10.0, 4.0)
	check(scc != null, "SlotCenterToCenter sketch object")
	var scp := BdgSlotCenterPoint.new(Vector3(1, 2, 0), Vector3(6, 2, 0), 4.0)
	check(scp != null, "SlotCenterPoint sketch object")
	var arc_edge := BdgEdge.make_center_arc(Vector3.ZERO, 10.0, 0.0, 90.0)
	var sarc := BdgSlotArc.new(arc_edge, 4.0)
	check(sarc != null, "SlotArc sketch object")
	return failures == 0

func _test_operations() -> bool:
	var profile := BdgFace.make_polygon([
		Vector3(9.0, 0.0, -1.0), Vector3(11.0, 0.0, -1.0),
		Vector3(11.0, 0.0, 1.0), Vector3(9.0, 0.0, 1.0),
	])
	var rev180: BdgShape = profile.revolve(180.0, BdgAxis.Z)
	check(rev180 != null and not rev180.is_null(), "revolve face 180 about Z")
	if rev180 != null:
		var s180 := rev180.solids()
		check(not s180.is_empty(), "revolved produces solid")
		if not s180.is_empty():
			check(absf(s180[0].volume() - 40.0 * PI) < 2.0, "revolve 180 volume %.2f" % s180[0].volume())

	var rev360: BdgShape = profile.revolve(360.0, BdgAxis.Z)
	check(rev360 != null and not rev360.is_null(), "revolve 360 produces solid")
	if rev360 != null:
		var s360 := rev360.solids()
		check(s360.size() == 1, "revolve 360 gives one solid")
		if not s360.is_empty():
			check(absf(s360[0].volume() - 80.0 * PI) < 2.0, "revolve 360 torus volume %.2f" % s360[0].volume())

	var thick := BdgFace.make_rect(10.0, 5.0)
	var thickened: BdgShape = thick.thicken(2.0)
	check(thickened != null, "thicken rect face")
	if thickened != null:
		var solids := thickened.solids()
		check(not solids.is_empty(), "thicken produced solids")

	var sweep_profile := BdgFace.make_circle(2.0)
	var sweep_path := BdgWire.make_polygon([Vector3.ZERO, Vector3(0, 0, 20.0)], false)
	var swept: BdgShape = sweep_profile.sweep(sweep_path)
	check(swept != null and not swept.is_null(), "sweep circle along line")

	var box := BdgSolid.new(OcgBRepPrimAPIMakeBox.from_6(10.0, 10.0, 10.0).solid())
	var sect := box.section(BdgPlane.XY)
	check(sect.size() >= 1, "section box with plane, got %d edges" % sect.size())

	var wire := BdgWire.make_rect(10.0, 5.0)
	var off := wire.offset_2d(1.0)
	check(off != null, "offset_2d rect outward")
	if off != null:
		check(off.length() > wire.length(), "offset wire longer, %f vs %f" % [off.length(), wire.length()])

	var op_rev := BdgOperations.revolve(profile, 180.0, BdgAxis.Z)
	check(op_rev != null, "BdgOperations.revolve")

	return failures == 0

func _test_fillet() -> bool:
	var wire := BdgWire.make_rect(10.0, 5.0)
	var fw := wire.fillet_2d(1.0)
	check(fw != null and fw.is_closed(), "fillet_2d stays closed")
	if fw != null:
		check(fw.edges().size() == 8, "fillet_2d all corners -> 8 edges (4 arcs + 4 lines)")
		check(fw.length() < wire.length(), "fillet_2d shortens wire, %.3f vs %.3f" % [fw.length(), wire.length()])
		var corners := fw.vertices()
		check(corners.size() == 8, "filleted wire has 8 vertices")

	var one := wire.fillet_2d(1.0, [Vector3(-5.0, -2.5, 0.0)])
	check(one != null and one.edges().size() == 5, "single-corner fillet -> 5 edges")

	var pl := BdgPlane.new()
	pl.origin = Vector3(0.0, 0.0, 5.0)
	var w3 := BdgWire.make_rect(10.0, 5.0, pl)
	var fw3 := w3.fillet_2d(1.0)
	check(fw3 != null and fw3.is_closed() and fw3.edges().size() == 8, "fillet_2d in offset plane")

	var open := BdgWire.make_polygon([Vector3(0, 0, 0), Vector3(10, 0, 0), Vector3(10, 5, 0), Vector3(5, 5, 0)], false)
	var fw4 := open.fillet_2d(1.0)
	check(fw4 != null and not fw4.is_closed() and fw4.edges().size() == 5, "fillet_2d open wire -> 5 edges, stays open")

	return failures == 0

func _test_bspline_loft() -> bool:
	var b := BdgEdge.make_bspline(
		[Vector3(0, 0, 0), Vector3(0, 5, 0), Vector3(5, 5, 0), Vector3(5, 0, 0)],
		[0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0],
		3, false)
	check(b != null and b.geom_type() == BdgEnums.GeomType.BSPLINE, "make_bspline creates bspline edge")
	if b != null:
		check(b.position_at(0.5).distance_to(Vector3(2.5, 3.75, 0)) < 1e-3, "bspline interpolates approx shape")

	var wb := BdgWire.make_bspline(
		[Vector3(0, 0, 0), Vector3(0, 5, 0), Vector3(5, 5, 0), Vector3(5, 0, 0)],
		[0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0],
		3, false)
	check(wb != null, "BdgWire.make_bspline creates wire")

	var bottom := BdgWire.make_rect(10.0, 10.0).translate(Vector3(0, 0, 0)) as BdgWire
	var top := BdgWire.make_rect(5.0, 5.0).translate(Vector3(0, 0, 20.0)) as BdgWire
	var lofted := BdgSolid.make_loft([bottom, top])
	check(lofted != null, "make_loft two rects")
	if lofted != null:
		var v: float = lofted.volume()
		check(absf(v - 1166.6667) < 1.0, "loft frustum volume %.2f" % v)
		var open_loft := BdgShape.make_loft([bottom, top], false, false)
		check(open_loft != null and open_loft.solids().is_empty(), "shell loft produces no solids")

	var apex := BdgSolid.make_loft([bottom, BdgVertex.make_vertex(Vector3(0, 0, 10.0))])
	check(apex != null, "loft with apex vertex")

	return failures == 0