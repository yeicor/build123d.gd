#@tool
extends Node3D
## BdgViewer - Full-Featured CAD IDE & Interactive 3D Showcase for build123d.gd.
## Thin coordinator that wires the modular viewer subsystems together and owns
## the background build engine. Each subsystem targets a dedicated scene node.

const BdgExampleRegistry = preload("res://demo/BdgExampleRegistry.gd")
const BdgDSL = preload("res://addons/build123d.gd/dsl/BdgDSL.gd")
const BdgShape = preload("res://addons/build123d.gd/topology/BdgShape.gd")

@onready var _camera3d = $Viewport3D/ViewerCamera3D
@onready var _view3d = $Viewport3D/ViewerView3D
@onready var _toolbar = $UI/RootVBox/Toolbar
@onready var _view_pane = $UI/RootVBox/Workspace/ViewPane
@onready var _editor_container = $UI/RootVBox/Workspace/EditorContainer
@onready var _tabs = $UI/RootVBox/Workspace/EditorContainer/EditorLayout/Tabs
@onready var _code_editor = $UI/RootVBox/Workspace/EditorContainer/EditorLayout/Tabs/CodeEditorTab
@onready var _api_browser = $UI/RootVBox/Workspace/EditorContainer/EditorLayout/Tabs/ApiTab
@onready var _settings_tab = $UI/RootVBox/Workspace/EditorContainer/EditorLayout/Tabs/MiscTab
@onready var _toast_label: Label = $UI/RootVBox/Workspace/ViewPane/ToastLabel

# Back-compat references for existing tests.
var _code_edit: CodeEdit
var _doc_popup: PanelContainer

var _current_shape = null
var _current_tess_tol: float = 0.1
var _texture_scale: float = 0.05

# Background Worker
var _build_thread: Thread = null
var _is_building: bool = false
var _build_counter: int = 0

# Preset Registry
var _examples: Array[Dictionary] = []

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _build_thread != null and _build_thread.is_started():
			_build_thread.wait_to_finish()
			_build_thread = null

func _ready() -> void:
	_code_edit = _code_editor.get_code_edit()
	_doc_popup = _code_editor.get_doc_popup()

	_examples = BdgExampleRegistry.get_examples()
	_toolbar.set_examples(_examples)
	_wire_signals()
	_on_transparency_changed(_settings_tab.get_transparency())

	_view_pane.gui_input.connect(_camera3d.handle_view_pane_input)
	_load_example(0)

func _wire_signals() -> void:
	_toolbar.example_selected.connect(_load_example)
	_toolbar.reset_pressed.connect(_reset_current_example)
	_toolbar.build_pressed.connect(_compile_and_run)
	_toolbar.view_requested.connect(_camera3d.animate_view)
	_toolbar.center_requested.connect(_center_cam_on_model)
	_toolbar.export_requested.connect(_on_export_selected)
	_toolbar.toggle_editor_toggled.connect(_on_toggle_editor_toggled)

	_code_editor.build_requested.connect(_compile_and_run)
	_api_browser.insert_requested.connect(_on_api_insert_requested)

	_settings_tab.transparency_changed.connect(_on_transparency_changed)
	_settings_tab.edges_toggled.connect(_view3d.set_show_edges)
	_settings_tab.vertices_toggled.connect(_view3d.set_show_vertices)
	_settings_tab.grid_toggled.connect(_view3d.set_show_grid)
	_settings_tab.edge_color_changed.connect(_view3d.set_edge_color)
	_settings_tab.vertex_color_changed.connect(_view3d.set_vertex_color)
	_settings_tab.thickness_changed.connect(_view3d.set_edge_thickness)
	_settings_tab.material_preset_changed.connect(_on_material_preset_selected)
	_settings_tab.texture_scale_changed.connect(_on_texture_scale_changed)
	_settings_tab.parallel_meshing_changed.connect(_on_parallel_meshing_changed)
	_settings_tab.mesh_detail_changed.connect(_on_mesh_detail_changed)
	_settings_tab.mesh_detail_released.connect(_on_mesh_detail_released)

	_camera3d.focus_requested.connect(_center_cam_on_model)

