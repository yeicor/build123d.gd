#@tool
extends PanelContainer
## Owns the compact top application toolbar (example selector, build, camera
## presets, focus, export). Emits high-level signals to the coordinator.

signal example_selected(idx: int)
signal reset_pressed
signal build_pressed
signal view_requested(pitch: float, yaw: float)
signal center_requested
signal export_requested(id: int)
signal toggle_editor_toggled(pressed: bool)

var _toggle_editor_btn: Button
var _example_dropdown: OptionButton
var _spinner_label: Label
var _status_label: Label

func _ready() -> void:
	_toggle_editor_btn = $ToolbarRow/ToggleEditorBtn
	_example_dropdown = $ToolbarRow/ExampleDropdown
	_spinner_label = $ToolbarRow/SpinnerLabel
	_status_label = $ToolbarRow/StatusLabel

	$ToolbarRow/ResetBtn.pressed.connect(func(): reset_pressed.emit())
	$ToolbarRow/RunBtn.pressed.connect(func(): build_pressed.emit())
	$ToolbarRow/CamIsoBtn.pressed.connect(func(): view_requested.emit(30.0, 45.0))
	$ToolbarRow/CamTopBtn.pressed.connect(func(): view_requested.emit(89.9, 0.0))
	$ToolbarRow/CamFrontBtn.pressed.connect(func(): view_requested.emit(0.0, 0.0))
	$ToolbarRow/CamRightBtn.pressed.connect(func(): view_requested.emit(0.0, 90.0))
	$ToolbarRow/FocusBtn.pressed.connect(func(): center_requested.emit())
	$ToolbarRow/ExportBtn.get_popup().id_pressed.connect(func(id: int): export_requested.emit(id))
	_toggle_editor_btn.toggled.connect(func(pressed: bool): toggle_editor_toggled.emit(pressed))
	_example_dropdown.item_selected.connect(func(idx: int): example_selected.emit(idx))

	_status_label.text = "0.0 ms"
	_status_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))

func set_examples(examples: Array[Dictionary]) -> void:
	_example_dropdown.clear()
	for i in range(examples.size()):
		_example_dropdown.add_item(examples[i]["name"], i)

func set_busy(busy: bool) -> void:
	if _spinner_label == null:
		return
	_spinner_label.visible = busy
	_spinner_label.rotation = 0.0

func set_status(text: String, color: Color) -> void:
	if _status_label == null:
		return
	_status_label.text = text
	_status_label.add_theme_color_override("font_color", color)

func set_editor_toggle_text(editing: bool) -> void:
	if _toggle_editor_btn == null:
		return
	if editing:
		_toggle_editor_btn.text = "👁 View 3D"
		_toggle_editor_btn.tooltip_text = "Switch to 3D View (F4 / Ctrl+E)"
	else:
		_toggle_editor_btn.text = "⌨ Edit"
		_toggle_editor_btn.tooltip_text = "Switch to Code Editor (F4 / Ctrl+E)"

func set_toggle_state(pressed: bool) -> void:
	_toggle_editor_btn.button_pressed = pressed

func is_editor_visible() -> bool:
	return _toggle_editor_btn.button_pressed

func get_selected_example() -> int:
	return _example_dropdown.selected

func _process(delta: float) -> void:
	if _spinner_label != null and _spinner_label.visible:
		_spinner_label.pivot_offset = _spinner_label.size * 0.5
		_spinner_label.rotation += delta * 10.0
