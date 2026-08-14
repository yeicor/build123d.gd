#@tool
extends Node3D
## Owns the 3D model display: shaded mesh, edge/vertex MultiMesh overlays,
## ground grid, lights, PBR materials and CC0 textures.

# CC0 PBR Textures
var _tex_cad_check_alb: Texture2D = null
var _tex_cad_check_norm: Texture2D = null
var _tex_cad_check_rough: Texture2D = null
var _tex_carbon_alb: Texture2D = null
var _tex_carbon_norm: Texture2D = null
var _tex_grid_alb: Texture2D = null
var _tex_grid_norm: Texture2D = null
var _tex_brushed_alb: Texture2D = null
var _tex_brushed_norm: Texture2D = null

var _model_node: Node3D
var _edge_multimesh_node: MultiMeshInstance3D
var _vertex_multimesh_node: MultiMeshInstance3D
var _ground_grid: Node3D
var _current_shape = null
var _current_tess_tol: float = 0.1
var _material_preset_idx: int = 0
var _show_edges: bool = true
var _show_vertices: bool = true
var _edge_thickness_scale: float = 1.0
var _edge_material: StandardMaterial3D
var _vertex_material: StandardMaterial3D
var _texture_scale: float = 0.05

func _ready() -> void:
	_init_textures()
	_model_node = $Model
	_edge_multimesh_node = $Edges
	_vertex_multimesh_node = $Vertices
	_ground_grid = $Grid
	_edge_material = $Edges.material_override
	_vertex_material = $Vertices.material_override

func _init_textures() -> void:
	_tex_cad_check_alb = _load_texture("res://demo/assets/textures/cad_checkerboard_albedo.png")
	_tex_cad_check_norm = _load_texture("res://demo/assets/textures/cad_checkerboard_normal.png")
	_tex_cad_check_rough = _load_texture("res://demo/assets/textures/cad_checkerboard_roughness.png")
	_tex_carbon_alb = _load_texture("res://demo/assets/textures/carbon_fiber_albedo.png")
	_tex_carbon_norm = _load_texture("res://demo/assets/textures/carbon_fiber_normal.png")
	_tex_grid_alb = _load_texture("res://demo/assets/textures/technical_grid_albedo.png")
	_tex_grid_norm = _load_texture("res://demo/assets/textures/technical_grid_normal.png")
	_tex_brushed_alb = _load_texture("res://demo/assets/textures/brushed_metal_albedo.png")
	_tex_brushed_norm = _load_texture("res://demo/assets/textures/brushed_metal_normal.png")

static func _load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res: Variant = ResourceLoader.load(path)
		if res is Texture2D:
			return res as Texture2D
	if FileAccess.file_exists(path):
		var img := Image.load_from_file(path)
		if img != null and not img.is_empty():
			return ImageTexture.create_from_image(img)
	return null

func get_current_shape() -> Variant:
	return _current_shape

func display_shape(shape: Variant, cached_tess: Array = []) -> void:
	_current_shape = shape
	for child in _model_node.get_children():
		child.queue_free()

	if shape == null or shape.has_method("is_null") and shape.is_null():
		if _edge_multimesh_node != null: _edge_multimesh_node.multimesh = null
		if _vertex_multimesh_node != null: _vertex_multimesh_node.multimesh = null
		return

	var tess_res: Array = cached_tess if not cached_tess.is_empty() else shape.tessellate_with_uvs(_current_tess_tol, 11.459, _texture_scale)
	var vertices: PackedVector3Array = tess_res[0] if tess_res.size() > 0 else PackedVector3Array()
	var triangles: PackedInt32Array = tess_res[1] if tess_res.size() > 1 else PackedInt32Array()
	var uvs: PackedVector2Array = tess_res[2] if tess_res.size() > 2 else PackedVector2Array()

	var arr_mesh := ArrayMesh.new()
	if vertices.size() > 0:
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_INDEX] = triangles
		arrays[Mesh.ARRAY_TEX_UV] = uvs

		var normals := PackedVector3Array()
		normals.resize(vertices.size())
		normals.fill(Vector3.ZERO)
		var tri_count: int = triangles.size() / 3
		for i in range(tri_count):
			var i0: int = triangles[i * 3 + 0]
			var i1: int = triangles[i * 3 + 1]
			var i2: int = triangles[i * 3 + 2]
			var v0: Vector3 = vertices[i0]
			var v1: Vector3 = vertices[i1]
			var v2: Vector3 = vertices[i2]
			var norm: Vector3 = (v1 - v0).cross(v2 - v0).normalized()
			normals[i0] += norm
			normals[i1] += norm
			normals[i2] += norm
		for i in range(normals.size()):
			normals[i] = normals[i].normalized()
		arrays[Mesh.ARRAY_NORMAL] = normals

		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var mesh_inst := MeshInstance3D.new()
	mesh_inst.mesh = arr_mesh
	mesh_inst.material_override = _create_cad_material()
	_model_node.add_child(mesh_inst)

	_build_edge_multimesh(shape)
	_build_vertex_multimesh(shape)

