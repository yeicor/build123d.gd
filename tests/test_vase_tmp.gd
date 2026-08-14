extends SceneTree

func _init() -> void:
	var p0 := Vector3(0, 0, 0)
	var p1 := Vector3(12, 0, 0)
	var p2 := Vector3(15, 20, 0)
	var p3_mid := Vector3(22, 40, 0)
	var p3 := Vector3(20, 50, 0)
	var p4 := Vector3(20, 55, 0)
	var p5_mid := Vector3(22.5, 57.5, 0)
	var p5 := Vector3(20, 60, 0)
	var p6 := Vector3(20, 61, 0)
	var p7 := Vector3(0, 61, 0)

	var e1 := BdgEdge.make_line(p0, p1)
	var e2 := BdgEdge.make_radius_arc(p1, p2, 50.0, true)
	var t2_end: Vector3 = e2.tangent_at(1.0)
	var e3 := BdgEdge.make_spline([p2, p3_mid, p3], [t2_end, Vector3(-0.75, 1, 0).normalized()])
	var e4 := BdgEdge.make_radius_arc(p3, p4, 5.0, true)
	var t4_end: Vector3 = e4.tangent_at(1.0)
	var e5 := BdgEdge.make_spline([p4, p5_mid, p5], [t4_end, Vector3(-1, 0, 0).normalized()])
	var poly_wire := BdgWire.make_polygon([p5, p6, p7, p0], false)

	var vase_wire := BdgWire.make_wire([e1, e2, e3, e4, e5, poly_wire])
	var vase_face := BdgFace.make_from_wires(vase_wire)
	var rev := vase_face.revolve(360.0, BdgAxis.Y)
	print("revolve bbox size: ", rev.bounding_box().size())
	print("expected: ~ (45.3, 61, 45.3)")
	quit()
