extends Node3D
## BdgViewer - minimal viewer demonstrating build123d.gd + BdgMesh.
## Run the demo/viewer.tscn scene to see a modeled part rendered.

func _ready() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(35.0, 28.0, 35.0)
	add_child(camera)
	camera.look_at(Vector3.ZERO)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40.0, -35.0, 0.0)
	add_child(light)

	var part := _build_sample()
	if part == null:
		return
	var mi := BdgMesh.to_mesh_instance3d(part, 0.2, 15.0)
	add_child(mi)
	print("BdgViewer: displayed part with %d triangles" % BdgMesh.triangle_count(part, 0.2, 15.0))

func _build_sample() -> BdgShape:
	var bp := BdgBuildPart.new()
	bp.begin()
	BdgBox.new(20.0, 20.0, 6.0)
	BdgCylinder.new(4.0, 10.0, 360.0, Vector3.ZERO, [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.MAX], BdgEnums.Mode.ADD)
	BdgCylinder.new(1.6, 12.0, 360.0, Vector3.ZERO, [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.MAX], BdgEnums.Mode.SUBTRACT)
	bp.end()
	return bp.part()
