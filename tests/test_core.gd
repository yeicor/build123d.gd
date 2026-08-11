extends SceneTree

var failures := 0
var checks := 0

func _init():
	_test_booleans()
	_test_wires_edges()
	_test_faces()
	_test_transforms()
	_test_entities()
	_test_shape_list()
	_test_primitives()
	_test_operations()
	_test_builders()
	print("---")
	print("checks: %d, failures: %d" % [checks, failures])
	quit()

func _check(cond: bool, msg: String) -> void:
	checks += 1
	if not cond:
		failures += 1
		print("FAIL: ", msg)

func _test_booleans() -> void:
	var b1 := BdgSolid.new(OcgBRepPrimAPIMakeBox.from_6(1000.0, 1000.0, 1000.0).solid())
	var b2 := BdgSolid.new(OcgBRepPrimAPIMakeBox.from_6(1000.0, 1000.0, 1000.0).solid())
	b2.translate(Vector3(500.0, 0.0, 0.0))
	var fused := b1.fuse(b2)
	_check(abs(fused.volume() - 1.5e9) < 1e-6, "fuse volume %.1f" % fused.volume())
	var cut := b1.cut(b2)
	_check(abs(cut.volume() - 5e8) < 1e-6, "cut volume %.1f" % cut.volume())
	var inter := b1.intersect(b2)
	_check(abs(inter.volume() - 5e8) < 1e-6, "intersect volume %.1f" % inter.volume())

func _test_wires_edges() -> void:
	var e := BdgEdge.make_line(Vector3.ZERO, Vector3(10.0, 0.0, 0.0))
	_check(abs(e.length() - 10.0) < 1e-6, "line length %.2f" % e.length())
	_check(e.start_point().distance_to(Vector3.ZERO) < 1e-6, "line start")
	_check(e.end_point().distance_to(Vector3(10.0, 0.0, 0.0)) < 1e-6, "line end")

	var c := BdgEdge.make_circle(5.0)
	_check(abs(c.length() - 2.0 * PI * 5.0) < 1e-6, "circle length %.3f" % c.length())

	var w := BdgWire.make_rect(10.0, 20.0)
	_check(abs(w.length() - 60.0) < 1e-6, "rect wire length %.1f" % w.length())
	_check(w.is_closed(), "rect wire closed")

	var f := BdgFace.make_from_wires(w)
	_check(abs(f.area() - 200.0) < 1e-6, "face area %.1f" % f.area())

	var fc := BdgFace.make_circle(5.0)
	_check(abs(fc.area() - PI * 25.0) < 1e-6, "circle face area %.3f" % fc.area())

	var fr := BdgFace.make_rect(4.0, 6.0)
	_check(abs(fr.area() - 24.0) < 1e-6, "rect face area %.1f" % fr.area())

func _test_faces() -> void:
	var fr := BdgFace.make_rect(4.0, 6.0)
	_check(fr.outer_wire() != null and not fr.outer_wire().is_null(), "outer wire")
	var fc := BdgFace.make_circle(5.0)
	var n := fc.normal()
	_check(n.length() > 0.99, "face normal length %.2f" % n.length())

func _test_transforms() -> void:
	var b := BdgSolid.new(OcgBRepPrimAPIMakeBox.from_6(1.0, 1.0, 1.0).solid())
	b.translate(Vector3(5.0, 6.0, 7.0))
	_check(b.center_of_mass().distance_to(Vector3(5.5, 6.5, 7.5)) < 1e-6, "moved center %s" % b.center_of_mass())
	var m := BdgMatrix.rotation_about(Vector3.ZERO, Vector3.BACK, 90.0)
	var p := Vector3(1.0, 0.0, 0.0)
	var rotated := m.apply(p)
	_check(rotated.distance_to(Vector3(0.0, 1.0, 0.0)) < 1e-6, "rotate 90 about z: %s" % rotated)

