extends RefCounted
## BdgShape - base class for all CAD topology objects (Vertex, Edge, Wire, Face,
## Shell, Solid, Compound, Part, Sketch). Wraps an OcgTopoDSShape.
## Mirrors build123d/topology/shape_core.py Shape.
class_name BdgShape

var _wrapped: OcgTopoDSShape = null
var label: String = ""
var for_construction: bool = false
var _color: BdgColor = null
var topo_parent: BdgShape = null

## Construct. Args:
##   ()                      -> empty shape
##   (obj: OcgTopoDSShape)   -> wrap existing shape
##   (other: BdgShape)       -> copy of wrapped
func _init(...args) -> void:
	if args.size() == 1:
		if args[0] is OcgTopoDSShape:
			_wrapped = args[0]
		elif args[0] is BdgShape:
			_wrapped = args[0]._wrapped
		elif args[0] == null:
			_wrapped = null

func wrapped() -> OcgTopoDSShape:
	return _wrapped

func set_wrapped(shape: OcgTopoDSShape) -> void:
	_wrapped = shape

func is_null() -> bool:
	return _wrapped == null or _wrapped.is_null()

## OCGTT TopAbs shape enum (BdgEnums.ShapeType values)
func shape_type() -> int:
	if _wrapped == null or _wrapped.is_null():
		return BdgEnums.ShapeType.SHAPE
	return _wrapped.shape_type()

func is_valid() -> bool:
	if _wrapped == null or _wrapped.is_null():
		return true
	var chk := OcgBRepCheckAnalyzer.from_L(_wrapped, true, false, true)
	return chk.is_valid_k()

## Remove extraneous internal structure (returns self)
func clean() -> BdgShape:
	if _wrapped != null and not _wrapped.is_null():
		OcgBRepTools.clean(_wrapped, true)
	return self

func is_same(other: BdgShape) -> bool:
	if _wrapped == null or other._wrapped == null:
		return false
	return _wrapped.is_same(other._wrapped)

func is_equal(other: BdgShape) -> bool:
	if _wrapped == null or other._wrapped == null:
		return false
	return _wrapped.is_equal(other._wrapped)

## Reverse the orientation of the shape (returns a new BdgShape)
func reversed() -> BdgShape:
	if _wrapped == null or _wrapped.is_null():
		return self
	return BdgShape.cast(_wrapped.reversed())

func area() -> float:
	if is_null():
		return 0.0
	var props := OcgGPropGProps.new()
	OcgBRepGProp.surface_properties_q(_wrapped, props, true, false)
	return props.mass()

func volume() -> float:
	if is_null():
		return 0.0
	return compute_volume()

func compute_volume() -> float:
	if is_null():
		return 0.0
	var props := OcgGPropGProps.new()
	OcgBRepGProp.volume_properties_J(_wrapped, props, true, false, false)
	return props.mass()

func center_of_mass() -> Vector3:
	if is_null():
		return Vector3.ZERO
	var props := OcgGPropGProps.new()
	OcgBRepGProp.volume_properties_J(_wrapped, props, true, false, false)
	return _gp_pnt_to_v3(props.centre_of_mass())

## center of the shape (bounding box center by default; subclasses override)
func center() -> Vector3:
	if is_null():
		return Vector3.ZERO
	return bounding_box().center()

## geometry type: BdgEnums.GeomType
func geom_type() -> int:
	if is_null():
		return BdgEnums.GeomType.OTHER
	var st := shape_type()
	if st == BdgEnums.ShapeType.EDGE:
		var adaptor := OcgBRepAdaptorCurve.from_g(_wrapped)
		return _curve_type_to_geom(adaptor.get_type())
	elif st == BdgEnums.ShapeType.FACE:
		var adaptor := OcgBRepAdaptorSurface.from_K(_wrapped, false)
		return _surface_type_to_geom(adaptor.get_type())
	return BdgEnums.GeomType.OTHER

