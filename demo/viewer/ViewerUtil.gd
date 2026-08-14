class_name ViewerUtil
## Shared helpers for the modular BdgViewer UI.
## Owned nodes become saveable into the @tool viewer scene.

static func scene_root(node: Node) -> Node:
	if Engine.is_editor_hint():
		var edited := node.get_tree().edited_scene_root
		if edited != null:
			return edited
	var n: Node = node
	while n.get_parent() != null and n.get_parent() != node.get_tree().root:
		n = n.get_parent()
	return n

static func own_tree(node: Node, root: Node) -> void:
	node.owner = root
	for c in node.get_children():
		own_tree(c, root)

static func extract_symbol_at_col(line: String, col: int) -> String:
	if line.is_empty() or col < 0:
		return ""
	var start: int = clampi(col, 0, line.length())
	while start > 0 and (line[start - 1].is_valid_identifier() or line[start - 1] == "."):
		start -= 1
	var end: int = clampi(col, 0, line.length())
	while end < line.length() and (line[end].is_valid_identifier() or line[end] == "."):
		end += 1
	return line.substr(start, end - start).strip_edges()

static func format_doc_bbcode(doc: Dictionary) -> String:
	var bb := ""
	bb += "[b][color=#6bc9ff]%s[/color][/b]  [color=#ffd166][%s][/color]\n" % [doc.get("name", ""), doc.get("category", "")]
	bb += "[color=#8cd3ff][b]Signature:[/b][/color] [code][color=#e0e8f5]%s[/color][/code]\n" % doc.get("sig", "")
	bb += "[color=#a0a8b4]%s[/color]\n\n" % doc.get("desc", "")

	var params: Array = doc.get("params", [])
	if not params.is_empty():
		bb += "[b][color=#8cd3ff]Parameters:[/color][/b]\n"
		for p in params:
			bb += "  • [b][color=#ffd166]%s[/color][/b] ([color=#85d7ff]%s[/color]): [color=#cfd8dc]%s[/color]\n" % [p.get("name", ""), p.get("type", ""), p.get("desc", "")]
		bb += "\n"

	var ex: String = doc.get("example", "")
	if not ex.is_empty():
		bb += "[b][color=#8cd3ff]Example:[/color][/b]\n[code][color=#a8ffb2]%s[/color][/code]" % ex

	return bb