func _on_toggle_editor_toggled(pressed: bool) -> void:
	_editor_container.visible = pressed
	_code_editor.set_doc_popup_visible(false)
	_toolbar.set_editor_toggle_text(pressed)

func _load_example(idx: int) -> void:
	if idx < 0 or idx >= _examples.size():
		return
	var ex: Dictionary = _examples[idx]
	var inst: BdgExample = ex.get("instance") as BdgExample
	if inst != null:
		_code_edit.text = inst.get_gdscript_code()
	elif ex.has("instance") and ex["instance"].has_method("get_gdscript_code"):
		_code_edit.text = ex["instance"].get_gdscript_code()
	_compile_and_run()

func _reset_current_example() -> void:
	_load_example(_toolbar.get_selected_example())

func _on_api_insert_requested(text: String) -> void:
	_code_editor.insert_snippet(text)
	_tabs.current_tab = 0

func _compile_and_run() -> void:
	_code_editor.clear_error()
	_code_editor.set_doc_popup_visible(false)
	var src := _code_edit.text.strip_edges()
	if src.is_empty():
		return

	if _is_building and _build_thread != null and _build_thread.is_started():
		return

	_is_building = true
	_toolbar.set_busy(true)
	_toolbar.set_status("Building...", Color(0.4, 0.8, 1.0))
	_build_counter += 1
	var build_id := _build_counter

	if _build_thread != null and _build_thread.is_started():
		_build_thread.wait_to_finish()
	_build_thread = Thread.new()
	_build_thread.start(_bg_build_worker.bind(src, build_id))

func _bg_build_worker(src: String, build_id: int) -> void:
	var start_time := Time.get_ticks_usec()
	var result: Variant = BdgDSL.eval(src)
	var elapsed_ms: float = float(Time.get_ticks_usec() - start_time) / 1000.0

	var tess_res: Array = []
	if result is BdgShape and not (result as BdgShape).is_null():
		tess_res = (result as BdgShape).tessellate_with_uvs(_current_tess_tol, 11.459, _texture_scale)

	call_deferred("_on_bg_build_completed", build_id, result, tess_res, elapsed_ms)

func _on_bg_build_completed(build_id: int, result: Variant, tess_res: Array, elapsed_ms: float) -> void:
	if build_id != _build_counter:
		return
	_is_building = false
	_toolbar.set_busy(false)
	if _build_thread != null and _build_thread.is_started():
		_build_thread.wait_to_finish()
		_build_thread = null

	if result is BdgShape:
		_current_shape = result as BdgShape
		_view3d.display_shape(_current_shape, tess_res)
		_camera3d.frame_shape(_current_shape)
		_update_metrics(tess_res)
		_toolbar.set_status("%.1f ms" % elapsed_ms, Color(0.4, 1.0, 0.6))
	else:
		_current_shape = null
		_view3d.display_shape(null)
		_code_editor.show_error("Script did not return a valid BdgShape (got %s)." % typeof(result))
		_toolbar.set_status("Build failed", Color(1.0, 0.4, 0.4))

func _update_metrics(tess_res: Array) -> void:
	if _current_shape == null or _current_shape.is_null():
		_settings_tab.set_stats("[color=#888888]Empty Shape[/color]")
		return
	var vol: float = _current_shape.volume()
	var bb: Variant = _current_shape.bounding_box()
	var bb_dim: Vector3 = bb.size() if bb != null else Vector3.ZERO
	var faces_cnt: int = _current_shape.faces().size()
	var edges_cnt: int = _current_shape.edges().size()
	var verts_cnt: int = _current_shape.vertices().size()
	var solids_cnt: int = _current_shape.solids().size()
	var tri_count: int = (tess_res[1] as PackedInt32Array).size() / 3 if tess_res.size() > 1 else 0

	_settings_tab.set_stats("""[color=#8cd3ff][b]Volume:[/b][/color] %.2f mm³
[color=#8cd3ff][b]Bounding Box:[/b][/color] %.1f × %.1f × %.1f mm
[color=#8cd3ff][b]Solids:[/b][/color] %d  |  [color=#8cd3ff][b]Faces:[/b][/color] %d
[color=#8cd3ff][b]Edges:[/b][/color] %d  |  [color=#8cd3ff][b]Vertices:[/b][/color] %d
[color=#8cd3ff][b]Triangles:[/b][/color] %d""" % [
		vol, bb_dim.x, bb_dim.y, bb_dim.z,
		solids_cnt, faces_cnt, edges_cnt, verts_cnt, tri_count
	])

