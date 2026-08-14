extends SceneTree

func _init() -> void:
	var scene: PackedScene = load("res://demo/viewer.tscn")
	var viewer: Node3D = scene.instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame

	var code_edit: CodeEdit = viewer.get("_code_edit")
	var doc_popup: Control = viewer.get("_doc_popup")

	code_edit.text = "var a = Bdg.box(10,10,10)\nvar b = Bdg.build_part(func():\n\tBdg.hole(5,10)\n)"
	await process_frame

	code_edit.grab_focus()

	# Move caret to column 9 on line 0 (inside "Bdg.box")
	code_edit.set_caret_line(0)
	code_edit.set_caret_column(9)
	await process_frame
	await process_frame
	print("after set caret inside Bdg.box -> visible:", doc_popup.visible, " pos:", doc_popup.position)

	# Now simulate a click via pushing the event to the code edit through gui_input signal emission
	var cl := InputEventMouseButton.new()
	cl.button_index = MOUSE_BUTTON_LEFT
	cl.pressed = true
	cl.position = Vector2(50, 5)
	cl.global_position = Vector2(50, 5)
	code_edit.emit_signal("gui_input", cl)
	await process_frame
	await process_frame
	print("after emitted click -> visible:", doc_popup.visible)

	# Check doc popup parent relation / visibility chain
	print("popup.visible:", doc_popup.visible, " popup.get_tree null?", doc_popup.is_inside_tree())
	# Are ancestors visible?
	var node: Node = doc_popup
	while node != null:
		print("  ancestor:", node.get_class(), " name:", node.name, " visible:", node.visible if "visible" in node else "n/a")
		node = node.get_parent()

	quit()