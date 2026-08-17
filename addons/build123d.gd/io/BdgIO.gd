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
		f.store_string("  facet normal %.6f %.6f %.6f\n" % [normal.x, normal.y, normal.z])
		f.store_string("    outer loop\n")
		f.store_string("      vertex %.6f %.6f %.6f\n" % [a.x, a.y, a.z])
		f.store_string("      vertex %.6f %.6f %.6f\n" % [b.x, b.y, b.z])
		f.store_string("      vertex %.6f %.6f %.6f\n" % [c.x, c.y, c.z])
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
	var global_path := ProjectSettings.globalize_path(path)
	var tri := OcgRWStl.read_file_D(global_path, OcgMessageProgressRange.new())
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
	var global_path := ProjectSettings.globalize_path(path)
	var ok := reader.perform_t(OcgTCollectionAsciiString.from_a(global_path), doc, OcgMessageProgressRange.new())
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

## Export a shape in native OpenCASCADE BREP format.
static func export_brep(shape: BdgShape, path: String) -> bool:
	if shape == null or shape.is_null():
		push_error("BdgIO.export_brep: shape is null")
		return false
	var global_path := ProjectSettings.globalize_path(path)
	return OcgBRepTools.write_2(shape._wrapped, global_path, OcgMessageProgressRange.new())

## Import an OpenCASCADE BREP file.
static func import_brep(path: String) -> BdgShape:
	var shape := OcgTopoDSShape.new()
	var builder := OcgBRepBuilder.new()
	var global_path := ProjectSettings.globalize_path(path)
	var ok := OcgBRepTools.read_M(shape, global_path, builder, OcgMessageProgressRange.new())
	if not ok or shape.is_null():
		push_error("BdgIO.import_brep: failed to read %s" % path)
		return null
	return BdgShape.cast(shape)

## Export 2D contours / edges of a shape to a vector SVG file.
static func export_svg(shape: BdgShape, path: String, plane: BdgPlane = null, scale_val: float = 1.0) -> bool:
	if shape == null or shape.is_null():
		return false
	var pln := plane if plane != null else BdgPlane.XY
	var es := shape.edges()
	if es.is_empty():
		return false

	var paths_svg: Array[String] = []
	var min_x := 1e9
	var min_y := 1e9
	var max_x := -1e9
	var max_y := -1e9

	for e in es:
		var pts: Array[Vector3] = []
		if e.geom_type() == BdgEnums.GeomType.LINE:
			pts = [e.start_point(), e.end_point()]
		else:
			pts = e.positions(16)
		if pts.size() < 2:
			continue

		var path_str := ""
		for i in pts.size():
			var p3 := pts[i]
			var rel := p3 - pln.origin
			var px := rel.dot(pln.x_dir) * scale_val
			var py := -rel.dot(pln.y_dir) * scale_val # SVG Y points downward
			min_x = minf(min_x, px)
			min_y = minf(min_y, py)
			max_x = maxf(max_x, px)
			max_y = maxf(max_y, py)
			if i == 0:
				path_str += "M %.3f %.3f " % [px, py]
			else:
				path_str += "L %.3f %.3f " % [px, py]
		paths_svg.append(path_str)

	var margin := 5.0
	var w := max_x - min_x + 2.0 * margin
	var h := max_y - min_y + 2.0 * margin
	var vb_x := min_x - margin
	var vb_y := min_y - margin

	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("BdgIO.export_svg: cannot open %s" % path)
		return false

	f.store_string('<svg xmlns="http://www.w3.org/2000/svg" viewBox="%.3f %.3f %.3f %.3f" width="%.3f" height="%.3f">\n' % [vb_x, vb_y, w, h, w, h])
	for p_d in paths_svg:
		f.store_string('  <path d="%s" fill="none" stroke="black" stroke-width="0.5"/>\n' % p_d)
	f.store_string('</svg>\n')
	f.close()
	return true

