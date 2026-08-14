extends SceneTree

func _init() -> void:
	var scene: PackedScene = load("res://demo/viewer.tscn")
	var viewer: Node3D = scene.instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame

	var code_edit: CodeEdit = viewer.get("_code_edit")
	var doc_popup: Control = viewer.get("_doc_popup")
	if code_edit == null:
		print("FAIL: _code_edit not found")
		quit()
		return

	print("code_edit found, has caret_changed:", code_edit.caret_changed.get_connections().size(), " connections")
	print("doc_popup visible initially:", doc_popup.visible)
	print("doc_popup parent:", doc_popup.get_parent().get_class())

	code_edit.text = "var part = Bdg.build_part(func():\n    Bdg.box(50.0, 30.0, 10.0)\n)"
	code_edit.set_caret_line(0)
	code_edit.set_caret_column(11)
	await process_frame

	print("After caret to 'Bdg.build_part' -> popup visible:", doc_popup.visible)

	code_edit.set_caret_line(0)
	code_edit.set_caret_column(0)
	await process_frame
	print("After caret to empty col -> popup visible:", doc_popup.visible)

	quit()