func _curve_type_to_geom(t: int) -> int:
	match t:
		OcgEnums.GeomAbs_CurveType.GeomAbs_Line: return BdgEnums.GeomType.LINE
		OcgEnums.GeomAbs_CurveType.GeomAbs_Circle: return BdgEnums.GeomType.CIRCLE
		OcgEnums.GeomAbs_CurveType.GeomAbs_Ellipse: return BdgEnums.GeomType.ELLIPSE
		OcgEnums.GeomAbs_CurveType.GeomAbs_Hyperbola: return BdgEnums.GeomType.HYPERBOLA
		OcgEnums.GeomAbs_CurveType.GeomAbs_Parabola: return BdgEnums.GeomType.PARABOLA
		OcgEnums.GeomAbs_CurveType.GeomAbs_BezierCurve: return BdgEnums.GeomType.BEZIER
		OcgEnums.GeomAbs_CurveType.GeomAbs_BSplineCurve: return BdgEnums.GeomType.BSPLINE
		OcgEnums.GeomAbs_CurveType.GeomAbs_OffsetCurve: return BdgEnums.GeomType.OFFSET
	return BdgEnums.GeomType.OTHER

func _surface_type_to_geom(t: int) -> int:
	match t:
		OcgEnums.GeomAbs_SurfaceType.GeomAbs_Plane: return BdgEnums.GeomType.PLANE
		OcgEnums.GeomAbs_SurfaceType.GeomAbs_Cylinder: return BdgEnums.GeomType.CYLINDER
		OcgEnums.GeomAbs_SurfaceType.GeomAbs_Cone: return BdgEnums.GeomType.CONE
		OcgEnums.GeomAbs_SurfaceType.GeomAbs_Sphere: return BdgEnums.GeomType.SPHERE
		OcgEnums.GeomAbs_SurfaceType.GeomAbs_Torus: return BdgEnums.GeomType.TORUS
		OcgEnums.GeomAbs_SurfaceType.GeomAbs_BezierSurface: return BdgEnums.GeomType.BEZIER
		OcgEnums.GeomAbs_SurfaceType.GeomAbs_BSplineSurface: return BdgEnums.GeomType.BSPLINE
		OcgEnums.GeomAbs_SurfaceType.GeomAbs_SurfaceOfRevolution: return BdgEnums.GeomType.REVOLUTION
		OcgEnums.GeomAbs_SurfaceType.GeomAbs_SurfaceOfExtrusion: return BdgEnums.GeomType.EXTRUSION
		OcgEnums.GeomAbs_SurfaceType.GeomAbs_OffsetSurface: return BdgEnums.GeomType.OFFSET
	return BdgEnums.GeomType.OTHER

# ---------------------------------------------------------------------------
# Location / transforms
# ---------------------------------------------------------------------------

func location() -> BdgLocation:
	if is_null():
		return BdgLocation.new()
	var loc := _wrapped.location_k()
	return BdgLocation.new(loc)

func set_location(loc: BdgLocation) -> void:
	if _wrapped != null and not _wrapped.is_null():
		_wrapped.location_j(loc.wrapped(), true)

func position() -> Vector3:
	return location().position

func orientation() -> Quaternion:
	return location().orientation

## Copy of self at the given absolute location
func located(loc: BdgLocation) -> BdgShape:
	if is_null():
		return self
	var copy := duplicate_shape(self)
	copy._wrapped.location_j(loc.wrapped(), true)
	return copy

## Apply location in-place
func locate(loc: BdgLocation) -> BdgShape:
	if _wrapped != null and not _wrapped.is_null():
		_wrapped.location_j(loc.wrapped(), true)
	return self

## Move (relative) in place
func move(loc: BdgLocation) -> BdgShape:
	return transform_geometry(_location_to_matrix(loc))

## Move (relative) returning copy
func moved(loc: BdgLocation) -> BdgShape:
	return transform_shape(_location_to_matrix(loc))

func translate(v: Vector3) -> BdgShape:
	return transform_geometry(BdgMatrix.translation(v))

func rotated_about(axis: BdgAxis, angle_deg: float) -> BdgShape:
	return transform_geometry(BdgMatrix.rotation_about(axis.position, axis.direction, angle_deg))

func scale(factor: float, center: Vector3 = Vector3.ZERO) -> BdgShape:
	return transform_geometry(BdgMatrix.scaling(center, Vector3.ONE * factor))

## transform geometry (in place)
func transform_geometry(m: BdgMatrix) -> BdgShape:
	if _wrapped != null and not _wrapped.is_null():
		var transformed := _wrapped.moved(_toploc_from_matrix(m))
		_wrapped = transformed
	return self

