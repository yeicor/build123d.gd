@tool
extends SceneTree
## build_docs.gd - Reusable Documentation Generator Tool for build123d.gd.
## Scans docstrings, class definitions, and function signatures across all source files,
## programmatically re-populates BdgDocRegistry.gd database, and exports docs/API_REFERENCE.md.

func _init() -> void:
	print("==================================================")
	print("   BUILD123D.GD AUTOMATED DOC GENERATOR (@tool)   ")
	print("==================================================")
	var docs := generate_documentation()
	update_doc_registry(docs)
	write_markdown_reference(docs)
	print("Successfully updated BdgDocRegistry.gd and docs/API_REFERENCE.md!")
	quit()

static func generate_documentation() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var source_dir := "res://addons/build123d.gd"
	var files := _find_gd_files(source_dir)
	print("Scanning %d GDScript source files..." % files.size())

	for path in files:
		if path.ends_with("BdgDocRegistry.gd") or path.ends_with("build_docs.gd"):
			continue
		var file_docs := _parse_file(path)
		results.append_array(file_docs)

	return results

static func _find_gd_files(dir_path: String) -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	dir.list_dir_begin()
	var filename := dir.get_next()
	while not filename.is_empty():
		if filename.begins_with("."):
			filename = dir.get_next()
			continue
		var full := dir_path.path_join(filename)
		if dir.current_is_dir():
			out.append_array(_find_gd_files(full))
		elif filename.ends_with(".gd"):
			out.append(full)
		filename = dir.get_next()
	return out

