extends RefCounted
## BdgMesh - convert a BdgShape into Godot 3D mesh primitives for display.
## Mirrors build123d/mesher.py Mesher, reduced to the Godot-native output.
class_name BdgMesh

## Build a Godot ArrayMesh from a shape's tessellation.
## tolerance (linear) and angular_tolerance (degrees) control mesh density.
## Per-vertex normals are area-weighted smoothed from the triangle faces.
static func to_array_mesh(shape: BdgShape, tolerance: float = 0.1, angular_tolerance: float = 10.0) -> ArrayMesh:
	var tess := shape.tessellate(tolerance, angular_tolerance)
	var vertices: PackedVector3Array = tess[0]
	var triangles: PackedInt32Array = tess[1]
	var mesh := ArrayMesh.new()
	if vertices.is_empty() or triangles.is_empty():
		return mesh
	var normals := PackedVector3Array()
	normals.resize(vertices.size())
	for i in range(0, triangles.size(), 3):
		var a := vertices[triangles[i]]
		var b := vertices[triangles[i + 1]]
		var c := vertices[triangles[i + 2]]
		var n := (b - a).cross(c - a)
		normals[triangles[i]] = normals[triangles[i]] + n
		normals[triangles[i + 1]] = normals[triangles[i + 1]] + n
		normals[triangles[i + 2]] = normals[triangles[i + 2]] + n
	for i in normals.size():
		var n := normals[i]
		if n.length_squared() < 1e-12:
			normals[i] = Vector3.UP
		else:
			normals[i] = n.normalized()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = triangles
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

## Build a MeshInstance3D node displaying the shape.
static func to_mesh_instance3d(shape: BdgShape, tolerance: float = 0.1, angular_tolerance: float = 10.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = to_array_mesh(shape, tolerance, angular_tolerance)
	return mi

## Count of triangles in a shape's tessellation.
static func triangle_count(shape: BdgShape, tolerance: float = 0.1, angular_tolerance: float = 10.0) -> int:
	var tess := shape.tessellate(tolerance, angular_tolerance)
	var triangles: PackedInt32Array = tess[1]
	return triangles.size() / 3