## transform shape returning a copy
func transform_shape(m: BdgMatrix) -> BdgShape:
	if _wrapped == null or _wrapped.is_null():
		return self
	var transformed := _wrapped.moved(_toploc_from_matrix(m))
	var result := BdgShape.cast(transformed)
	_copy_attributes(result)
	return result

func mirrored(plane: BdgPlane) -> BdgShape:
	var m := BdgMatrix.new()
	m._wrapped = OcgGpTrsf.new()
	var pnt := OcgGpPnt.from_6(plane.origin.x, plane.origin.y, plane.origin.z)
	var dir := OcgGpDir.from_6(plane.z_dir.x, plane.z_dir.y, plane.z_dir.z)
	m._wrapped.set_mirror_6(OcgGpAx1.from_n(pnt, dir))
	return transform_geometry(m)

# ---------------------------------------------------------------------------
# Bounding box
# ---------------------------------------------------------------------------

func bounding_box(tolerance: float = -1.0) -> BdgBoundBox:
	var box := OcgBndBox.new()
	if tolerance > 0.0:
		box.set_gap(tolerance)
	OcgBRepBndLib.add(_wrapped, box, true)
	return BdgBoundBox.new(box)

# ---------------------------------------------------------------------------
# Extrusion (mirror build123d _extrude_topods_shape)
# ---------------------------------------------------------------------------

## Extrude this shape along direction. Vertices->Edges, Edges->Faces,
## Wires->Shells, Faces->Solids, Shells->Compounds.
func extrude(direction: Vector3) -> BdgShape:
	var prism := OcgBRepPrimAPIMakePrism.from_i(
		_wrapped, OcgGpVec.from_6(direction.x, direction.y, direction.z)
	)
	var result := prism.shape()
	if result.shape_type() == BdgEnums.ShapeType.COMPSOLID:
		var solids: Array = []
		var explorer := OcgTopExpExplorer.from_4(result, int(BdgEnums.ShapeType.SOLID), int(BdgEnums.ShapeType.SHAPE))
		while explorer.more():
			solids.append(BdgShape.cast(explorer.current()))
			explorer.next()
		result = make_compound_of(solids)._wrapped
	return BdgShape.cast(result)

# ---------------------------------------------------------------------------
# Boolean operations
# ---------------------------------------------------------------------------

func _bool_op(args: Array, tools: Array, op_name: String) -> BdgShape:
	# Determine highest order class among self + args + tools (Solid > Vertex)
	var order := 0
	var base_class: String = "BdgShape"
	for s: BdgShape in [self] + args + tools:
		var o := _class_order(s)
		if o > order:
			order = o
			base_class = s.get_script().get_global_name()

	# Handle empty-tool / empty-arg degenerate cases like build123d
	if op_name == "cut" and tools.is_empty():
		if args.size() == 1:
			var one := args[0] as BdgShape
			return BdgShape.cast(one._wrapped)
		return BdgShape.make_compound_of(args)
	elif op_name == "fuse":
		if args.size() == 1 and tools.is_empty():
			var one := args[0] as BdgShape
			return BdgShape.cast(one._wrapped)
		elif args.is_empty() and not tools.is_empty():
			return BdgShape.make_compound_of(tools)
	elif op_name == "intersect" and (args.is_empty() or tools.is_empty()):
		return BdgShape.new()

	# Build the boolean using the verified two-shape constructor path:
	# fuse/cut/common constructors take (S1, S2) or (S1, S2, PaveFiller).
	# Multi-shape operations fold the extra shapes into a compound.
	var wrapped_args: Array[OcgTopoDSShape] = []
	for obj in args:
		if obj._wrapped != null:
			wrapped_args.append(obj._wrapped)
	var wrapped_tools: Array[OcgTopoDSShape] = []
	for obj in tools:
		if obj._wrapped != null:
			wrapped_tools.append(obj._wrapped)

	if wrapped_args.is_empty():
		wrapped_args.append(_wrapped)

	var op: RefCounted = null
	var topo_result: OcgTopoDSShape = null
	var rng := OcgMessageProgressRange.new()

	if op_name == "fuse":
		if wrapped_tools.size() == 1:
			op = OcgBRepAlgoAPIFuse.from_b(wrapped_args[0], wrapped_tools[0], rng)
		else:
			var tool_comp := _make_compound_topo(wrapped_tools)
			op = OcgBRepAlgoAPIFuse.from_b(wrapped_args[0], tool_comp, rng)
		topo_result = op.shape()
	elif op_name == "cut":
		if wrapped_tools.size() == 1:
			op = OcgBRepAlgoAPICut.from_b(wrapped_args[0], wrapped_tools[0], rng)
		else:
			var tool_comp := _make_compound_topo(wrapped_tools)
			op = OcgBRepAlgoAPICut.from_b(wrapped_args[0], tool_comp, rng)
		topo_result = op.shape()
	elif op_name == "intersect":
		if wrapped_tools.size() == 1:
			op = OcgBRepAlgoAPICommon.from_b(wrapped_args[0], wrapped_tools[0], rng)
		else:
			var tool_comp := _make_compound_topo(wrapped_tools)
			op = OcgBRepAlgoAPICommon.from_b(wrapped_args[0], tool_comp, rng)
		topo_result = op.shape()

	if topo_result == null or topo_result.is_null():
		return BdgShape.new()

	# Unwrap single-result compounds
	var result := BdgShape.cast(topo_result)
	_copy_attributes(result)
	return result

