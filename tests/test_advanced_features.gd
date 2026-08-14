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
	_test_airfoil()
	_test_parabolic_hyperbolic_arcs()
	_test_blend_curve()
	_test_convex_polyhedron()
	_test_pack_nesting()
	_test_technical_drawing()
	_test_svg_dxf_io_roundtrip()
	_test_obj_ply_gltf_export()
	print("--- Advanced Features Test Results ---")
	print("Checks: %d, Failures: %d" % [checks, failures])
	quit(1 if failures > 0 else 0)

func _test_airfoil() -> void:
	var foil := BdgAirfoil.new("2412", 100.0, 80)
	check(foil != null, "BdgAirfoil created")
	if foil != null:
		var bbox := foil.bounding_box()
		check(absf(bbox.max.x - bbox.min.x - 100.0) < 1.0, "Airfoil chord length is 100mm, got %f" % (bbox.max.x - bbox.min.x))
		check(bbox.max.y > bbox.min.y, "Airfoil thickness > 0")

func _test_parabolic_hyperbolic_arcs() -> void:
	var parab := BdgParabolicCenterArc.new(10.0, -15.0, 15.0)
	check(parab != null, "BdgParabolicCenterArc created")
	if parab != null:
		check(parab.edges().size() == 1, "Parabolic arc has 1 edge")

	var hypr := BdgHyperbolicCenterArc.new(15.0, 8.0, -1.0, 1.0)
	check(hypr != null, "BdgHyperbolicCenterArc created")
	if hypr != null:
		check(hypr.edges().size() == 1, "Hyperbolic arc has 1 edge")

func _test_blend_curve() -> void:
	var e1 := BdgEdge.make_line(Vector3(0, 0, 0), Vector3(10, 0, 0))
	var e2 := BdgEdge.make_line(Vector3(20, 10, 0), Vector3(20, 20, 0))
	var blend := BdgBlendCurve.new(e1, e2)
	check(blend != null, "BdgBlendCurve created")
	if blend != null:
		check(blend.edges().size() == 1, "Blend curve has 1 edge")

func _test_convex_polyhedron() -> void:
	# 3D points of a regular octahedron
	var pts := [
		Vector3(10, 0, 0), Vector3(-10, 0, 0),
		Vector3(0, 10, 0), Vector3(0, -10, 0),
		Vector3(0, 0, 10), Vector3(0, 0, -10)
	]
	var poly := BdgConvexPolyhedron.new(pts)
	check(poly != null, "BdgConvexPolyhedron octahedron created")
	if poly != null:
		var solids := poly.solids()
		check(solids.size() == 1, "Polyhedron is a single solid")
		if not solids.is_empty():
			var expected_vol := (4.0 / 3.0) * (10.0 * 10.0 * 10.0) # 1333.33
			check(absf(solids[0].volume() - expected_vol) < 5.0, "Octahedron volume: %f vs %f" % [solids[0].volume(), expected_vol])

func _test_pack_nesting() -> void:
	var b1 := Bdg.box(20.0, 30.0, 5.0)
	var b2 := Bdg.box(40.0, 20.0, 5.0)
	var b3 := Bdg.box(15.0, 15.0, 5.0)
	var packed := BdgPack.pack([b1, b2, b3], 100.0, 100.0, 2.0)
	check(packed.size() == 3, "BdgPack packed 3 parts")
	if packed.size() == 3:
		# Verify no bounding boxes overlap
		var bbox1: BdgBoundBox = (packed[0] as BdgShape).bounding_box()
		var bbox2: BdgBoundBox = (packed[1] as BdgShape).bounding_box()
		check(bbox1.max.x <= bbox2.min.x or bbox2.max.x <= bbox1.min.x or bbox1.max.y <= bbox2.min.y or bbox2.max.y <= bbox1.min.y, "Packed parts do not overlap")

func _test_technical_drawing() -> void:
	var part := Bdg.build_part(func():
		Bdg.box(50.0, 30.0, 10.0)
		Bdg.hole(5.0, 15.0)
	)
	var td := BdgTechnicalDrawing.new(part, 297.0, 210.0, 1.0, "Bracket Drawing", "Test Engineer")
	td.add_dimension(BdgDimensionLine.new(Vector3(20, 20, 0), Vector3(70, 20, 0), 10.0, "50.0 mm"))

	var svg_ok := td.export_svg("user://tech_drawing.svg")
	check(svg_ok, "Technical drawing exported to SVG")

	var dxf_ok := td.export_dxf("user://tech_drawing.dxf")
	check(dxf_ok, "Technical drawing exported to DXF")

func _test_svg_dxf_io_roundtrip() -> void:
	var rect := BdgWire.make_rect(40.0, 25.0)
	BdgIO.export_svg(rect, "user://rect_test.svg")
	var imported_svg := BdgIO.import_svg("user://rect_test.svg")
	check(not imported_svg.is_empty(), "SVG imported wires")

	var circ := BdgWire.make_circle(12.0)
	BdgIO.export_dxf(circ, "user://circ_test.dxf")
	var imported_dxf := BdgIO.import_dxf("user://circ_test.dxf")
	check(not imported_dxf.is_empty(), "DXF imported wires")

func _test_obj_ply_gltf_export() -> void:
	var box := BdgSolid.make_box(15.0, 15.0, 15.0)
	var obj_ok := BdgIO.export_obj(box, "user://cube.obj")
	check(obj_ok, "export_obj succeeded")

	var ply_ok := BdgIO.export_ply(box, "user://cube.ply")
	check(ply_ok, "export_ply succeeded")

	var gltf_ok := BdgIO.export_gltf(box, "user://cube.gltf")
	check(gltf_ok, "export_gltf succeeded")
	if gltf_ok:
		var f := FileAccess.open("user://cube.gltf", FileAccess.READ)
		check(f != null and f.get_length() > 100, "GLTF file valid size")
		if f != null:
			var txt := f.get_as_text()
			check(txt.contains('"asset"') and txt.contains('"buffers"'), "GLTF contains valid JSON schema")
			f.close()