func _test_entities() -> void:
	var b := BdgSolid.new(OcgBRepPrimAPIMakeBox.from_6(10.0, 10.0, 10.0).solid())
	_check(b.vertices().size() == 8, "box vertices %d" % b.vertices().size())
	_check(b.edges().size() == 12, "box edges %d" % b.edges().size())
	_check(b.faces().size() == 6, "box faces %d" % b.faces().size())
	_check(b.solids().size() == 1, "box solids")
	_check(b.shape_type() == BdgEnums.ShapeType.SOLID, "shape type")

func _test_shape_list() -> void:
	var b := BdgSolid.new(OcgBRepPrimAPIMakeBox.from_6(10.0, 20.0, 30.0).solid())
	var faces := b.faces()
	_check(faces.size() == 6, "face list size %d" % faces.size())
	_check(faces is Array, "faces() returns Array")

	var list := BdgShapeList.new(faces)
	_check(list.size() == 6, "BdgShapeList size %d" % list.size())
	_check(list.first() is BdgShape, "first is BdgShape")

	var top_faces := list.filter_by(BdgEnums.GeomType.PLANE)
	_check(top_faces.size() == 6, "filter by PLANE %d" % top_faces.size())

	var z_faces := list.filter_by(BdgAxis.Z)
	_check(z_faces.size() == 2, "filter by axis Z %d" % z_faces.size())

	var by_area := list.sort_by(BdgEnums.SortBy.AREA)
	_check(by_area.at(0).area() < by_area.at(5).area(), "sort by area ascending")

	var z_sorted := list.sort_by(BdgAxis.Z)
	_check(z_sorted.at(0).center().z <= z_sorted.at(1).center().z, "sort by z")

	var groups := list.group_by(BdgAxis.Z)
	_check(groups.size() == 3, "group by z -> %d groups" % groups.size())
	_check(groups[0].size() == 1, "first z-group has 1 face")
	_check(groups[1].size() == 4, "middle z-group has 4 faces")
	_check(groups[2].size() == 1, "third z-group has 1 face")

	var s1 := BdgSolid.new(OcgBRepPrimAPIMakeBox.from_6(10.0, 10.0, 10.0).solid())
	var s2 := BdgSolid.new(OcgBRepPrimAPIMakeBox.from_6(10.0, 10.0, 10.0).solid())
	s2.translate(Vector3(100.0, 0.0, 0.0))
	var list1 := BdgShapeList.new([s1])
	var list2 := BdgShapeList.new([s2])
	_check(abs(list1.distance_to(list2) - 90.0) < 1e-6, "distance %.2f" % list1.distance_to(list2))

	var center := list1.center()
	_check(center.distance_to(Vector3(5.0, 5.0, 5.0)) < 1e-6, "list center %s" % center)