# ---------------------------------------------------------------------------
# Meshing / tessellation
# ---------------------------------------------------------------------------

## Tessellate this shape into Godot-native vertex/triangle arrays.
## Returns [vertices: PackedVector3Array, triangles: PackedInt32Array].
## tolerance (linear) and angular_tolerance (degrees) control mesh density.
func tessellate(tolerance: float = 0.1, angular_tolerance: float = 10.0) -> Array:
	var mesh := OcgBRepMeshIncrementalMesh.from_z(
		_wrapped, tolerance, false, deg_to_rad(angular_tolerance), false
	)
	mesh.perform_W(OcgMessageProgressRange.new())
	var vertices := PackedVector3Array()
	var triangles := PackedInt32Array()
	for face in faces():
		var loc := OcgTopLocLocation.new()
		var tri := OcgBRepTool.triangulation(face._wrapped, loc, 0)
		if tri == null:
			continue
		var trsf := loc.transformation()
		var base := vertices.size()
		for i in tri.nb_nodes():
			var p := tri.node(i + 1).transformed(trsf)
			vertices.append(Vector3(p.x(), p.y(), p.z()))
		for t in tri.nb_triangles():
			var tr := tri.triangle(t + 1)
			triangles.append(base + tr.value(1) - 1)
			triangles.append(base + tr.value(2) - 1)
			triangles.append(base + tr.value(3) - 1)
	return [vertices, triangles]

static func _make_compound_topo(shapes: Array[OcgTopoDSShape]) -> OcgTopoDSShape:
	if shapes.size() == 1:
		return shapes[0]
	var builder := OcgTopoDSBuilder.new()
	var comp := OcgTopoDSCompound.new()
	builder.make_compound(comp)
	for s in shapes:
		builder.add(comp, s)
	return comp

func _class_order(s: BdgShape) -> int:
	match s.shape_type():
		BdgEnums.ShapeType.SOLID, BdgEnums.ShapeType.COMPSOLID: return 4
		BdgEnums.ShapeType.SHELL: return 3
		BdgEnums.ShapeType.FACE: return 2
		BdgEnums.ShapeType.WIRE: return 1
		BdgEnums.ShapeType.EDGE: return 1
		BdgEnums.ShapeType.VERTEX: return 0
	return 0

## fuse all shapes into one
func fuse(other: BdgShape) -> BdgShape:
	return _bool_op([self], [other], "fuse")

func cut(other: BdgShape) -> BdgShape:
	return _bool_op([self], [other], "cut")

func intersect(other: BdgShape) -> BdgShape:
	return _bool_op([self], [other], "intersect")

## fuse with multiple tools at once
func fuse_all(tools: Array) -> BdgShape:
	return _bool_op([self], tools, "fuse")

## cut with multiple tools at once
func cut_all(tools: Array) -> BdgShape:
	return _bool_op([self], tools, "cut")

## intersect with multiple tools at once
func intersect_all(tools: Array) -> BdgShape:
	return _bool_op([self], tools, "intersect")

