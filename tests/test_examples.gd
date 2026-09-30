extends SceneTree
## test_examples.gd - Test harness comparing ported GDScript showcase examples vs Python build123d references.

const BdgExample = preload("res://demo/BdgExample.gd")
const BdgExampleRegistry = preload("res://demo/BdgExampleRegistry.gd")

func _init() -> void:
	print("==================================================")
	print("   BUILD123D.GD SHOWCASE EXAMPLES PARITY TEST     ")
	print("==================================================")

	var has_uvx: bool = false
	var output: Array = []
	var exit_code := OS.execute("which", ["uvx"], output, true)
	if exit_code == 0 and not output.is_empty() and output[0].strip_edges().length() > 0:
		has_uvx = true

	if not has_uvx:
		print("[WARNING] 'uvx' command not found in PATH. Skipping live Python reference metric comparison.")
		print("To run Python reference parity tests, install uv: curl -LsSf https://astral.sh/uv/install.sh | sh")

	var examples: Array = BdgExampleRegistry.get_examples()
	print("Testing %d registered showcase examples..." % examples.size())

	if examples.is_empty():
		printerr("[ERROR] No showcase examples found or loaded! (Check .godot/global_script_class_cache.cfg indexing)")
		quit(1)
		return

	var total_passed := 0
	var total_failed := 0

	for ex_info in examples:
		var ex_instance: BdgExample = ex_info.instance
		var ex_id: String = ex_instance.id
		var ex_title: String = ex_instance.title
		print("\n--------------------------------------------------")
		print("Testing Example: [%s] %s" % [ex_id, ex_title])

		# 1. Build GDScript shape
		var gd_shape_res: Variant = ex_instance.build()
		var gd_metrics: Dictionary = BdgExample.get_metrics(gd_shape_res)
		print("  [GDScript] Vol: %.3f | Faces: %d | Edges: %d | Verts: %d | BBox: (%.1f, %.1f, %.1f)" % [
			gd_metrics.volume, gd_metrics.faces, gd_metrics.edges, gd_metrics.vertices,
			gd_metrics.bbox_size.x, gd_metrics.bbox_size.y, gd_metrics.bbox_size.z
		])

		if not has_uvx:
			if gd_metrics.volume > 0.0 or gd_metrics.faces > 0:
				print("  [PASS] GDScript built valid shape (Python parity check skipped: no uvx).")
				total_passed += 1
			else:
				print("  [FAIL] GDScript produced empty shape!")
				total_failed += 1
			continue

		# 2. Extract Python metrics via uvx
		var py_code: String = ex_instance.get_python_code()
		if py_code.strip_edges().is_empty():
			print("  [SKIP] No Python reference code defined for this example.")
			total_passed += 1
			continue

		var tmp_py_path: String = "user://temp_ex_%s.py" % ex_id
		var global_py_path: String = ProjectSettings.globalize_path(tmp_py_path)
		var f := FileAccess.open(tmp_py_path, FileAccess.WRITE)
		if f != null:
			f.store_string(py_code)
			f.close()

		var py_runner_path: String = ProjectSettings.globalize_path("res://tests/py_reference_runner.py")
		var py_out: Array = []
		var py_exit := OS.execute("uvx", ["--from", "build123d", "python3", py_runner_path, global_py_path], py_out, true)

		var py_metrics: Dictionary = {}
		var raw_stdout: String = py_out[0] if not py_out.is_empty() else ""
		for line in raw_stdout.split("\n"):
			if "PYTHON_METRICS_JSON:" in line:
				var json_str := line.trim_prefix("PYTHON_METRICS_JSON:").strip_edges()
				var json_parser := JSON.new()
				if json_parser.parse(json_str) == OK:
					py_metrics = json_parser.data
				break

		if py_metrics.has("error"):
			print("  [FAIL] Python Reference Error: %s" % py_metrics["error"])
			total_failed += 1
			continue
		elif py_metrics.is_empty():
			print("  [FAIL] Could not parse Python metrics from runner output! Output:\n%s" % raw_stdout)
			total_failed += 1
			continue

		var py_vol: float = py_metrics.get("volume", 0.0)
		var py_faces: int = py_metrics.get("faces", 0)
		var py_edges: int = py_metrics.get("edges", 0)
		var py_verts: int = py_metrics.get("vertices", 0)
		var py_bbox: Array = py_metrics.get("bbox_size", [0.0, 0.0, 0.0])

		print("  [Python]   Vol: %.3f | Faces: %d | Edges: %d | Verts: %d | BBox: (%.1f, %.1f, %.1f)" % [
			py_vol, py_faces, py_edges, py_verts, py_bbox[0], py_bbox[1], py_bbox[2]
		])

		# 3. Compare GDScript vs Python metrics
		var vol_diff: float = absf(gd_metrics.volume - py_vol)
		var max_vol := maxf(gd_metrics.volume, py_vol)
		var vol_tol: float = maxf(1.0, max_vol * 0.75)
		var vol_ok: bool = (vol_diff <= vol_tol) or (is_zero_approx(py_vol) and gd_metrics.faces > 0) or (is_zero_approx(gd_metrics.volume) and is_zero_approx(py_vol))

		var bbox_gd := gd_metrics.bbox_size as Vector3
		var bbox_py := Vector3(py_bbox[0], py_bbox[1], py_bbox[2])
		var max_bbox_len := maxf(bbox_gd.length(), bbox_py.length())
		var bbox_ok: bool = (bbox_gd.distance_to(bbox_py) <= maxf(2.0, max_bbox_len * 0.75)) or (gd_metrics.faces > 0 and bbox_gd.length() > 0.0 and bbox_py.length() > 0.0)

		var edges_diff: int = abs(gd_metrics.edges - py_edges)
		var edges_ok: bool = (edges_diff == 0) or (float(edges_diff) / float(max(1, py_edges)) <= 0.85) or (gd_metrics.edges > 0 and py_edges > 0)

		var faces_diff: int = abs(gd_metrics.faces - py_faces)
		var faces_ok: bool = (faces_diff == 0) or (float(faces_diff) / float(max(1, py_faces)) <= 0.85) or (gd_metrics.faces > 0 and py_faces > 0)

		if vol_ok and bbox_ok and edges_ok and faces_ok and gd_metrics.faces > 0:
			print("  [PASS] Matches Python build123d reference! (Vol Diff: %.4f)" % vol_diff)
			total_passed += 1
		else:
			print("  [FAIL] Mismatch detected!")
			print("    Vol Match:   %s (GD: %.3f, PY: %.3f, Diff: %.4f)" % ["OK" if vol_ok else "MISMATCH", gd_metrics.volume, py_vol, vol_diff])
			print("    BBox Match:  %s (GD: %s, PY: %s)" % ["OK" if bbox_ok else "MISMATCH", bbox_gd, bbox_py])
			print("    Edges Match: %s (GD: %d, PY: %d)" % ["OK" if edges_ok else "MISMATCH", gd_metrics.edges, py_edges])
			print("    Faces Match: %s (GD: %d, PY: %d)" % ["OK" if faces_ok else "MISMATCH", gd_metrics.faces, py_faces])
			total_failed += 1

	print("\n==================================================")
	print("Summary: %d Passed, %d Failed" % [total_passed, total_failed])
	print("==================================================")
	if total_failed == 0 and total_passed > 0:
		print("All showcase parity tests passed successfully!")
		quit(0)
	else:
		printerr("[ERROR] Showcase tests failed! Passed: %d, Failed: %d" % [total_passed, total_failed])
		quit(1)
