#@tool
extends VBoxContainer
## Owns the CAD API Reference tab: category filter, search, item list, doc
## detail and the "Insert Snippet" button. Emits insert_requested to the
## coordinator which routes it to the code editor.

const BdgDocRegistry = preload("res://addons/build123d.gd/docs/BdgDocRegistry.gd")
const ViewerUtil = preload("res://demo/viewer/ViewerUtil.gd")

signal insert_requested(text: String)

var _api_category_btn: OptionButton
var _api_search_input: LineEdit
var _api_item_list: ItemList
var _api_doc_display: RichTextLabel
var _api_insert_btn: Button
var _filtered_api_docs: Array[Dictionary] = []

func _ready() -> void:
	_api_category_btn = $ApiToolbar/ApiCategory
	_api_search_input = $ApiToolbar/ApiSearch
	_api_item_list = $ApiSplit/ApiList
	_api_doc_display = $ApiSplit/ApiDetail/ApiDoc
	_api_insert_btn = $ApiSplit/ApiDetail/ApiBtnRow/ApiInsertBtn

	_api_category_btn.item_selected.connect(func(_arg): _refresh_api_browser())
	_api_search_input.text_changed.connect(func(_arg): _refresh_api_browser())
	_api_item_list.item_selected.connect(_on_api_item_selected)
	_api_insert_btn.pressed.connect(_on_api_insert_pressed)

	_refresh_api_browser()

func _refresh_api_browser() -> void:
	_api_item_list.clear()
	var cat_idx: int = _api_category_btn.selected
	var cat_name: String = BdgDocRegistry.get_categories()[maxi(0, cat_idx)]
	var q: String = _api_search_input.text.strip_edges()
	_filtered_api_docs = BdgDocRegistry.search_docs(q, cat_name)
	for i in range(_filtered_api_docs.size()):
		var doc: Dictionary = _filtered_api_docs[i]
		_api_item_list.add_item("[%s] %s" % [doc.get("category", ""), doc.get("name", "")])

	if not _filtered_api_docs.is_empty():
		_api_item_list.select(0)
		_display_api_doc(_filtered_api_docs[0])
	else:
		_api_doc_display.text = "[color=#888888]No matching CAD methods found.[/color]"

func _on_api_item_selected(idx: int) -> void:
	if idx >= 0 and idx < _filtered_api_docs.size():
		_display_api_doc(_filtered_api_docs[idx])

func _display_api_doc(doc: Dictionary) -> void:
	_api_doc_display.text = ViewerUtil.format_doc_bbcode(doc)

func _on_api_insert_pressed() -> void:
	var sel: PackedInt32Array = _api_item_list.get_selected_items()
	if sel.is_empty():
		return
	var doc: Dictionary = _filtered_api_docs[sel[0]]
	var raw_insert: String = doc.get("insert", "")
	var clean_insert: String = raw_insert.replace("${0}", "").replace("${1}", "").replace("${2}", "").replace("${3}", "").replace("${4}", "").replace("${5}", "").replace("${6}", "").replace("${7}", "")
	insert_requested.emit(clean_insert)
