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
	_test_polar_line()
	_test_polyline()
	_test_fillet_polyline()
	_test_double_tangent_arc()
	_test_jern_arc()
	_test_elliptical_center_arc()
	_test_intersecting_line()
	_test_text()
	_test_superellipse()
	_test_polygon()
	_test_mixin1d_methods()
	_test_wire_enhancements()
	_test_edge_enhancements()
	_test_face_enhancements()
	_test_solid_enhancements()
	print("--- Phase 1 Test Results ---")
	print("Checks: %d, Failures: %d" % [checks, failures])
	quit(1 if failures > 0 else 0)

func _test_polar_line() -> void:
	var l := BdgPolarLine.new(10.0, 45.0)
	check(l != null and l.edges().size() == 1, "PolarLine created")
	var e: BdgEdge = l.edges()[0]
	check(absf(e.length() - 10.0) < 1e-4, "PolarLine length 10")
	var expected_end := Vector3(cos(PI / 4.0) * 10.0, sin(PI / 4.0) * 10.0, 0.0)
	check(e.end_point().distance_to(expected_end) < 1e-4, "PolarLine 45deg end point")

	var l2 := BdgPolarLine.new(Vector3(1, 1, 0), 5.0, Vector3.UP)
	check(l2 != null, "PolarLine from start with direction")
	var e2: BdgEdge = l2.edges()[0]
	check(e2.end_point().distance_to(Vector3(1, 6, 0)) < 1e-4, "PolarLine end with direction")

func _test_polyline() -> void:
	var pts := [Vector3(0, 0, 0), Vector3(10, 0, 0), Vector3(10, 10, 0), Vector3(0, 10, 0)]
	var pl := BdgPolyline.new(pts, true)
	check(pl != null, "Polyline created")
	check(pl.edges().size() == 4, "Closed polyline has 4 edges")
	var w := BdgWire.make_wire(pl.edges())
	check(w.is_closed(), "Polyline forms closed wire")
	check(absf(w.length() - 40.0) < 1e-4, "Polyline perimeter 40")

func _test_fillet_polyline() -> void:
	var pts := [Vector3(0, 0, 0), Vector3(20, 0, 0), Vector3(20, 10, 0), Vector3(0, 10, 0)]
	var fp := BdgFilletPolyline.new(pts, 2.0, true)
	check(fp != null, "FilletPolyline created")
	var edges := fp.edges()
	check(edges.size() == 8, "FilletPolyline 4 corners filleted -> 8 edges")
	var w := BdgWire.make_wire(edges)
	check(w != null and w.is_closed(), "FilletPolyline is closed wire")
	check(w.length() < 60.0, "FilletPolyline shorter than sharp perimeter")

func _test_double_tangent_arc() -> void:
	var dta := BdgDoubleTangentArc.new(
		Vector3(0, 0, 0), Vector3(1, 0, 0),
		Vector3(10, 10, 0), Vector3(0, 1, 0)
	)
	check(dta != null, "DoubleTangentArc created")
	var e: BdgEdge = dta.edges()[0]
	check(e != null, "DoubleTangentArc edge exists")
	check(e.start_point().distance_to(Vector3(0, 0, 0)) < 1e-4, "DoubleTangentArc start")
	check(e.end_point().distance_to(Vector3(10, 10, 0)) < 1e-4, "DoubleTangentArc end")
	check(e.tangent_at(0.0).distance_to(Vector3(1, 0, 0)) < 1e-3, "DoubleTangentArc start tangent")
	check(e.tangent_at(1.0).distance_to(Vector3(0, 1, 0)) < 1e-3, "DoubleTangentArc end tangent")

func _test_jern_arc() -> void:
	var ja := BdgJernArc.new(Vector3(0, 0, 0), Vector3(1, 0, 0), 5.0, 90.0)
	check(ja != null, "JernArc created")
	var e: BdgEdge = ja.edges()[0]
	check(absf(e.length() - 2.5 * PI) < 1e-3, "JernArc length 2.5*PI, got %f" % e.length())
	check(e.tangent_at(0.0).distance_to(Vector3(1, 0, 0)) < 1e-3, "JernArc initial tangent")

func _test_elliptical_center_arc() -> void:
	var eca := BdgEllipticalCenterArc.new(Vector3(5, 5, 0), 10.0, 5.0, 0.0, 90.0)
	check(eca != null, "EllipticalCenterArc created")
	var e: BdgEdge = eca.edges()[0]
	check(e.start_point().distance_to(Vector3(15, 5, 0)) < 1e-3, "EllipticalCenterArc start")
	check(e.end_point().distance_to(Vector3(5, 10, 0)) < 1e-3, "EllipticalCenterArc end")

func _test_intersecting_line() -> void:
	var target := BdgEdge.make_line(Vector3(10, -10, 0), Vector3(10, 10, 0))
	var il := BdgIntersectingLine.new(Vector3(0, 0, 0), Vector3(1, 0, 0), target)
	check(il != null, "IntersectingLine created")
	var e: BdgEdge = il.edges()[0]
	check(e.end_point().distance_to(Vector3(10, 0, 0)) < 1e-3, "IntersectingLine hits target at (10,0,0)")