## Export 2D edges of a shape to a minimal AutoCAD DXF file.
static func export_dxf(shape: BdgShape, path: String, plane: BdgPlane = null) -> bool:
	if shape == null or shape.is_null():
		return false
	var pln := plane if plane != null else BdgPlane.XY
	var es := shape.edges()
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("BdgIO.export_dxf: cannot open %s" % path)
		return false

	f.store_string("0\nSECTION\n2\nENTITIES\n")
	for e in es:
		var pts: Array[Vector3] = []
		if e.geom_type() == BdgEnums.GeomType.LINE:
			pts = [e.start_point(), e.end_point()]
		else:
			pts = e.positions(16)
		for i in range(pts.size() - 1):
			var p1 := pts[i] - pln.origin
			var p2 := pts[i + 1] - pln.origin
			var x1 := p1.dot(pln.x_dir)
			var y1 := p1.dot(pln.y_dir)
			var x2 := p2.dot(pln.x_dir)
			var y2 := p2.dot(pln.y_dir)
			f.store_string("0\nLINE\n8\n0\n")
			f.store_string("10\n%.6f\n20\n%.6f\n30\n0.0\n" % [x1, y1])
			f.store_string("11\n%.6f\n21\n%.6f\n31\n0.0\n" % [x2, y2])
	f.store_string("0\nENDSEC\n0\nEOF\n")
	f.close()
	return true

## Import 2D curves/wires from an SVG file.
static func import_svg(path: String) -> Array[BdgWire]:
	var result: Array[BdgWire] = []
	var global_path := ProjectSettings.globalize_path(path)
	var f := FileAccess.open(global_path, FileAccess.READ)
	if f == null:
		push_error("BdgIO.import_svg: cannot open %s" % path)
		return result

	var content := f.get_as_text()
	f.close()

	# Match path d="..." attributes
	var regex := RegEx.new()
	regex.compile('d="([^"]+)"')
	for m in regex.search_all(content):
		var d_attr := m.get_string(1)
		var wire := _parse_svg_path(d_attr)
		if wire != null:
			result.append(wire)

	return result

static func _parse_svg_path(d: String) -> BdgWire:
	var tokens: Array = []
	var cur_token := ""
	for i in d.length():
		var c := d[i]
		if c in ["M", "m", "L", "l", "H", "h", "V", "v", "C", "c", "Z", "z", ","]:
			if cur_token.strip_edges() != "":
				tokens.append(cur_token.strip_edges())
				cur_token = ""
			if c != ",":
				tokens.append(c)
		elif c in [" ", "\t", "\n", "\r"]:
			if cur_token.strip_edges() != "":
				tokens.append(cur_token.strip_edges())
				cur_token = ""
		else:
			cur_token += c
	if cur_token.strip_edges() != "":
		tokens.append(cur_token.strip_edges())

	var pts: Array[Vector3] = []
	var cur_pos := Vector3.ZERO
	var start_pos := Vector3.ZERO
	var idx := 0
	var is_closed := false

	while idx < tokens.size():
		var cmd: String = tokens[idx]
		idx += 1
		match cmd:
			"M", "m":
				if idx + 1 < tokens.size():
					var x := float(tokens[idx])
					var y := -float(tokens[idx + 1]) # Invert SVG Y
					idx += 2
					cur_pos = Vector3(x, y, 0.0) if cmd == "M" else cur_pos + Vector3(x, y, 0.0)
					start_pos = cur_pos
					pts.append(cur_pos)
			"L", "l":
				if idx + 1 < tokens.size():
					var x := float(tokens[idx])
					var y := -float(tokens[idx + 1])
					idx += 2
					cur_pos = Vector3(x, y, 0.0) if cmd == "L" else cur_pos + Vector3(x, y, 0.0)
					pts.append(cur_pos)
			"H", "h":
				if idx < tokens.size():
					var x := float(tokens[idx])
					idx += 1
					cur_pos.x = x if cmd == "H" else cur_pos.x + x
					pts.append(cur_pos)
			"V", "v":
				if idx < tokens.size():
					var y := -float(tokens[idx])
					idx += 1
					cur_pos.y = y if cmd == "V" else cur_pos.y + y
					pts.append(cur_pos)
			"Z", "z":
				is_closed = true
				if not pts.is_empty() and pts.back().distance_to(start_pos) > 1e-4:
					pts.append(start_pos)

	if pts.size() >= 2:
		return BdgWire.make_polygon(pts, is_closed)
	return null