func set_show_edges(on: bool) -> void:
	_show_edges = on
	if _edge_multimesh_node != null:
		_edge_multimesh_node.visible = on

func set_show_vertices(on: bool) -> void:
	_show_vertices = on
	if _vertex_multimesh_node != null:
		_vertex_multimesh_node.visible = on

func set_show_grid(on: bool) -> void:
	if _ground_grid != null:
		_ground_grid.visible = on

func set_edge_color(idx: int) -> void:
	if _edge_material == null:
		return
	match idx:
		0: _edge_material.albedo_color = Color(0.06, 0.07, 0.1)
		1: _edge_material.albedo_color = Color(0.98, 0.98, 1.0)
		2: _edge_material.albedo_color = Color(0.1, 0.85, 1.0)
		3: _edge_material.albedo_color = Color(1.0, 0.5, 0.0)

func set_vertex_color(idx: int) -> void:
	if _vertex_material == null:
		return
	match idx:
		0: _vertex_material.albedo_color = Color(0.98, 0.68, 0.16)
		1: _vertex_material.albedo_color = Color(0.2, 0.85, 1.0)
		2: _vertex_material.albedo_color = Color(1.0, 0.45, 0.1)
		3: _vertex_material.albedo_color = Color(0.98, 0.98, 1.0)
		4: _vertex_material.albedo_color = Color(0.2, 0.9, 0.4)

func set_edge_thickness(scale: float) -> void:
	_edge_thickness_scale = scale
	if _current_shape != null:
		_build_edge_multimesh(_current_shape)
		_build_vertex_multimesh(_current_shape)

func set_material_preset(idx: int) -> void:
	_material_preset_idx = idx
	if _current_shape != null:
		display_shape(_current_shape)

func set_texture_scale(val: float) -> void:
	_texture_scale = val
	if _current_shape != null:
		display_shape(_current_shape)

func set_parallel_meshing(enabled: bool) -> void:
	if _current_shape != null:
		display_shape(_current_shape)

func set_tess_tol(val: float) -> void:
	_current_tess_tol = val

func retessellate() -> void:
	if _current_shape != null:
		display_shape(_current_shape)

func _diagonal_of(bb: Variant) -> float:
	if bb == null or bb.is_void():
		return 100.0
	if bb.has_method("diagonal"):
		return bb.diagonal()
	if bb.has_method("diagonal_length"):
		return bb.diagonal_length()
	return bb.size().length()

func _create_cad_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.rim_enabled = true
	mat.rim = 0.45
	mat.rim_tint = 0.5
	mat.clearcoat_enabled = true
	mat.clearcoat = 0.25
	mat.clearcoat_roughness = 0.2

	mat.uv1_triplanar = false
	mat.uv1_scale = Vector3(1.0, 1.0, 1.0)

	match _material_preset_idx:
		0:
			mat.albedo_color = Color(0.85, 0.88, 0.94)
			mat.albedo_texture = _tex_cad_check_alb
			mat.normal_enabled = true
			mat.normal_texture = _tex_cad_check_norm
			mat.normal_scale = 0.85
			mat.roughness_texture = _tex_cad_check_rough
			mat.metallic = 0.35
			mat.roughness = 0.3
		1:
			mat.albedo_color = Color(0.82, 0.85, 0.9)
			mat.albedo_texture = _tex_brushed_alb
			mat.normal_enabled = true
			mat.normal_texture = _tex_brushed_norm
			mat.normal_scale = 0.65
			mat.metallic = 0.65
			mat.roughness = 0.28
		2:
			mat.albedo_color = Color(0.22, 0.7, 0.92)
			mat.albedo_texture = _tex_grid_alb
			mat.normal_enabled = true
			mat.normal_texture = _tex_grid_norm
			mat.normal_scale = 0.6
			mat.metallic = 0.15
			mat.roughness = 0.25
		3:
			mat.albedo_color = Color(0.96, 0.5, 0.12)
			mat.albedo_texture = _tex_grid_alb
			mat.normal_enabled = true
			mat.normal_texture = _tex_grid_norm
			mat.normal_scale = 0.6
			mat.metallic = 0.08
			mat.roughness = 0.3
		4:
			mat.albedo_color = Color(0.75, 0.78, 0.84)
			mat.albedo_texture = _tex_carbon_alb
			mat.normal_enabled = true
			mat.normal_texture = _tex_carbon_norm
			mat.normal_scale = 1.2
			mat.metallic = 0.55
			mat.roughness = 0.25
		5:
			mat.albedo_color = Color(0.94, 0.78, 0.28)
			mat.albedo_texture = _tex_cad_check_alb
			mat.normal_enabled = true
			mat.normal_texture = _tex_cad_check_norm
			mat.normal_scale = 0.5
			mat.metallic = 0.9
			mat.roughness = 0.18
		6:
			mat.albedo_color = Color(0.96, 0.97, 0.99)
			mat.albedo_texture = _tex_grid_alb
			mat.normal_enabled = true
			mat.normal_texture = _tex_grid_norm
			mat.normal_scale = 0.4
			mat.metallic = 0.05
			mat.roughness = 0.12
		_:
			mat.albedo_color = Color(0.85, 0.88, 0.94)
			mat.albedo_texture = _tex_cad_check_alb
			mat.metallic = 0.35
			mat.roughness = 0.3

	return mat