static func _parse_file(filepath: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var f := FileAccess.open(filepath, FileAccess.READ)
	if f == null:
		return out
	var content := f.get_as_text()
	f.close()

	var class_match := RegEx.create_from_string("class_name\\s+(\\w+)").search(content)
	var cname := class_match.get_string(1) if class_match != null else filepath.get_file().get_basename()
	var category := _category_for_class(cname)

	var lines := content.split("\n")
	var pending_doc := ""

	for i in lines.size():
		var line := lines[i].strip_edges()
		if line.begins_with("##"):
			var doc_text := line.substr(2).strip_edges()
			if not pending_doc.is_empty():
				pending_doc += " " + doc_text
			else:
				pending_doc = doc_text
		elif line.begins_with("func ") or line.begins_with("static func "):
			var is_static := line.begins_with("static ")
			var func_regex := RegEx.create_from_string("(?:static\\s+)?func\\s+(\\w+)\\s*\\((.*?)\\)(?:\\s*->\\s*([\\w\\.\\[\\]]+))?")
			var match_res := func_regex.search(line)
			if match_res != null:
				var fname := match_res.get_string(1)
				if not fname.begins_with("_"):
					var raw_args := match_res.get_string(2)
					var ret_type := match_res.get_string(3)
					if ret_type.is_empty(): ret_type = "Variant"

					var symbol_name := cname + "." + fname
					var sig := "%s(%s) -> %s" % [symbol_name, raw_args, ret_type]
					if is_static:
						sig = "static " + sig

					var insert_snippet := "%s(%s)" % [symbol_name, "${0}"]
					if raw_args.is_empty():
						insert_snippet = "%s()" % symbol_name

					out.append({
						"category": category,
						"name": symbol_name,
						"class": cname,
						"func": fname,
						"sig": sig,
						"returns": ret_type,
						"desc": pending_doc if not pending_doc.is_empty() else "Method %s in class %s." % [fname, cname],
						"insert": insert_snippet,
						"filepath": filepath
					})
			pending_doc = ""
		elif not line.is_empty() and not line.begins_with("#"):
			pending_doc = ""

	return out

static func _category_for_class(cname: String) -> String:
	if cname in ["Bdg", "BdgBuilder", "BdgBuildPart", "BdgBuildSketch", "BdgBuildLine"]: return "Builders"
	elif cname in ["BdgVector", "BdgAxis", "BdgPlane", "BdgLocation", "BdgMatrix", "BdgBoundBox", "BdgColor"]: return "Math & Geometry"
	elif cname in ["BdgShape", "BdgVertex", "BdgEdge", "BdgWire", "BdgFace", "BdgShell", "BdgSolid", "BdgCompound", "BdgShapeList"]: return "Topology"
	elif cname.begins_with("BdgOps") or cname in ["BdgOperations", "BdgPack"]: return "Operations"
	elif cname in ["BdgIO", "BdgMesh"]: return "I/O & Meshing"
	elif cname.begins_with("BdgBuild") or cname.ends_with("Locations") or cname in ["BdgGridLocations", "BdgHexLocations", "BdgPolarLocations"]: return "Patterns"
	return "Objects"

static func update_doc_registry(docs: Array[Dictionary]) -> void:
	var registry_path := "res://addons/build123d.gd/docs/BdgDocRegistry.gd"
	var f := FileAccess.open(registry_path, FileAccess.WRITE)
	if f == null:
		push_error("Failed to open BdgDocRegistry.gd for writing!")
		return

	f.store_line("extends RefCounted")
	f.store_line("## BdgDocRegistry - Comprehensive API Documentation & Autocompletion Metadata Database.")
	f.store_line("## Programmatically generated from source files by build_docs.gd tool.")
	f.store_line("class_name BdgDocRegistry")
	f.store_line("")
	f.store_line("static var _docs_cache: Array[Dictionary] = []")
	f.store_line("static var _docs_by_name: Dictionary = {}")
	f.store_line("")
	f.store_line("static func get_all_docs() -> Array[Dictionary]:")
	f.store_line("\tif not _docs_cache.is_empty():")
	f.store_line("\t\treturn _docs_cache")
	f.store_line("\t_initialize_database()")
	f.store_line("\treturn _docs_cache")
	f.store_line("")
	f.store_line("static func get_doc_for_symbol(symbol_name: String) -> Dictionary:")
	f.store_line("\tif _docs_by_name.is_empty():")
	f.store_line("\t\t_initialize_database()")
	f.store_line("\tvar clean := symbol_name.strip_edges()")
	f.store_line("\tif _docs_by_name.has(clean):")
	f.store_line("\t\treturn _docs_by_name[clean]")
	f.store_line("\tif not clean.begins_with(\"Bdg.\") and _docs_by_name.has(\"Bdg.\" + clean):")
	f.store_line("\t\treturn _docs_by_name[\"Bdg.\" + clean]")
	f.store_line("\tif clean.begins_with(\"Bdg.\") and _docs_by_name.has(clean.substr(4)):")
	f.store_line("\t\treturn _docs_by_name[clean.substr(4)]")
	f.store_line("\tif \".\" in clean:")
	f.store_line("\t\tvar last_segment := clean.get_slice(\".\", clean.count(\".\"))")
	f.store_line("\t\tif _docs_by_name.has(last_segment):")
	f.store_line("\t\t\treturn _docs_by_name[last_segment]")
	f.store_line("\t\tif _docs_by_name.has(\"Bdg.\" + last_segment):")
	f.store_line("\t\t\treturn _docs_by_name[\"Bdg.\" + last_segment]")
	f.store_line("\treturn {}")
	f.store_line("")
	f.store_line("static func search_docs(query: String, category: String = \"All\") -> Array[Dictionary]:")
	f.store_line("\tvar all := get_all_docs()")
	f.store_line("\tvar q := query.to_lower().strip_edges()")
	f.store_line("\tvar results: Array[Dictionary] = []")
	f.store_line("\tfor item in all:")
	f.store_line("\t\tif category != \"All\" and item.get(\"category\", \"\") != category:")
	f.store_line("\t\t\tcontinue")
	f.store_line("\t\tif q.is_empty():")
	f.store_line("\t\t\tresults.append(item)")
	f.store_line("\t\t\tcontinue")
	f.store_line("\t\tvar name_match: bool = item.get(\"name\", \"\").to_lower().contains(q)")
	f.store_line("\t\tvar desc_match: bool = item.get(\"desc\", \"\").to_lower().contains(q)")
	f.store_line("\t\tvar sig_match: bool = item.get(\"sig\", \"\").to_lower().contains(q)")
	f.store_line("\t\tif name_match or desc_match or sig_match:")
	f.store_line("\t\t\tresults.append(item)")
	f.store_line("\treturn results")
	f.store_line("")
	f.store_line("static func get_categories() -> Array[String]:")
	f.store_line("\treturn [\"All\", \"Builders\", \"Math & Geometry\", \"Topology\", \"Operations\", \"Objects\", \"I/O & Meshing\", \"Patterns\"]")
	f.store_line("")
	f.store_line("static func _initialize_database() -> void:")
	f.store_line("\t_docs_cache = [")

	for i in range(docs.size()):
		var d := docs[i]
		var entry := "\t\t{\"category\": %s, \"name\": %s, \"sig\": %s, \"returns\": %s, \"desc\": %s, \"insert\": %s}" % [
			JSON.stringify(d.get("category", "")),
			JSON.stringify(d.get("name", "")),
			JSON.stringify(d.get("sig", "")),
			JSON.stringify(d.get("returns", "")),
			JSON.stringify(d.get("desc", "")),
			JSON.stringify(d.get("insert", ""))
		]
		if i < docs.size() - 1:
			entry += ","
		f.store_line(entry)

	f.store_line("\t]")
	f.store_line("\t_docs_by_name.clear()")
	f.store_line("\tfor item in _docs_cache:")
	f.store_line("\t\tvar n: String = item.get(\"name\", \"\")")
	f.store_line("\t\tif not n.is_empty():")
	f.store_line("\t\t\t_docs_by_name[n] = item")
	f.store_line("\t\t\tif n.begins_with(\"Bdg.\"):")
	f.store_line("\t\t\t\t_docs_by_name[n.substr(4)] = item")
	f.store_line("")

	f.close()
	print("Programmatically re-populated BdgDocRegistry.gd with %d API entries." % docs.size())

static func write_markdown_reference(docs: Array[Dictionary]) -> void:
	for path in ["res://docs/API_REFERENCE.md", "res://addons/build123d.gd/docs/API_REFERENCE.md"]:
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f == null:
			continue
		f.store_line("# build123d.gd - Complete API Reference")
		f.store_line("\nAutomated reference generated programmatically by `@tool` script `build_docs.gd`.\n")

		var categories: Dictionary = {}
		for d in docs:
			var cat: String = d.get("category", "General")
			if not categories.has(cat):
				categories[cat] = []
			categories[cat].append(d)

		for cat in categories.keys():
			f.store_line("\n## " + cat)
			f.store_line("")
			for d in categories[cat]:
				f.store_line("### `%s`" % d["sig"])
				f.store_line("%s\n" % d["desc"])

		f.close()