## Revolve this shape around an axis by angle_deg (360 = full). Returns a BdgShape.
func revolve(angle_deg: float, axis: BdgAxis = BdgAxis.Z) -> BdgShape:
	if is_null():
		return self
	var angle := deg_to_rad(angle_deg)
	var gp_axis := OcgGpAx1.from_n(
		OcgGpPnt.from_6(axis.position.x, axis.position.y, axis.position.z),
		OcgGpDir.from_6(axis.direction.x, axis.direction.y, axis.direction.z),
	)
	var builder := OcgBRepPrimAPIMakeRevol.from_V(_wrapped, gp_axis, angle, false)
	var result := builder.shape()
	if result.shape_type() == BdgEnums.ShapeType.COMPSOLID:
		var solids: Array = []
		var explorer := OcgTopExpExplorer.from_4(result, int(BdgEnums.ShapeType.SOLID), int(BdgEnums.ShapeType.SHAPE))
		while explorer.more():
			solids.append(BdgShape.cast(explorer.current()))
			explorer.next()
		result = make_compound_of(solids)._wrapped
	return BdgShape.cast(result)

## Sweep this profile shape along a spine wire. Returns the swept shape.
func sweep(spine: BdgWire, aux_spines: Array = [], is_frenet: bool = false) -> BdgShape:
	if is_null():
		return self
	if aux_spines.is_empty():
		var trihedron := OcgEnums.GeomFill_Trihedron.GeomFill_IsFrenet if is_frenet else OcgEnums.GeomFill_Trihedron.GeomFill_IsCorrectedFrenet
		var pipe := OcgBRepOffsetAPIMakePipe.from_1(spine._wrapped, _wrapped, trihedron, false)
		var result := pipe.shape()
		return BdgShape.cast(_unwrap_compound(result))
	var pshell := OcgBRepOffsetAPIMakePipeShell.from_I(spine._wrapped)
	pshell.set_mode_c(is_frenet)
	pshell.add_T(_wrapped)
	for s in aux_spines:
		if s is BdgWire:
			pshell.set_mode_g(s._wrapped, true, OcgEnums.BRepFill_TypeOfContact.BRepFill_NoContact)
			pshell.add_T(_wrapped)
	pshell.build(null)
	var result: BdgShape = BdgShape.cast(_unwrap_compound(pshell.shape()))
	var shell := _shape_of_type(result._wrapped, BdgEnums.ShapeType.SHELL)
	if shell != null:
		var faces: Array = shell.faces()
		result = BdgShape.make_compound_of(faces)
	return result

## Thicken a face (or shell) outward by amount (negative = inward). Returns a BdgShape.
func thicken(amount: float) -> BdgShape:
	if is_null():
		return self
	var thick := OcgBRepOffsetAPIMakeThickSolid.new()
	thick.make_thick_solid_by_simple(_wrapped, amount)
	thick.build(null)
	if not thick.is_done():
		push_error("BdgShape.thicken failed")
		return null
	return BdgShape.cast(_unwrap_compound(thick.shape()))

## World coord section of this shape with a plane. Returns edges (array of BdgEdge).
func section(plane: BdgPlane = null) -> Array:
	if is_null():
		return []
	if plane == null:
		plane = BdgPlane.XY
	var pln := OcgGpPln.from_k(OcgGpAx3.from_v(_plane_to_ax2(plane)))
	var sectioner := OcgBRepAlgoAPISection.from_M(_wrapped, pln, true)
	var result := sectioner.shape()
	var edges: Array = []
	var explorer := OcgTopExpExplorer.from_4(result, int(BdgEnums.ShapeType.EDGE), int(BdgEnums.ShapeType.SHAPE))
	while explorer.more():
		edges.append(BdgShape.cast(explorer.current()))
		explorer.next()
	return edges

func _unwrap_compound(shape: OcgTopoDSShape) -> OcgTopoDSShape:
	if shape.shape_type() == BdgEnums.ShapeType.COMPOUND:
		var solids: Array = []
		var explorer := OcgTopExpExplorer.from_4(shape, int(BdgEnums.ShapeType.SOLID), int(BdgEnums.ShapeType.SHAPE))
		while explorer.more():
			solids.append(BdgShape.cast(explorer.current()))
			explorer.next()
		if not solids.is_empty():
			return make_compound_of(solids)._wrapped
		var faces: Array = []
		explorer = OcgTopExpExplorer.from_4(shape, int(BdgEnums.ShapeType.FACE), int(BdgEnums.ShapeType.SHAPE))
		while explorer.more():
			faces.append(BdgShape.cast(explorer.current()))
			explorer.next()
		if not faces.is_empty():
			return make_compound_of(faces)._wrapped
	return shape