## Import 2D curves/wires from a DXF file.
static func import_dxf(path: String) -> Array[BdgWire]:
	var result: Array[BdgWire] = []
	var global_path := ProjectSettings.globalize_path(path)
	var f := FileAccess.open(global_path, FileAccess.READ)
	if f == null:
		push_error("BdgIO.import_dxf: cannot open %s" % path)
		return result

	var lines: Array[String] = []
	while not f.eof_reached():
		lines.append(f.get_line().strip_edges())
	f.close()

	var i := 0
	var edges: Array[BdgEdge] = []

	while i < lines.size() - 1:
		var code := lines[i]
		var val := lines[i + 1]
		i += 2

		if code == "0" and val == "LINE":
			var x1 := 0.0; var y1 := 0.0; var x2 := 0.0; var y2 := 0.0
			while i < lines.size() - 1 and lines[i] != "0":
				var c := lines[i]; var v := lines[i + 1]; i += 2
				match c:
					"10": x1 = float(v)
					"20": y1 = float(v)
					"11": x2 = float(v)
					"21": y2 = float(v)
			edges.append(BdgEdge.make_line(Vector3(x1, y1, 0.0), Vector3(x2, y2, 0.0)))

		elif code == "0" and val == "CIRCLE":
			var cx := 0.0; var cy := 0.0; var r := 1.0
			while i < lines.size() - 1 and lines[i] != "0":
				var c := lines[i]; var v := lines[i + 1]; i += 2
				match c:
					"10": cx = float(v)
					"20": cy = float(v)
					"40": r = float(v)
			result.append(BdgWire.make_circle(r, BdgPlane.new(Vector3(cx, cy, 0.0))))

		elif code == "0" and val == "ARC":
			var cx := 0.0; var cy := 0.0; var r := 1.0; var a1 := 0.0; var a2 := 360.0
			while i < lines.size() - 1 and lines[i] != "0":
				var c := lines[i]; var v := lines[i + 1]; i += 2
				match c:
					"10": cx = float(v)
					"20": cy = float(v)
					"40": r = float(v)
					"50": a1 = float(v)
					"51": a2 = float(v)
			edges.append(BdgEdge.make_center_arc(Vector3(cx, cy, 0.0), r, a1, a2 - a1))

	if not edges.is_empty():
		var w := BdgWire.make_wire(edges)
		if w != null:
			result.append(w)

	return result

