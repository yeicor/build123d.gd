extends RefCounted
## BdgIO - export/import of CAD files.
## STL export is implemented directly on top of the BRepMesh tessellation
## (no OCCT I/O wrappers required). STEP export needs the classic
## STEPControl_Writer wrapper and is not yet available.
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