func _shape_of_type(shape: OcgTopoDSShape, topo_type: int) -> BdgShape:
	var explorer := OcgTopExpExplorer.from_4(shape, int(topo_type), int(BdgEnums.ShapeType.SHAPE))
	while explorer.more():
		var s := BdgShape.cast(explorer.current())
		return s
	return null

static func _plane_to_ax2(plane: BdgPlane) -> OcgGpAx2:
	var pnt := OcgGpPnt.from_6(plane.origin.x, plane.origin.y, plane.origin.z)
	var n := OcgGpDir.from_6(plane.z_dir.x, plane.z_dir.y, plane.z_dir.z)
	var vx := OcgGpDir.from_6(plane.x_dir.x, plane.x_dir.y, plane.x_dir.z)
	return OcgGpAx2.from_S(pnt, n, vx)

# ---------------------------------------------------------------------------
# Entity extraction (vertices/edges/faces/...)
# ---------------------------------------------------------------------------

func entities(topo_type: int) -> Array[OcgTopoDSShape]:
	var result: Array[OcgTopoDSShape] = []
	if is_null():
		return result
	var m := OcgNCollectionIndexedMapTopoDSShapeTopToolsShapeMapHasher.new()
	OcgTopExp.map_shapes_H(_wrapped, int(topo_type), m)
	for i in range(1, m.extent() + 1):
		result.append(OcgTopoDSShape.cast(m.find_key_T(i)))
	return result

func vertices() -> Array:
	var res: Array = []
	for e in entities(BdgEnums.ShapeType.VERTEX):
		var v := BdgVertex.new(e)
		v.topo_parent = self
		res.append(v)
	return res

func edges() -> Array:
	var res: Array = []
	for e in entities(BdgEnums.ShapeType.EDGE):
		var edge := BdgEdge.new(e)
		edge.topo_parent = self
		res.append(edge)
	return res

func wires() -> Array:
	var res: Array = []
	for e in entities(BdgEnums.ShapeType.WIRE):
		var w := BdgWire.new(e)
		w.topo_parent = self
		res.append(w)
	return res

func faces() -> Array:
	var res: Array = []
	for e in entities(BdgEnums.ShapeType.FACE):
		var f := BdgFace.new(e)
		f.topo_parent = self
		res.append(f)
	return res

func shells() -> Array:
	var res: Array = []
	for e in entities(BdgEnums.ShapeType.SHELL):
		var s := BdgShell.new(e)
		s.topo_parent = self
		res.append(s)
	return res

func solids() -> Array:
	var res: Array = []
	for e in entities(BdgEnums.ShapeType.SOLID):
		var s := BdgSolid.new(e)
		s.topo_parent = self
		res.append(s)
	return res

func compounds() -> Array:
	var res: Array = []
	for e in entities(BdgEnums.ShapeType.COMPOUND):
		res.append(BdgCompound.new(e))
	return res

func vertex() -> BdgVertex:
	var es := vertices()
	return es[0] if not es.is_empty() else null

func edge() -> BdgEdge:
	var es := edges()
	return es[0] if not es.is_empty() else null

func wire() -> BdgWire:
	var es := wires()
	return es[0] if not es.is_empty() else null

func face() -> BdgFace:
	var es := faces()
	return es[0] if not es.is_empty() else null

func shell() -> BdgShell:
	var es := shells()
	return es[0] if not es.is_empty() else null

func solid() -> BdgSolid:
	var es := solids()
	return es[0] if not es.is_empty() else null

func compound() -> BdgCompound:
	var es := compounds()
	return es[0] if not es.is_empty() else null

## get_top_level_shapes - first level non-compound children
func get_top_level_shapes() -> Array:
	var res: Array = []
	if is_null():
		return res
	var collected: Array[OcgTopoDSShape] = []
	_collect_top_level(_wrapped, collected)
	for s in collected:
		res.append(BdgShape.cast(s))
	return res