func _build_edge_multimesh(shape: Variant) -> void:
	if not _show_edges or shape == null or shape.has_method("is_null") and shape.is_null():
		_edge_multimesh_node.multimesh = null
		return

	var all_edges: Array = shape.edges()
	if all_edges.is_empty():
		_edge_multimesh_node.multimesh = null
		return

	var bb: Variant = shape.bounding_box()
	var diag: float = _diagonal_of(bb)
	var edge_radius: float = clampf(diag * 0.0018 * _edge_thickness_scale, 0.008, 2.0)

	var seg_list: Array[Array] = []
	for e in all_edges:
		if e != null:
			var pts: PackedVector3Array
			if e.has_method("tessellate_edge"):
				pts = e.tessellate_edge(0.02)
			elif e.has_method("positions"):
				var arr: Array[Vector3] = e.positions(32)
				pts = PackedVector3Array(arr)
			for i in range(pts.size() - 1):
				var p0: Vector3 = pts[i]
				var p1: Vector3 = pts[i + 1]
				if p0.distance_squared_to(p1) > 1e-8:
					seg_list.append([p0, p1])

	if seg_list.is_empty():
		_edge_multimesh_node.multimesh = null
		return

	var cyl_mesh := CylinderMesh.new()
	cyl_mesh.top_radius = 1.0
	cyl_mesh.bottom_radius = 1.0
	cyl_mesh.height = 1.0
	cyl_mesh.radial_segments = 6
	cyl_mesh.rings = 0

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = cyl_mesh
	mm.instance_count = seg_list.size()

	for idx in range(seg_list.size()):
		var seg: Array = seg_list[idx]
		var p0: Vector3 = seg[0]
		var p1: Vector3 = seg[1]
		var delta: Vector3 = p1 - p0
		var seg_len: float = delta.length()
		var mid: Vector3 = (p0 + p1) * 0.5
		var y_axis: Vector3 = delta / seg_len

		var up := Vector3.UP if absf(y_axis.y) < 0.99 else Vector3.RIGHT
		var x_axis: Vector3 = y_axis.cross(up).normalized()
		var z_axis: Vector3 = x_axis.cross(y_axis).normalized()

		var basis := Basis(x_axis * edge_radius, y_axis * seg_len, z_axis * edge_radius)
		var xform := Transform3D(basis, mid)
		mm.set_instance_transform(idx, xform)

	_edge_multimesh_node.multimesh = mm
	_edge_multimesh_node.visible = _show_edges

func _build_vertex_multimesh(shape: Variant) -> void:
	if not _show_vertices or shape == null or shape.has_method("is_null") and shape.is_null():
		_vertex_multimesh_node.multimesh = null
		return

	var all_verts: Array = shape.vertices()
	if all_verts.is_empty():
		_vertex_multimesh_node.multimesh = null
		return

	var bb: Variant = shape.bounding_box()
	var diag: float = _diagonal_of(bb)
	var edge_radius: float = clampf(diag * 0.0018 * _edge_thickness_scale, 0.008, 2.0)
	var vertex_radius: float = edge_radius * 1.35

	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = 1.0
	sphere_mesh.height = 2.0
	sphere_mesh.radial_segments = 6
	sphere_mesh.rings = 4

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = sphere_mesh
	mm.instance_count = all_verts.size()

	for i in range(all_verts.size()):
		var v = all_verts[i]
		var pos: Vector3 = v.center() if v.has_method("center") else Vector3.ZERO
		var xform := Transform3D(Basis().scaled(Vector3.ONE * vertex_radius), pos)
		mm.set_instance_transform(i, xform)

	_vertex_multimesh_node.multimesh = mm
	_vertex_multimesh_node.visible = _show_vertices