func _test_text() -> void:
	var txt := BdgText.new("B123D", 10.0)
	check(txt != null, "Text object created")
	var faces := txt.faces()
	check(faces.size() >= 5, "Text has at least 5 faces, got %d" % faces.size())
	var bb := txt.bounding_box()
	check(bb.size().x > 0.0 and bb.size().y > 0.0, "Text bounding box valid: %s" % str(bb.size()))

func _test_superellipse() -> void:
	var se := BdgSuperellipse.new(10.0, 5.0, 2.5)
	check(se != null, "Superellipse created")
	var faces := se.faces()
	check(faces.size() >= 1, "Superellipse has face")
	check(faces[0].area() > 0.0, "Superellipse area > 0: %f" % faces[0].area())

func _test_polygon() -> void:
	var pts := [Vector3(0, 0, 0), Vector3(10, 0, 0), Vector3(10, 10, 0), Vector3(0, 10, 0)]
	var poly := BdgPolygon.new(pts)
	check(poly != null, "Polygon sketch object created")
	var faces := poly.faces()
	check(faces.size() == 1, "Polygon has 1 face")
	check(absf(faces[0].area() - 100.0) < 1e-4, "Polygon area 100")

func _test_mixin1d_methods() -> void:
	var c := BdgEdge.make_circle(5.0)
	var n := c.normal_at(0.0)
	check(n.length() > 0.99, "Circle normal is unit vector")
	var kappa := c.curvature_at(0.0)
	check(absf(kappa - 0.2) < 1e-3, "Circle curvature 1/r = 0.2, got %f" % kappa)
	var rad := c.radius_at(0.0)
	check(absf(rad - 5.0) < 1e-3, "Circle radius_at 5.0")
	var samples := c.positions(4)
	check(samples.size() == 4, "positions(4) returns 4 points")
	var locs := c.locations(4)
	check(locs.size() == 4, "locations(4) returns 4 BdgLocations")

func _test_wire_enhancements() -> void:
	var rect_wire := BdgWire.make_rect(20.0, 10.0)
	var chamfered := rect_wire.chamfer_2d(2.0)
	check(chamfered != null and chamfered.is_closed(), "chamfer_2d produced closed wire")
	check(chamfered.edges().size() == 8, "chamfer_2d 4 corners -> 8 edges")

	var open_wire := BdgWire.make_polygon([Vector3(0,0,0), Vector3(10,0,0), Vector3(10,10,0)], false)
	check(not open_wire.is_closed(), "polygon open wire is open")
	var closed := open_wire.close()
	check(closed.is_closed(), "wire.close() makes closed wire")

	var ordered_edges := rect_wire.order_edges()
	check(ordered_edges.size() == 4, "order_edges returns 4 ordered edges")

func _test_edge_enhancements() -> void:
	var e1 := BdgEdge.make_line(Vector3(0, -5, 0), Vector3(0, 5, 0))
	var e2 := BdgEdge.make_line(Vector3(-5, 0, 0), Vector3(5, 0, 0))
	var hits := e1.find_intersection(e2)
	check(hits.size() == 1, "find_intersection found 1 hit")
	if hits.size() == 1:
		check(hits[0]["point"].distance_to(Vector3.ZERO) < 1e-4, "intersection point at origin")

	var full_line := BdgEdge.make_line(Vector3(0, 0, 0), Vector3(100, 0, 0))
	var trimmed := full_line.trim(0.2, 0.8)
	check(trimmed != null, "edge trim")
	check(absf(trimmed.length() - 60.0) < 1e-4, "trimmed length 60, got %f" % trimmed.length())
	check(trimmed.start_point().distance_to(Vector3(20, 0, 0)) < 1e-4, "trimmed start (20,0,0)")

	var sphere := BdgSolid.make_sphere(10.0)
	var proj_edge := BdgEdge.make_line(Vector3(-5, -5, 20), Vector3(5, -5, 20))
	var projected := proj_edge.project_to_shape(sphere, Vector3(0, 0, -1))
	check(projected.size() > 0, "project_to_shape projected edge on sphere")

func _test_face_enhancements() -> void:
	var outer := BdgWire.make_rect(20.0, 20.0)
	var inner := BdgWire.make_circle(3.0)
	var face_with_hole := BdgFace.make_from_wires(outer, [inner])
	check(face_with_hole != null, "face with hole created")
	check(face_with_hole.is_planar(), "face is planar")
	var inners := face_with_hole.inner_wires()
	check(inners.size() == 1, "inner_wires returns 1 hole wire")
	var pln := face_with_hole.to_plane()
	check(pln != null and pln.z_dir.distance_to(Vector3.BACK) < 1e-3, "to_plane normal")
	var surf_pt := face_with_hole.surface_point(0.5, 0.5)
	check(surf_pt.distance_to(Vector3.ZERO) < 1e-3, "surface_point(0.5, 0.5) is at center")

func _test_solid_enhancements() -> void:
	var box := BdgSolid.make_box(10.0, 10.0, 10.0)
	var top_face: BdgFace = box.faces()[0] as BdgFace
	var hollowed := box.hollow([top_face], -1.0)
	check(hollowed != null, "solid.hollow created hollow box")
	if hollowed != null:
		check(hollowed.volume() < box.volume() and hollowed.volume() > 0.0, "hollow box volume < solid box")
