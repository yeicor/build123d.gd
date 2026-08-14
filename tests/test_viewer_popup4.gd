extends SceneTree

func _init() -> void:
	var scene: PackedScene = load("res://demo/viewer.tscn")
	var viewer: Node3D = scene.instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	await process_frame

	var code_edit: CodeEdit = viewer.get("_code_edit")
	var doc_popup: Control = viewer.get("_doc_popup")

	# The example text that would actually be loaded
	print("Example text first line:")
	print(code_edit.text.split("\n")[0])

	# Test doc lookup for every Bdg. symbol present in the example
	var lines: PackedStringArray = code_edit.text.split("\n")
	var found: Dictionary = {}
	for i in range(min(lines.size(), 30)):
		var line: String = lines[i]
		var chars := line.to_utf8_buffer()
		for col in range(line.length()):
			if line[col] == ".":
				# extract symbol
				var start: int = col
				while start > 0 and (line[start - 1].is_valid_identifier() or line[start - 1] == "."):
					start -= 1
				var end: int = col + 1
				while end < line.length() and (line[end].is_valid_identifier()):
					end += 1
				var sym: String = line.substr(start, end - start)
				if sym.begins_with("Bdg."):
					var doc: Dictionary = BdgDocRegistry.get_doc_for_symbol(sym)
					if not doc.is_empty():
						found[sym] = doc.get("category", "")
	print("Symbols found in example:", found)

	# Move caret to first found symbol and check popup
	if not found.is_empty():
		var target: String = found.keys()[0]
		var sym_col: int = code_edit.text.find(target)
		code_edit.set_caret_line(0)
		code_edit.set_caret_column(sym_col + 1)
		await process_frame
		await process_frame
		print("popup visible for '", target, "':", doc_popup.visible, " at:", doc_popup.position)

	quit()