extends SceneTree

func _init() -> void:
	var scene: PackedScene = load("res://demo/viewer.tscn")
	var viewer: Node3D = scene.instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame

	var code_edit: CodeEdit = viewer.get("_code_edit")
	var doc_popup: Control = viewer.get("_doc_popup")

	var long_line: String = "var result = Bdg.extrude(Bdg.box(50.0, 30.0, 10.0), 20.0, 0.0, false)  # comment Bdg.build_part"
	code_edit.text = "line0\n" + long_line + "\n" + long_line + "\n" + long_line + "\n" + long_line + "\nlast"
	await process_frame

	# caret at "Bdg.extrude" on line 1
	code_edit.set_caret_line(1)
	code_edit.set_caret_column(13)
	await process_frame
	await process_frame
	print("L1 extrude visible:", doc_popup.visible, " pos:", doc_popup.position)

	# caret in comment at end
	code_edit.set_caret_line(1)
	code_edit.set_caret_column(long_line.length())
	await process_frame
	await process_frame
	print("L1 comment visible:", doc_popup.visible)

	# caret on last line
	code_edit.set_caret_line(5)
	code_edit.set_caret_column(2)
	await process_frame
	await process_frame
	print("L5 visible:", doc_popup.visible, " pos:", doc_popup.position)

	# multiline select
	code_edit.select(0, 0, 5, 5)
	await process_frame
	await process_frame
	print("after select visible:", doc_popup.visible)

	quit()