func _test_primitives() -> void:
	var box := BdgBox.new(10.0, 20.0, 30.0)
	_check(box is BdgPart, "box is BdgPart")
	_check(box is BdgCompound, "box wrapped as compound")
	_check(abs(box.volume() - 6000.0) < 1e-6, "box volume %.1f" % box.volume())
	var bc := box.bounding_box()
	_check(bc.center().distance_to(Vector3.ZERO) < 1e-6, "box centered %s" % bc.center())
	_check(abs(bc.size().x - 10.0) < 1e-6 and abs(bc.size().y - 20.0) < 1e-6, "box size %s" % bc.size())

	var moved_box := BdgBox.new(10.0, 20.0, 30.0, Vector3(0.0, 0.0, 90.0))
	var mb := moved_box.bounding_box()
	_check(abs(mb.size().x - 20.0) < 1e-6 and abs(mb.size().y - 10.0) < 1e-6, "rotated box size %s" % mb.size())

	var box_min := BdgBox.new(10.0, 20.0, 30.0, Vector3.ZERO, BdgEnums.Align.MIN)
	var bm := box_min.bounding_box()
	_check(bm.min.distance_to(Vector3.ZERO) < 1e-6, "box MIN aligned %s" % bm.min)

	var cyl := BdgCylinder.new(5.0, 20.0)
	_check(abs(cyl.volume() - PI * 25.0 * 20.0) < 1e-6, "cylinder volume %.1f" % cyl.volume())
	var cc := cyl.bounding_box()
	_check(cc.center().distance_to(Vector3.ZERO) < 1e-6, "cylinder centered %s" % cc.center())
	_check(abs(cc.size().z - 20.0) < 1e-6, "cylinder height %.1f" % cc.size().z)

	var cone := BdgCone.new(5.0, 0.0, 10.0)
	_check(abs(cone.volume() - PI * 25.0 * 10.0 / 3.0) < 1e-3, "cone volume %.2f" % cone.volume())

	var sphere := BdgSphere.new(5.0)
	_check(abs(sphere.volume() - 4.0 / 3.0 * PI * 125.0) < 1e-3, "sphere volume %.2f" % sphere.volume())

	var torus := BdgTorus.new(10.0, 2.0)
	_check(abs(torus.volume() - 2.0 * PI * PI * 10.0 * 4.0) < 1e-3, "torus volume %.2f" % torus.volume())

	var wedge := BdgWedge.new(10.0, 20.0, 5.0, -5.0, 0.0, 5.0, 5.0)
	_check(wedge.volume() > 0.0, "wedge volume %.1f" % wedge.volume())

	var solid := BdgSolid.make_box(10.0, 20.0, 30.0)
	_check(solid is BdgSolid, "solid make_box")
	_check(abs(solid.volume() - 6000.0) < 1e-6, "solid box volume %.1f" % solid.volume())
	var solid_plane := BdgSolid.make_box(10.0, 20.0, 30.0, BdgPlane.XY)
	_check(abs(solid_plane.volume() - 6000.0) < 1e-6, "solid box on plane")

func _test_operations() -> void:
	var rect := BdgFace.make_rect(10.0, 10.0, BdgPlane.XY)
	var extruded := rect.extrude(Vector3(0.0, 0.0, 15.0))
	_check(extruded is BdgSolid, "extruded face -> solid (%s)" % extruded.shape_type())
	_check(abs(extruded.volume() - 1500.0) < 1e-6, "extrude volume %.1f" % extruded.volume())

	var edge := BdgEdge.make_line(Vector3.ZERO, Vector3(10.0, 0.0, 0.0))
	var extruded_edge := edge.extrude(Vector3(0.0, 5.0, 0.0))
	_check(extruded_edge is BdgFace, "extruded edge -> face (%s)" % extruded_edge.shape_type())
	_check(abs(extruded_edge.area() - 50.0) < 1e-6, "extrude edge area %.1f" % extruded_edge.area())

	var box := BdgBox.new(10.0, 10.0, 10.0)
	var solids: Array = box.solids()
	_check(solids.size() >= 1, "box has solids")
	var solid: BdgShape = solids[0]
	_check(solid is BdgSolid, "box solid typed")
	var all_edges: Array = solid.edges()
	_check(all_edges.size() == 12, "box edges %d" % all_edges.size())
	var filleted: BdgSolid = solid.fillet(1.0, [all_edges[0], all_edges[1]])
	_check(filleted is BdgSolid, "fillet -> solid")
	_check(filleted.volume() > 990.0 and filleted.volume() < 1000.0, "fillet volume %.2f" % filleted.volume())

	var chamfered: BdgSolid = solid.chamfer(1.0, 0.0, [all_edges[0]])
	_check(chamfered is BdgSolid, "chamfer -> solid")
	_check(chamfered.volume() > 990.0 and chamfered.volume() < 1000.0, "chamfer volume %.2f" % chamfered.volume())

	var profile := BdgFace.make_rect(2.0, 3.0, BdgPlane.ZX)
	profile.translate(Vector3(5.0, 0.0, 0.0))
	var revolved := BdgSolid.make_revolve(profile, 360.0, BdgAxis.Z)
	_check(revolved is BdgSolid, "revolve -> solid")
	_check(abs(revolved.volume() - 6.0 * PI * 2.0 * 5.0) < 1e-2, "revolve volume %.2f" % revolved.volume())
	var half := BdgSolid.make_revolve(profile, 180.0, BdgAxis.Z)
	_check(abs(half.volume() - 6.0 * PI * 5.0) < 1e-2, "revolve 180 volume %.2f" % half.volume())

	var box2 := BdgBox.new(10.0, 10.0, 10.0)
	var box_edges: Array = box2.edges()
	var filleted_op: BdgShape = BdgOperations.fillet([box_edges[0]], 1.0)
	_check(filleted_op != null and filleted_op.volume() > 990.0, "BdgOperations.fillet volume %.2f" % (filleted_op.volume() if filleted_op else 0.0))
	var chamfered_op: BdgShape = BdgOperations.chamfer([box_edges[1]], 1.0)
	_check(chamfered_op != null and chamfered_op.volume() > 990.0, "BdgOperations.chamfer volume %.2f" % (chamfered_op.volume() if chamfered_op else 0.0))

	var rect2 := BdgFace.make_rect(4.0, 4.0, BdgPlane.XY)
	var extruded_op: BdgPart = BdgOperations.extrude(rect2, 3.0)
	_check(extruded_op is BdgPart, "BdgOperations.extrude -> BdgPart")
	_check(abs(extruded_op.volume() - 48.0) < 1e-6, "BdgOperations.extrude volume %.1f" % extruded_op.volume())