func _on_transparency_changed(alpha: float) -> void:
	_code_editor.set_transparency(alpha)
	_settings_tab.set_transparency(alpha)

func _on_texture_scale_changed(val: float) -> void:
	_texture_scale = val
	_view3d.set_texture_scale(val)

func _on_parallel_meshing_changed(on: bool) -> void:
	BdgShape.parallel_meshing = on
	_view3d.set_parallel_meshing(on)

func _on_mesh_detail_changed(val: float) -> void:
	_current_tess_tol = val
	_view3d.set_tess_tol(val)

func _on_mesh_detail_released() -> void:
	_view3d.retessellate()

func _on_material_preset_selected(idx: int) -> void:
	_view3d.set_material_preset(idx)

func _center_cam_on_model() -> void:
	_camera3d.center_on(_current_shape)

func _on_export_selected(id: int) -> void:
	if _current_shape == null:
		_show_toast("No model loaded to export!")
		return

	var base_name: String = "cad_model_" + str(Time.get_unix_time_from_system())
	var user_path: String = "user://" + base_name
	var filename: String = ""
	var mime_type: String = "application/octet-stream"
	var success: bool = false

	match id:
		0:
			filename = base_name + ".step"
			mime_type = "application/step"
			success = BdgDSL.export_step(_current_shape, user_path + ".step")
		1:
			filename = base_name + ".stl"
			mime_type = "model/stl"
			success = BdgDSL.export_stl_binary(_current_shape, user_path + ".stl", 0.01, 12.0)
		2:
			filename = base_name + "_ascii.stl"
			mime_type = "model/stl"
			success = BdgDSL.export_stl(_current_shape, user_path + "_ascii.stl", 0.01, 12.0)
		3:
			filename = base_name + ".obj"
			mime_type = "model/obj"
			success = BdgDSL.export_obj(_current_shape, user_path + ".obj")
		4:
			filename = base_name + ".gltf"
			mime_type = "model/gltf+json"
			success = BdgDSL.export_gltf(_current_shape, user_path + ".gltf")
		5:
			filename = base_name + ".ply"
			mime_type = "application/octet-stream"
			success = BdgDSL.export_ply(_current_shape, user_path + ".ply")
		6:
			filename = base_name + ".brep"
			mime_type = "application/octet-stream"
			success = BdgDSL.export_brep(_current_shape, user_path + ".brep")
		7:
			filename = base_name + ".svg"
			mime_type = "image/svg+xml"
			success = BdgDSL.export_svg(_current_shape, user_path + ".svg")
		8:
			filename = base_name + ".dxf"
			mime_type = "image/vnd.dxf"
			success = BdgDSL.export_dxf(_current_shape, user_path + ".dxf")

	var target_file: String = user_path + filename.substr(base_name.length())

	if OS.has_feature("web"):
		var buffer := FileAccess.get_file_as_bytes(target_file)
		if not buffer.is_empty():
			JavaScriptBridge.download_buffer(buffer, filename, mime_type)
			_show_toast("✓ Download initiated: " + filename)
			return

	if success:
		_show_toast("✓ Exported: " + ProjectSettings.globalize_path(target_file))
	else:
		_show_toast("Export failed: " + ProjectSettings.globalize_path(target_file))

func _show_toast(msg: String) -> void:
	_toast_label.text = msg
	_toast_label.visible = true
	var tw: Tween = create_tween()
	tw.tween_interval(3.0)
	tw.tween_callback(func(): _toast_label.visible = false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.ctrl_pressed and event.keycode == KEY_ENTER:
			_compile_and_run()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F4 or (event.ctrl_pressed and event.keycode == KEY_E):
			_toolbar.set_toggle_state(not _toolbar.is_editor_visible())
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F1:
			_editor_container.visible = true
			_toolbar.set_toggle_state(true)
			_tabs.current_tab = 1
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F2:
			_editor_container.visible = true
			_toolbar.set_toggle_state(true)
			_tabs.current_tab = 2
			get_viewport().set_input_as_handled()
