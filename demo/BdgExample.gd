extends RefCounted
## BdgExample - Base class for all showcase examples.
## Holds metadata, raw GitHub python_url permalink, and gdscript_code string.
## Evaluates gdscript_code dynamically in build() to eliminate code duplication.
class_name BdgExample

var id: String
var title: String
var category: String
var description: String
var python_url: String
var gdscript_code: String

var _cached_python_code: String = ""

func _init(p_id: String = "", p_title: String = "", p_category: String = "", p_description: String = "", p_python_url: String = "") -> void:
	id = p_id
	title = p_title
	category = p_category
	description = p_description
	python_url = p_python_url

func get_gdscript_code() -> String:
	return gdscript_code

func get_python_code() -> String:
	if not _cached_python_code.is_empty():
		return _cached_python_code

	if python_url.is_empty():
		return ""

	var cache_dir := "user://py_cache"
	DirAccess.make_dir_absolute(cache_dir)
	var cache_file := "%s/%s.py" % [cache_dir, id]

	if FileAccess.file_exists(cache_file):
		var f := FileAccess.open(cache_file, FileAccess.READ)
		if f != null:
			_cached_python_code = f.get_as_text()
			f.close()
			if not _cached_python_code.is_empty():
				return _cached_python_code

	# Download using curl / HTTP
	var out: Array = []
	var exit := OS.execute("curl", ["-s", "-f", python_url], out, true)
	if exit == 0 and not out.is_empty() and not out[0].is_empty():
		_cached_python_code = out[0]
		var f_write := FileAccess.open(cache_file, FileAccess.WRITE)
		if f_write != null:
			f_write.store_string(_cached_python_code)
			f_write.close()
		return _cached_python_code

	return ""

func build() -> Variant:
	if gdscript_code.strip_edges().is_empty():
		push_error("BdgExample: gdscript_code is empty for example %s" % id)
		return null

	var script := GDScript.new()
	var full_source := "extends RefCounted\n\nfunc run() -> Variant:\n"
	var lines := gdscript_code.split("\n")
	for line in lines:
		full_source += "\t" + line + "\n"

	script.source_code = full_source
	var err := script.reload()
	if err != OK:
		push_error("BdgExample: failed to compile GDScript for example %s (Error %d)" % [id, err])
		return null

	var inst = script.new()
	if inst != null and inst.has_method("run"):
		return inst.run()

	return null

static func get_metrics(shape_res: Variant) -> Dictionary:
	var metrics := {
		"volume": 0.0,
		"faces": 0,
		"edges": 0,
		"vertices": 0,
		"bbox_size": Vector3.ZERO,
		"bbox_min": Vector3.ZERO,
		"bbox_max": Vector3.ZERO
	}
	if shape_res == null:
		return metrics

	var target_shape: BdgShape = null
	if shape_res is BdgShape:
		target_shape = shape_res as BdgShape
	elif shape_res is Array:
		var shapes: Array[BdgShape] = []
		for s in shape_res:
			if s is BdgShape:
				shapes.append(s)
		if not shapes.is_empty():
			target_shape = BdgCompound.make_compound(shapes)

	if target_shape == null or target_shape.is_null():
		return metrics

	metrics["volume"] = target_shape.volume()
	metrics["faces"] = target_shape.faces().size()
	metrics["edges"] = target_shape.edges().size()
	metrics["vertices"] = target_shape.vertices().size()

	var bbox: BdgBoundBox = target_shape.bounding_box()
	if bbox != null:
		metrics["bbox_size"] = bbox.size()
		metrics["bbox_min"] = bbox.min
		metrics["bbox_max"] = bbox.max

	return metrics
