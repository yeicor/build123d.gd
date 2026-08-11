extends RefCounted
## BdgIO - export/import of CAD files.
## STL export uses the BRepMesh tessellation; STL import uses RWStl.
## STEP export uses STEPControl_Writer; STEP import uses STEPCAFControl_Reader.
class_name BdgIO

## Export a shape as an ASCII STL file.
## Returns true on success.
static func export_stl(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 10.0) -> bool:
	var tess := shape.tessellate(tolerance, angular_tolerance)
	var vertices: PackedVector3Array = tess[0]
	var triangles: PackedInt32Array = tess[1]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("BdgIO.export_stl: cannot open %s" % path)
		return false
	f.store_string("solid build123d\n")
	for i in range(0, triangles.size(), 3):
		var a := vertices[triangles[i]]
		var b := vertices[triangles[i + 1]]
		var c := vertices[triangles[i + 2]]
		var normal := (b - a).cross(c - a).normalized()
		f.store_string("  facet normal %.6e %.6e %.6e\n" % [normal.x, normal.y, normal.z])
		f.store_string("    outer loop\n")
		f.store_string("      vertex %.6e %.6e %.6e\n" % [a.x, a.y, a.z])
		f.store_string("      vertex %.6e %.6e %.6e\n" % [b.x, b.y, b.z])
		f.store_string("      vertex %.6e %.6e %.6e\n" % [c.x, c.y, c.z])
		f.store_string("    endloop\n")
		f.store_string("  endfacet\n")
	f.store_string("endsolid build123d\n")
	f.close()
	return true

## Export a shape as a STEP file (AP214 / ManifoldSolidBrep).
## Returns true on success.
static func export_step(shape: BdgShape, path: String) -> bool:
	var session_reader := OcgXSControlReader.from_f("STEP")
	if session_reader == null:
		push_error("BdgIO.export_step: cannot create STEP session")
		return false
	var writer := OcgSTEPControlWriter.from_v(session_reader.ws(), true)
	var mode := OcgEnums.STEPControl_StepModelType.STEPControl_ManifoldSolidBrep
	var tstat: int = writer.transfer_z(shape.wrapped(), mode, false, OcgMessageProgressRange.new())
	# A successful transfer reports RetDone (existing model) or RetVoid (new model).
	if tstat != OcgEnums.IFSelect_ReturnStatus.IFSelect_RetDone and tstat != OcgEnums.IFSelect_ReturnStatus.IFSelect_RetVoid:
		push_error("BdgIO.export_step: transfer failed with status %d" % tstat)
		return false
	var chunks: Array[String] = []
	var sink := func(text: String) -> void:
		chunks.append(text)
	writer.write_stream(sink)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("BdgIO.export_step: cannot open %s" % path)
		return false
	for chunk in chunks:
		f.store_string(chunk)
	f.close()
	return true

## Import an STL file (ASCII or binary) as a reference Face.
## The result is a mesh-based face, suitable for viewing or meshing,
## not for CAD boolean editing.
## Returns null on failure.
static func import_stl(path: String) -> BdgShape:
	var tri := OcgRWStl.read_file_D(path, OcgMessageProgressRange.new())
	if tri == null:
		return null
	var face := OcgTopoDSFace.new()
	var builder := OcgBRepBuilder.new()
	builder.make_face_U(face, tri)
	return BdgShape.cast(face)

## Import a STEP file using the XCAF reader, preserving assemblies, names,
## locations and colors. Returns a BdgShape (a BdgCompound for multi-root
## files, the single root shape for single-root files). Null on failure.
static func import_step(path: String) -> BdgShape:
	var doc := OcgTDocStdDocument.from_d(OcgTCollectionExtendedString.from_j("XCAF"))
	if doc == null:
		push_error("BdgIO.import_step: cannot create XCAF document")
		return null
	var reader := OcgSTEPCAFControlReader.new()
	reader.set_name_mode(true)
	reader.set_color_mode(true)
	reader.set_layer_mode(true)
	var ok := reader.perform_t(OcgTCollectionAsciiString.from_a(path), doc, OcgMessageProgressRange.new())
	if not ok:
		push_error("BdgIO.import_step: failed to read %s" % path)
		return null
	var shape_tool := OcgXCAFDocDocumentTool.shape_tool(doc.main())
	var color_tool := OcgXCAFDocDocumentTool.color_tool(doc.main())
	var free := OcgNCollectionSequenceTDFLabel.new()
	shape_tool.get_free_shapes(free)
	var children := _step_assembly(shape_tool, color_tool, free)
	if children.is_empty():
		push_error("BdgIO.import_step: no shapes found in %s" % path)
		return null
	if children.size() == 1:
		return children[0]
	return BdgCompound.make_compound(children)

