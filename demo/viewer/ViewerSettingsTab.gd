#@tool
extends VBoxContainer
## Owns the Misc tab: appearance settings, mesh quality controls and the 3D
## geometry metrics readout. Emits high-level signals to the coordinator.

signal transparency_changed(alpha: float)
signal edges_toggled(on: bool)
signal vertices_toggled(on: bool)
signal grid_toggled(on: bool)
signal edge_color_changed(idx: int)
signal vertex_color_changed(idx: int)
signal thickness_changed(scale: float)
signal material_preset_changed(idx: int)
signal texture_scale_changed(val: float)
signal parallel_meshing_changed(on: bool)
signal mesh_detail_changed(val: float)
signal mesh_detail_released

var _sub_panel_styles: Array[StyleBoxFlat] = []
var _transparency_slider: HSlider
var _transparency_label: Label
var _texture_scale_label: Label
var _mesh_detail_label: Label
var _stats_label: RichTextLabel

func _ready() -> void:
	_transparency_slider = $SettingsScroll/SettingsContent/AppearancePanel/AppearanceBox/TransRow/TransparencySlider
	_transparency_label = $SettingsScroll/SettingsContent/AppearancePanel/AppearanceBox/TransRow/TransparencyLabel
	_texture_scale_label = $SettingsScroll/SettingsContent/AppearancePanel/AppearanceBox/TexScaleRow/TexScaleLabel
	_mesh_detail_label = $SettingsScroll/SettingsContent/MeshPanel/MeshBox/DetailRow/MeshDetailLabel
	_stats_label = $SettingsScroll/SettingsContent/MetricsPanel/MetricsBox/StatsLabel

	_sub_panel_styles.append($SettingsScroll/SettingsContent/AppearancePanel.get_theme_stylebox("panel") as StyleBoxFlat)
	_sub_panel_styles.append($SettingsScroll/SettingsContent/MeshPanel.get_theme_stylebox("panel") as StyleBoxFlat)
	_sub_panel_styles.append($SettingsScroll/SettingsContent/MetricsPanel.get_theme_stylebox("panel") as StyleBoxFlat)

	var appearance := $SettingsScroll/SettingsContent/AppearancePanel/AppearanceBox
	var mesh := $SettingsScroll/SettingsContent/MeshPanel/MeshBox

	appearance.get_node("TransRow/TransparencySlider").value_changed.connect(func(val: float):
		_transparency_label.text = "%d%%" % int(val * 100.0)
		transparency_changed.emit(val)
	)
	appearance.get_node("ChecksRow/EdgesCheck").toggled.connect(func(on: bool): edges_toggled.emit(on))
	appearance.get_node("ChecksRow/VerticesCheck").toggled.connect(func(on: bool): vertices_toggled.emit(on))
	appearance.get_node("ChecksRow/GridCheck").toggled.connect(func(on: bool): grid_toggled.emit(on))
	appearance.get_node("ColorsRow/EdgeColorOpt").item_selected.connect(func(idx: int): edge_color_changed.emit(idx))
	appearance.get_node("ColorsRow/VertexColorOpt").item_selected.connect(func(idx: int): vertex_color_changed.emit(idx))
	appearance.get_node("ColorsRow/ThicknessSlider").value_changed.connect(func(val: float): thickness_changed.emit(val))
	appearance.get_node("MaterialRow/MaterialOpt").item_selected.connect(func(idx: int): material_preset_changed.emit(idx))
	appearance.get_node("TexScaleRow/TexScaleSlider").value_changed.connect(func(val: float):
		_texture_scale_label.text = "%.2f" % val
		texture_scale_changed.emit(val)
	)
	mesh.get_node("ParallelCheck").toggled.connect(func(on: bool): parallel_meshing_changed.emit(on))
	mesh.get_node("DetailRow/MeshDetailSlider").value_changed.connect(func(val: float):
		_mesh_detail_label.text = "%.3f mm" % val
		mesh_detail_changed.emit(val)
	)
	mesh.get_node("DetailRow/MeshDetailSlider").drag_ended.connect(func(_v): mesh_detail_released.emit())

func set_stats(text: String) -> void:
	if _stats_label != null:
		_stats_label.text = text

func get_transparency() -> float:
	return _transparency_slider.value

func set_transparency(alpha: float) -> void:
	for style in _sub_panel_styles:
		style.bg_color.a = alpha * 0.95