func _test_builders() -> void:
	var bp := BdgBuildPart.new()
	bp.begin()
	var box1 := BdgBox.new(10.0, 10.0, 10.0)
	var cyl1 := BdgCylinder.new(6.0, 10.0)
	bp.end()
	var part: BdgPart = bp.part()
	_check(part != null, "BuildPart produced a part")
	_check(part.volume() > 1000.0 and part.volume() < 1000.0 + PI * 36.0 * 10.0, "BuildPart fused volume %.2f" % part.volume())

	var bs := BdgBuildSketch.new()
	bs.begin()
	var r1 := BdgRectangle.new(10.0, 5.0)
	var c1 := BdgCircle.new(2.0)
	bs.end()
	var sketch: BdgSketch = bs.sketch()
	_check(sketch != null, "BuildSketch produced a sketch")
	var sfaces: Array = sketch.faces()
	_check(not sfaces.is_empty(), "sketch has faces, got %d" % sfaces.size())

	var bl := BdgBuildLine.new()
	bl.begin()
	var l1 := BdgLine.new(Vector3.ZERO, Vector3(10.0, 0.0, 0.0))
	var l2 := BdgLine.new(Vector3(10.0, 0.0, 0.0), Vector3(10.0, 5.0, 0.0))
	bl.end()
	var curve: BdgShape = bl.curve()
	_check(curve != null, "BuildLine produced a curve")
	var ledges: Array = bl.edges()
	_check(ledges.size() == 2, "line has 2 edges, got %d" % ledges.size())

	var bp2 := BdgBuildPart.new()
	bp2.begin()
	var box2 := BdgBox.new(10.0, 10.0, 10.0)
	BdgCylinder.new(4.0, 4.0, 360.0, Vector3.ZERO, [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.MAX], BdgEnums.Mode.SUBTRACT)
	bp2.end()
	var part2: BdgPart = bp2.part()
	_check(part2 != null, "BuildPart with subtract produced a part")
	_check(part2.volume() < 1000.0, "BuildPart subtract volume %.2f" % part2.volume())

	var bp3 := BdgBuildPart.new()
	bp3.begin()
	var sk := BdgBuildSketch.new()
	sk.begin()
	var rect := BdgRectangle.new(10.0, 10.0)
	sk.end()
	var sketched: BdgSketch = sk.sketch()
	BdgOperations.extrude(sketched, 5.0)
	bp3.end()
	var part3: BdgPart = bp3.part()
	_check(part3 != null and abs(part3.volume() - 500.0) < 1e-6, "extrude into BuildPart volume %.1f" % (part3.volume() if part3 else 0.0))
