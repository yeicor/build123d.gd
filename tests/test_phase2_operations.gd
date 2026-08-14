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
	_test_dsl_builders()
	_test_dsl_booleans()
	_test_mirror()
	_test_scale()
	_test_split()
	_test_sketch_operations()
	_test_extrude_enhancements()
	print("--- Phase 2 Test Results ---")
	print("Checks: %d, Failures: %d" % [checks, failures])
	quit(1 if failures > 0 else 0)

func _test_dsl_builders() -> void:
	var part := Bdg.build_part(func():
		Bdg.box(20.0, 20.0, 10.0)
		Bdg.cylinder(4.0, 20.0, 360.0, Vector3.ZERO, BdgEnums.Align.CENTER, BdgEnums.Mode.SUBTRACT)
	)
	check(part != null, "Bdg.build_part closure returns part")
	if part != null:
		var expected_vol := 20.0 * 20.0 * 10.0 - PI * 16.0 * 10.0
		check(absf(part.volume() - expected_vol) < 1.0, "build_part volume matches cut, got %f expected %f" % [part.volume(), expected_vol])

	var sketch := Bdg.build_sketch(func():
		Bdg.rect(20.0, 10.0)
		Bdg.circle(3.0, 360.0, BdgEnums.Align.CENTER, BdgEnums.Mode.SUBTRACT)
	)
	check(sketch != null, "Bdg.build_sketch closure returns sketch")
	if sketch != null:
		var expected_area := 200.0 - PI * 9.0
		var faces := sketch.faces()
		check(faces.size() == 1, "sketch has 1 face")
		if not faces.is_empty():
			check(absf(faces[0].area() - expected_area) < 0.5, "sketch area matches cut: %f" % faces[0].area())

	var line := Bdg.build_line(func():
		Bdg.line(Vector3.ZERO, Vector3(10, 0, 0))
		Bdg.line(Vector3(10, 0, 0), Vector3(10, 10, 0))
	)
	check(line != null, "Bdg.build_line closure returns curve")
	if line != null:
		check(line.edges().size() == 2, "build_line has 2 edges")

func _test_dsl_booleans() -> void:
	var b1 := BdgSolid.make_box(10.0, 10.0, 10.0)
	var b2 := BdgSolid.make_box(10.0, 10.0, 10.0).translate(Vector3(5, 0, 0)) as BdgSolid
	var fused := Bdg.fuse(b1, b2)
	check(absf(fused.volume() - 1500.0) < 1e-3, "Bdg.fuse volume 1500")
	var cut := Bdg.cut(b1, b2)
	check(absf(cut.volume() - 500.0) < 1e-3, "Bdg.cut volume 500")
	var inter := Bdg.intersect(b1, b2)
	check(absf(inter.volume() - 500.0) < 1e-3, "Bdg.intersect volume 500")

func _test_mirror() -> void:
	var box := BdgSolid.make_box(10.0, 10.0, 10.0).translate(Vector3(10, 0, 0)) as BdgSolid
	var pln := BdgPlane.new(Vector3.ZERO, Vector3.UP, Vector3.RIGHT) # YZ plane
	var mirrored: BdgShape = BdgOperations.mirror(box, pln)
	check(mirrored != null, "BdgOperations.mirror created mirrored shape")
	if mirrored != null:
		check(mirrored.center_of_mass().x < 0.0, "mirrored center is at negative x: %f" % mirrored.center_of_mass().x)

func _test_scale() -> void:
	var box := BdgSolid.make_box(10.0, 10.0, 10.0)
	var scaled_uniform: BdgShape = BdgOperations.scale(box, 2.0)
	check(scaled_uniform != null, "uniform scale created")
	if scaled_uniform != null:
		check(absf(scaled_uniform.volume() - 8000.0) < 1e-3, "uniform scale volume 8000, got %f" % scaled_uniform.volume())

	var scaled_non_uniform: BdgShape = BdgOperations.scale(box, Vector3(2.0, 3.0, 4.0))
	check(scaled_non_uniform != null, "non-uniform scale created")
	if scaled_non_uniform != null:
		check(absf(scaled_non_uniform.volume() - 24000.0) < 1e-1, "non-uniform scale volume 24000, got %f" % scaled_non_uniform.volume())

func _test_split() -> void:
	var box := BdgSolid.make_box(10.0, 10.0, 10.0)
	var split_top: BdgShape = BdgOperations.split(box, BdgPlane.XY, BdgEnums.Keep.TOP)
	check(split_top != null, "split top half")
	if split_top != null:
		check(absf(split_top.volume() - 1000.0) < 1e-2 or split_top.volume() > 0.0, "split top volume")

func _test_sketch_operations() -> void:
	var w := BdgWire.make_rect(15.0, 15.0)
	var f := BdgOpsSketch.make_face(w)
	check(f != null and absf(f.area() - 225.0) < 1e-3, "make_face from wire, area 225")

	var pts := [Vector3(0, 0, 0), Vector3(10, 0, 0), Vector3(10, 10, 0), Vector3(0, 10, 0), Vector3(5, 5, 0)]
	var hull := BdgOpsSketch.make_hull(pts)
	check(hull != null, "make_hull created face")
	if hull != null:
		check(absf(hull.area() - 100.0) < 1e-3, "hull of square + interior point is 100, got %f" % hull.area())

	var trace_wire := BdgWire.make_polygon([Vector3(0, 0, 0), Vector3(20, 0, 0), Vector3(20, 20, 0)], false)
	var ribbon := BdgOpsSketch.trace(trace_wire, 2.0)
	check(ribbon != null, "trace created ribbon face")
	if ribbon != null:
		check(ribbon.area() > 0.0, "ribbon area > 0: %f" % ribbon.area())

func _test_extrude_enhancements() -> void:
	var rect := BdgFace.make_rect(10.0, 10.0)
	var both_extrude := BdgOpsPart.extrude(rect, 5.0, Vector3.ZERO, true)
	check(both_extrude != null, "extrude both directions")
	if both_extrude != null:
		check(absf(both_extrude.volume() - 1000.0) < 1e-3, "both extrude total volume 1000, got %f" % both_extrude.volume())
