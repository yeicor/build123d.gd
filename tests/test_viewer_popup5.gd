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

	# 1. Test with actual loaded example text over a class-based symbol
	var line0: String = code_edit.text.split("\n")[0]
	print("line0:", line0)
	var idx: int = line0.find("make_box")
	if idx >= 0:
		code_edit.set_caret_line(0)
		code_edit.set_caret_column(idx + 2)
		await process_frame
		await process_frame
		print("cursor over 'make_box' (class API) -> popup:", doc_popup.visible)

	# 2. Test with a Bdg. DSL symbol
	code_edit.text = "var p := Bdg.box(50.0, 30.0, 10.0)"
	code_edit.set_caret_line(0)
	code_edit.set_caret_column(10)
	await process_frame
	await process_frame
	print("cursor over 'Bdg.box' (DSL API) -> popup:", doc_popup.visible)

	quit()