@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_tool_menu_item("Rebuild build123d Documentation", _on_rebuild_docs)

func _exit_tree() -> void:
	remove_tool_menu_item("Rebuild build123d Documentation")

func _on_rebuild_docs() -> void:
	var doc_builder := load("res://addons/build123d.gd/tools/build_docs.gd")
	if doc_builder != null:
		var docs = doc_builder.generate_documentation()
		doc_builder.write_markdown_reference(docs)
		print("[build123d.gd] Documentation successfully regenerated!")