static func _step_assembly(
	shape_tool: OcgXCAFDocShapeTool,
	color_tool: OcgXCAFDocColorTool,
	labels: OcgNCollectionSequenceTDFLabel
) -> Array:
	var result: Array = []
	for i in range(labels.length()):
		var label: OcgTDFLabel = labels.value_T(i + 1)
		var source := label
		if OcgXCAFDocShapeTool.is_reference(label):
			var ref := OcgTDFLabel.new()
			if not OcgXCAFDocShapeTool.get_referred_shape(label, ref):
				continue
			source = ref
		var shape: BdgShape = null
		if OcgXCAFDocShapeTool.is_assembly(source):
			var comp := OcgNCollectionSequenceTDFLabel.new()
			shape_tool.get_components(source, comp, true)
			shape = BdgCompound.make_compound(_step_assembly(shape_tool, color_tool, comp))
		else:
			var topo := OcgXCAFDocShapeTool.get_shape_A(source)
			if topo == null or topo.is_null():
				continue
			shape = BdgShape.cast(topo)
		var loc := OcgXCAFDocShapeTool.get_location(label)
		if loc != null:
			shape = shape.located(BdgLocation.new(loc))
		shape.label = _step_label_name(label, source)
		var color := _step_color(color_tool, shape)
		if color != null:
			shape._color = color
		result.append(shape)
	return result

static func _step_label_name(label: OcgTDFLabel, source: OcgTDFLabel) -> String:
	var attr := OcgTDataStdName.new()
	var id := OcgTDataStdName.get_id()
	if label.find_attribute_N(id, attr) and attr.get() != "":
		return attr.get()
	if not label.is_equal(source):
		attr = OcgTDataStdName.new()
		if source.find_attribute_N(id, attr) and attr.get() != "":
			return attr.get()
	return ""

static func _step_color(color_tool: OcgXCAFDocColorTool, shape: BdgShape) -> BdgColor:
	var rgba := OcgQuantityColorRGBA.new()
	for t in [
		OcgEnums.XCAFDoc_ColorType.XCAFDoc_ColorGen,
		OcgEnums.XCAFDoc_ColorType.XCAFDoc_ColorSurf,
		OcgEnums.XCAFDoc_ColorType.XCAFDoc_ColorCurv,
	]:
		if color_tool.get_color_r(shape._wrapped, t, rgba):
			var rgb := rgba.get_rgb()
			return BdgColor.new(Color(rgb.red(), rgb.green(), rgb.blue(), rgba.alpha()))
	return null

## Export a shape as a binary STL file.
## Returns true on success.
static func export_stl_binary(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 10.0) -> bool:
	var tess := shape.tessellate(tolerance, angular_tolerance)
	var vertices: PackedVector3Array = tess[0]
	var triangles: PackedInt32Array = tess[1]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("BdgIO.export_stl: cannot open %s" % path)
		return false
	var header := "binary stl".lpad(80, " ")
	f.store_buffer(header.to_ascii_buffer())
	f.store_32(triangles.size() / 3)
	for i in range(0, triangles.size(), 3):
		var a := vertices[triangles[i]]
		var b := vertices[triangles[i + 1]]
		var c := vertices[triangles[i + 2]]
		var normal := (b - a).cross(c - a).normalized()
		f.store_float(normal.x)
		f.store_float(normal.y)
		f.store_float(normal.z)
		f.store_float(a.x)
		f.store_float(a.y)
		f.store_float(a.z)
		f.store_float(b.x)
		f.store_float(b.y)
		f.store_float(b.z)
		f.store_float(c.x)
		f.store_float(c.y)
		f.store_float(c.z)
		f.store_16(0)
	f.close()
	return true