func _collect_top_level(shape: OcgTopoDSShape, out: Array[OcgTopoDSShape]) -> void:
	if shape.shape_type() != BdgEnums.ShapeType.COMPOUND:
		out.append(OcgTopoDSShape.cast(shape))
		return
	var it := OcgTopoDSIterator.new()
	it.initialize(shape)
	while it.more():
		var child := it.value()
		if child.shape_type() == BdgEnums.ShapeType.COMPOUND:
			_collect_top_level(child, out)
		else:
			out.append(OcgTopoDSShape.cast(child))
		it.next()

# ---------------------------------------------------------------------------
# Casting / factory
# ---------------------------------------------------------------------------

## Return the right Bdg* wrapper class given an OCCT shape
static func cast(obj: OcgTopoDSShape) -> BdgShape:
	if obj == null or obj.is_null():
		return BdgShape.new()
	var concrete := OcgTopoDSShape.cast(obj)
	match obj.shape_type():
		BdgEnums.ShapeType.VERTEX: return BdgVertex.new(concrete)
		BdgEnums.ShapeType.EDGE: return BdgEdge.new(concrete)
		BdgEnums.ShapeType.WIRE: return BdgWire.new(concrete)
		BdgEnums.ShapeType.FACE: return BdgFace.new(concrete)
		BdgEnums.ShapeType.SHELL: return BdgShell.new(concrete)
		BdgEnums.ShapeType.SOLID: return BdgSolid.new(concrete)
		BdgEnums.ShapeType.COMPSOLID: return BdgCompound.new(concrete)
		BdgEnums.ShapeType.COMPOUND: return BdgCompound.new(concrete)
	return BdgShape.new(concrete)

## Build a compound from an array of BdgShape
static func make_compound_of(shapes: Array) -> BdgShape:
	if shapes.is_empty():
		return BdgShape.new()
	if shapes.size() == 1:
		return shapes[0]
	var builder := OcgTopoDSBuilder.new()
	var compound := OcgTopoDSCompound.new()
	builder.make_compound(compound)
	for s in shapes:
		builder.add(compound, s._wrapped)
	return BdgCompound.new(compound)

func _copy_attributes(target: BdgShape) -> void:
	target.label = label
	target._color = _color
	target.for_construction = for_construction

func _to_string() -> String:
	return "%s(%s)" % [get_script().get_global_name(), _wrapped]

# ---------------------------------------------------------------------------
# OCCT type conversion helpers
# ---------------------------------------------------------------------------

static func _gp_pnt_to_v3(p: OcgGpPnt) -> Vector3:
	if p == null:
		return Vector3.ZERO
	return Vector3(p.x(), p.y(), p.z())

static func _gp_vec_to_v3(v: OcgGpVec) -> Vector3:
	if v == null:
		return Vector3.ZERO
	return Vector3(v.x(), v.y(), v.z())

static func _gp_dir_to_v3(d: OcgGpDir) -> Vector3:
	if d == null:
		return Vector3.ZERO
	return Vector3(d.x(), d.y(), d.z()).normalized()

static func _v3_to_pnt(v: Vector3) -> OcgGpPnt:
	return OcgGpPnt.from_6(v.x, v.y, v.z)

static func _toploc_from_matrix(m: BdgMatrix) -> OcgTopLocLocation:
	return OcgTopLocLocation.from_z(m.wrapped())

static func _location_to_matrix(loc: BdgLocation) -> BdgMatrix:
	return BdgLocation_to_matrix(loc)

static func BdgLocation_to_matrix(loc: BdgLocation) -> BdgMatrix:
	var trsf := OcgGpTrsf.new()
	var q := OcgGpQuaternion.from_r(loc.orientation.x, loc.orientation.y, loc.orientation.z, loc.orientation.w)
	trsf.set_rotation_A(q)
	trsf.set_translation_part(OcgGpVec.from_6(loc.position.x, loc.position.y, loc.position.z))
	var m := BdgMatrix.new()
	m._wrapped = trsf
	return m

## Duplicate a BdgShape (deep copy of wrapped OCCT shape)
static func duplicate_shape(s: BdgShape) -> BdgShape:
	var copier := OcgBRepBuilderAPICopy.from_T(s._wrapped, true, false)
	return BdgShape.cast(copier.modified_shape(s._wrapped))
