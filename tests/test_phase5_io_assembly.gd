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
	_test_assembly_hierarchy()
	_test_joints()
	_test_brep_io()
	_test_svg_export()
	_test_dxf_export()
	_test_step_io()
	print("--- Phase 5 Test Results ---")
	print("Checks: %d, Failures: %d" % [checks, failures])
	quit(1 if failures > 0 else 0)

func _test_assembly_hierarchy() -> void:
	var root := BdgAssembly.new(null, "RootAssembly")
	var base_plate := BdgSolid.make_box(50.0, 50.0, 5.0)
	var motor := BdgSolid.make_cylinder(10.0, 30.0)

	var sub_base := root.add(base_plate, "BasePlate", BdgLocation.new(Vector3(0, 0, 0)), Color.GRAY)
	var sub_motor := root.add(motor, "Motor", BdgLocation.new(Vector3(0, 0, 5.0)), Color.STEEL_BLUE)

	check(root.children.size() == 2, "Assembly root has 2 children")
	check(root.find("Motor") != null, "find('Motor') located child assembly")
	check(sub_motor.world_location().position.z == 5.0, "Motor world Z position is 5.0")

	var comp := root.to_compound()
	check(comp != null, "Assembly flattened to compound")
	if comp != null:
		check(comp.solids().size() == 2, "Compound contains 2 solids")

func _test_joints() -> void:
	var rigid := BdgJoint.make_rigid(BdgLocation.new(Vector3(10, 0, 0)), BdgLocation.new(Vector3(0, 0, 0)))
	var child_loc := rigid.compute_child_location()
	check(child_loc.position.distance_to(Vector3(10, 0, 0)) < 1e-3, "Rigid joint child placed at (10, 0, 0)")

	var revolute := BdgJoint.make_revolute(BdgLocation.new(Vector3(0, 0, 10)), BdgLocation.new(Vector3(0, 0, 0)), BdgAxis.Z)
	var rot_loc := revolute.compute_child_location(90.0)
	check(rot_loc.position.z == 10.0, "Revolute joint maintains origin Z")
	check(absf(rot_loc.orientation.get_euler().z - deg_to_rad(90.0)) < 1e-2 or absf(rot_loc.orientation.get_euler().z + deg_to_rad(90.0)) < 1e-2, "Revolute joint rotated 90 deg")

	var linear := BdgJoint.make_linear(BdgLocation.new(Vector3.ZERO), BdgLocation.new(Vector3.ZERO), BdgAxis.X)
	var lin_loc := linear.compute_child_location(25.0)
	check(lin_loc.position.distance_to(Vector3(25, 0, 0)) < 1e-3, "Linear joint slid 25mm along X")

func _test_brep_io() -> void:
	var original := BdgSolid.make_cylinder(6.0, 20.0)
	var brep_path := "user://test_model.brep"
	var exported := BdgIO.export_brep(original, brep_path)
	check(exported, "BREP exported successfully")
	if exported:
		var imported := BdgIO.import_brep(brep_path)
		check(imported != null, "BREP imported successfully")
		if imported != null:
			check(absf(imported.volume() - original.volume()) < 1e-2, "Imported BREP volume matches: %f vs %f" % [imported.volume(), original.volume()])

func _test_svg_export() -> void:
	var rect := BdgWire.make_rect(30.0, 20.0)
	var svg_path := "user://test_drawing.svg"
	var exported := BdgIO.export_svg(rect, svg_path)
	check(exported, "SVG exported successfully")
	if exported:
		var f := FileAccess.open(svg_path, FileAccess.READ)
		check(f != null and f.get_length() > 50, "SVG file written with content")
		if f != null:
			var txt := f.get_as_text()
			check(txt.contains("<svg") and txt.contains("<path"), "SVG contains standard XML tags")
			f.close()

func _test_dxf_export() -> void:
	var circle := BdgWire.make_circle(15.0)
	var dxf_path := "user://test_drawing.dxf"
	var exported := BdgIO.export_dxf(circle, dxf_path)
	check(exported, "DXF exported successfully")
	if exported:
		var f := FileAccess.open(dxf_path, FileAccess.READ)
		check(f != null and f.get_length() > 50, "DXF file written with content")
		if f != null:
			var txt := f.get_as_text()
			check(txt.contains("ENTITIES") and txt.contains("EOF"), "DXF contains standard entities section and EOF")
			f.close()

func _test_step_io() -> void:
	var orig_box := BdgSolid.make_box(10.0, 10.0, 10.0)
	var step_path := "user://test_box.step"
	var exported := BdgIO.export_step(orig_box, step_path)
	check(exported, "STEP exported successfully")
	if exported:
		var imported := BdgIO.import_step(step_path)
		check(imported != null, "STEP imported successfully")
		if imported != null:
			check(absf(imported.volume() - 1000.0) < 1e-2, "STEP imported volume is 1000")
