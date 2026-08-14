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

	code_edit.text = "var part = Bdg.build_part(func():\n    Bdg.box(50.0, 30.0, 10.0)\n)"
	code_edit.set_caret_line(0)
	code_edit.set_caret_column(11)
	await process_frame
	await process_frame

	print("POPUP visible:", doc_popup.visible)
	print("POPUP pos:", doc_popup.position, " size:", doc_popup.size)
	print("POPUP parent class:", doc_popup.get_parent().get_class(), " parent size:", doc_popup.get_parent().size)
	print("CODEEDIT size:", code_edit.size, " caret draw pos:", code_edit.get_caret_draw_pos())

	var img: Image = root.get_viewport().get_texture().get_image()
	img.save_png("/tmp/opencode/viewer_popup_shot.png")
	print("screenshot saved")

	quit()