## Export a shape as Wavefront OBJ format.
static func export_obj(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool:
	if shape == null or shape.is_null():
		return false
	var tess := shape.tessellate(tolerance, angular_tolerance)
	var vertices: PackedVector3Array = tess[0]
	var triangles: PackedInt32Array = tess[1]

	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("BdgIO.export_obj: cannot open %s" % path)
		return false

	f.store_string("# Wavefront OBJ exported by build123d.gd\n")
	f.store_string("o %s\n" % (shape.label if shape.label != "" else "BdgShape"))

	for v in vertices:
		f.store_string("v %.6f %.6f %.6f\n" % [v.x, v.y, v.z])

	for i in range(0, triangles.size(), 3):
		f.store_string("f %d %d %d\n" % [triangles[i] + 1, triangles[i + 1] + 1, triangles[i + 2] + 1])

	f.close()
	return true

## Export a shape as Stanford PLY format.
static func export_ply(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool:
	if shape == null or shape.is_null():
		return false
	var tess := shape.tessellate(tolerance, angular_tolerance)
	var vertices: PackedVector3Array = tess[0]
	var triangles: PackedInt32Array = tess[1]

	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("BdgIO.export_ply: cannot open %s" % path)
		return false

	f.store_string("ply\nformat ascii 1.0\ncomment Exported by build123d.gd\n")
	f.store_string("element vertex %d\nproperty float x\nproperty float y\nproperty float z\n" % vertices.size())
	f.store_string("element face %d\nproperty list uchar int vertex_indices\nend_header\n" % (triangles.size() / 3))

	for v in vertices:
		f.store_string("%.6f %.6f %.6f\n" % [v.x, v.y, v.z])

	for i in range(0, triangles.size(), 3):
		f.store_string("3 %d %d %d\n" % [triangles[i], triangles[i + 1], triangles[i + 2]])

	f.close()
	return true

## Export a shape as GLTF JSON format.
static func export_gltf(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool:
	if shape == null or shape.is_null():
		return false
	var tess := shape.tessellate(tolerance, angular_tolerance)
	var vertices: PackedVector3Array = tess[0]
	var triangles: PackedInt32Array = tess[1]

	var byte_buf := PackedByteArray()
	for v in vertices:
		var buf := PackedByteArray()
		buf.resize(12)
		buf.encode_float(0, v.x)
		buf.encode_float(4, v.y)
		buf.encode_float(8, v.z)
		byte_buf.append_array(buf)
	var v_byte_len := byte_buf.size()

	for t in triangles:
		var buf := PackedByteArray()
		buf.resize(4)
		buf.encode_u32(0, t)
		byte_buf.append_array(buf)
	var total_byte_len := byte_buf.size()

	var b64 := Marshalls.raw_to_base64(byte_buf)
	var uri := "data:application/octet-stream;base64," + b64

	var gltf_dict := {
		"asset": {"version": "2.0", "generator": "build123d.gd"},
		"scene": 0,
		"scenes": [{"nodes": [0]}],
		"nodes": [{"mesh": 0}],
		"meshes": [{
			"primitives": [{
				"attributes": {"POSITION": 0},
				"indices": 1,
				"mode": 4
			}]
		}],
		"buffers": [{"byteLength": total_byte_len, "uri": uri}],
		"bufferViews": [
			{"buffer": 0, "byteOffset": 0, "byteLength": v_byte_len, "target": 34962},
			{"buffer": 0, "byteOffset": v_byte_len, "byteLength": total_byte_len - v_byte_len, "target": 34963}
		],
		"accessors": [
			{"bufferView": 0, "byteOffset": 0, "componentType": 5126, "count": vertices.size(), "type": "VEC3"},
			{"bufferView": 1, "byteOffset": 0, "componentType": 5125, "count": triangles.size(), "type": "SCALAR"}
		]
	}

	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("BdgIO.export_gltf: cannot open %s" % path)
		return false

	f.store_string(JSON.stringify(gltf_dict, "  "))
	f.close()
	return true

## Export model as ZIP archive package for PCBWay fabrication quote
static func export_to_pcbway(shape: BdgShape, path: String) -> bool:
	return export_step(shape, path)

## Import full SVG document metadata along with wires
static func import_svg_document(path: String) -> Dictionary:
	var wires := import_svg(path)
	return {"wires": wires, "count": wires.size()}

## Import SVG path and convert to executable Bdg.build_line GDScript code
static func import_svg_as_buildline_code(path: String) -> String:
	var wires := import_svg(path)
	var code := "var curve = Bdg.build_line(func():\n"
	for w in wires:
		for e in w.edges():
			code += "    Bdg.line(Vector3(%.2f, %.2f, 0), Vector3(%.2f, %.2f, 0))\n" % [
				e.start_point().x, e.start_point().y, e.end_point().x, e.end_point().y
			]
	code += ")\n"
	return code



