extends SceneTree
## test_api_parity.gd - API Parity Verification Test for build123d.gd

var checks := 0
var failures := 0

func check(cond: bool, msg: String) -> void:
	checks += 1
	if not cond:
		failures += 1
		print("FAIL: %s" % msg)
	else:
		print("ok: %s" % msg)

func _init() -> void:
	print("==================================================")
	print("       BUILD123D.GD API PARITY TEST SUITE         ")
	print("==================================================")

	test_math_parity()
	test_topology_parity()
	test_dsl_parity()
	test_godot_native_types()

	print("\nSummary: %d checks, %d failures" % [checks, failures])
	if failures > 0:
		print("TEST SUITE FAILED")
	else:
		print("ALL PARITY TESTS PASSED!")
	quit()

func test_math_parity() -> void:
	print("\n--- Testing Math & Geometry Parity ---")
	var v := Vector3(10, 20, 30)
	check(BdgVector.to_tuple(v) == [10.0, 20.0, 30.0], "BdgVector.to_tuple")
	check(BdgVector.add(v, Vector3(1, 1, 1)) == Vector3(11, 21, 31), "BdgVector.add")
	check(BdgVector.to_dir(v) == v.normalized(), "BdgVector.to_dir")

	var axis := BdgAxis.X
	check(axis.reverse().direction == Vector3.LEFT, "BdgAxis.reverse")
	check(axis.is_parallel(BdgAxis.X_flipped), "BdgAxis.is_parallel")
	check(axis.is_normal(BdgAxis.Y), "BdgAxis.is_normal")

	var plane := BdgPlane.XY
	var local_p := plane.to_local_coords(Vector3(5, 10, 0))
	check(local_p == Vector3(5, 10, 0), "BdgPlane.to_local_coords")
	check(plane.from_local_coords(local_p) == Vector3(5, 10, 0), "BdgPlane.from_local_coords")

	var loc := BdgLocation.new(Vector3(10, 0, 0))
	check(loc.to_transform3d().origin == Vector3(10, 0, 0), "BdgLocation.to_transform3d")
	check(loc.inverse().position == Vector3(-10, 0, 0), "BdgLocation.inverse")

	var bbox := BdgBoundBox.new(Vector3(0, 0, 0), Vector3(10, 20, 30))
	check(bbox.to_aabb().size == Vector3(10, 20, 30), "BdgBoundBox.to_aabb")
	check(bbox.is_inside(Vector3(5, 5, 5)), "BdgBoundBox.is_inside")

	var color := BdgColor.categorical_set(0)
	check(color != null and color.color.a == 1.0, "BdgColor.categorical_set")

func test_topology_parity() -> void:
	print("\n--- Testing Topology Parity ---")
	var b1 := BdgSolid.make_box(10, 10, 10)
	var b2 := BdgSolid.make_box(10, 10, 10, BdgPlane.new(Vector3(20, 0, 0)))

	check(b1.distance_to(b2) >= 9.9, "BdgShape.distance_to")
	check(b1.closest_points(b2).size() == 2, "BdgShape.closest_points")
	check(b1.is_manifold(), "BdgSolid.is_manifold")
	check(b1.compute_mass() > 900.0, "BdgShape.compute_mass")

	var v := BdgVertex.make_vertex(Vector3(1, 2, 3))
	check(v.to_tuple() == [1.0, 2.0, 3.0], "BdgVertex.to_tuple")

	var e := BdgEdge.make_line(Vector3.ZERO, Vector3(10, 0, 0))
	check(e.param_at(5.0) == 0.5, "BdgEdge.param_at")
	check(e.find_tangent(0.5) == Vector3.RIGHT, "BdgEdge.find_tangent")
	check(e.distribute_locations(3).size() == 3, "BdgEdge.distribute_locations")

	var w := BdgWire.make_rect(10, 10)
	check(w.is_closed(), "BdgWire.is_closed")

	var f := BdgFace.make_rect(10, 10)
	check(f.position_at(0.5, 0.5) == Vector3.ZERO, "BdgFace.position_at")
	check(f.normal_at(0.5, 0.5) == Vector3.BACK, "BdgFace.normal_at")

	var compound := BdgCompound.make_triad(10.0)
	check(compound != null and not compound.is_null(), "BdgCompound.make_triad")

	var sl := BdgShapeList.new([b1, b2])
	check(sl.sort_by_distance(Vector3(25, 0, 0)).first() == b2, "BdgShapeList.sort_by_distance")

func test_dsl_parity() -> void:
	print("\n--- Testing Ergonomic Bdg DSL ---")
	var p := Bdg.build_part(func():
		Bdg.box(10, 10, 10)
	)
	check(p != null and not p.is_null(), "Bdg.build_part")
	check(Bdg.vector([5, 5, 5]) == Vector3(5, 5, 5), "Bdg.vector")

func test_godot_native_types() -> void:
	print("\n--- Testing Native Godot Type Conversions ---")
	var box := BdgSolid.make_box(10, 20, 30)
	var arr_mesh := box.to_array_mesh()
	check(arr_mesh != null and arr_mesh.get_surface_count() > 0, "BdgShape.to_array_mesh")

	var node3d := box.to_node3d()
	check(node3d != null and node3d is MeshInstance3D, "BdgShape.to_node3d")
