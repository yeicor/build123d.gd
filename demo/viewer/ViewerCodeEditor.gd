#@tool
extends VBoxContainer
## Owns the Code Editor tab: CodeEdit, syntax highlighting, autocompletion,
## live floating doc popup and the error diagnostic panel.

const BdgDocRegistry = preload("res://addons/build123d.gd/docs/BdgDocRegistry.gd")
const ViewerUtil = preload("res://demo/viewer/ViewerUtil.gd")

signal build_requested

var _code_edit: CodeEdit
var _code_edit_style: StyleBoxFlat
var _doc_popup: PanelContainer
var _doc_popup_text: RichTextLabel
var _error_panel: PanelContainer
var _error_label: Label

func _ready() -> void:
	_code_edit = $CodeBox/CodeEdit
	_code_edit_style = _code_edit.get_theme_stylebox("normal") as StyleBoxFlat
	_doc_popup = $CodeBox/DocPopup
	_doc_popup_text = $CodeBox/DocPopup/DocText
	_error_panel = $ErrorPanel
	_error_label = $ErrorPanel/ErrorLabel

	_code_edit.code_completion_prefixes = ["Bdg.", "Bdg", "BdgEnums.", "BdgAxis.", "BdgPlane.", "BdgAlign.", "BdgMode.", "Vector3", "Color", "."]
	_code_edit.gui_input.connect(_on_code_edit_gui_input)
	_code_edit.code_completion_requested.connect(_on_code_completion_requested)
	_code_edit.caret_changed.connect(_on_editor_caret_changed)

	_error_panel.visible = false

func get_code_edit() -> CodeEdit:
	return _code_edit

func get_doc_popup() -> Control:
	return _doc_popup

func get_code() -> String:
	return _code_edit.text

func set_code(text: String) -> void:
	_code_edit.text = text

func set_text_with_caret(text: String, line: int, col: int) -> void:
	_code_edit.text = text
	_code_edit.set_caret_line(line, false, true, 0)
	_code_edit.set_caret_column(col, true, 0)

func insert_snippet(text: String) -> void:
	_code_edit.insert_text_at_caret(text)
	_code_edit.grab_focus()

func show_error(msg: String) -> void:
	_error_label.text = msg
	_error_panel.visible = true

func clear_error() -> void:
	_error_panel.visible = false

func set_transparency(alpha: float) -> void:
	if _code_edit_style != null:
		_code_edit_style.bg_color.a = alpha * 0.95

func set_doc_popup_visible(on: bool) -> void:
	if _doc_popup != null:
		_doc_popup.visible = on

func _on_code_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.ctrl_pressed and event.keycode == KEY_ENTER:
			build_requested.emit()
			_code_edit.accept_event()

func _on_code_completion_requested() -> void:
	var all_docs: Array[Dictionary] = BdgDocRegistry.get_all_docs()
	for doc in all_docs:
		var kind: CodeEdit.CodeCompletionKind = CodeEdit.KIND_CONSTANT if doc.get("category", "") == "Constants" else CodeEdit.KIND_FUNCTION
		var raw_insert: String = doc.get("insert", "")
		var clean_insert: String = raw_insert.replace("${0}", "").replace("${1}", "").replace("${2}", "").replace("${3}", "").replace("${4}", "").replace("${5}", "").replace("${6}", "").replace("${7}", "")
		var name_str: String = doc.get("name", "")
		_code_edit.add_code_completion_option(kind, name_str, clean_insert)
		if name_str.begins_with("Bdg."):
			_code_edit.add_code_completion_option(kind, name_str.substr(4), clean_insert.replace("Bdg.", ""))
	_code_edit.update_code_completion_options(true)

func _on_editor_caret_changed() -> void:
	var line_idx: int = _code_edit.get_caret_line()
	var col_idx: int = _code_edit.get_caret_column()
	var line: String = _code_edit.get_line(line_idx)
	var word: String = ViewerUtil.extract_symbol_at_col(line, col_idx)

	if not word.is_empty():
		var doc: Dictionary = BdgDocRegistry.get_doc_for_symbol(word)
		if not doc.is_empty():
			_doc_popup_text.text = ViewerUtil.format_doc_bbcode(doc)
			_position_doc_popup()
			_doc_popup.visible = true
			return

	_doc_popup.visible = false

func _position_doc_popup() -> void:
	var caret_pos: Vector2 = _code_edit.get_caret_draw_pos()
	var target_pos := caret_pos + Vector2(20.0, 24.0)

	var max_x: float = maxf(10.0, _code_edit.size.x - _doc_popup.size.x - 20.0)
	var max_y: float = maxf(10.0, _code_edit.size.y - _doc_popup.size.y - 20.0)
	target_pos.x = clampf(target_pos.x, 10.0, max_x)
	if target_pos.y > max_y:
		target_pos.y = maxf(10.0, caret_pos.y - _doc_popup.size.y - 8.0)
	_doc_popup.position = target_pos
