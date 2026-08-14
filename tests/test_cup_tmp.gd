extends SceneTree

func _init() -> void:
	var wall_thickness := 3.0
	var fillet_radius := wall_thickness * 0.49
	var hp0 := Vector3(55.9247, 35, 0)
	var hp3 := Vector3(60.5832, 80, 0)
	var hp1 := Vector3(92.4247, 35, 30)
	var hp2 := Vector3(97.4247, 35, 60)
	var ht0 := Vector3(1, 0, 1.25)
	var ht3 := Vector3(-0.2, 0, -1)
	var handle_spline := BdgEdge.make_spline([hp0, hp1, hp2, hp3], [ht0, ht3])
	var handle_wire := BdgWire.make_wire([handle_spline])
	print("tangent_at(0): ", handle_spline.tangent_at(0.0))
	print("normal_at(0): ", handle_spline.normal_at(0.0))
	var p_pos := handle_spline.position_at(0.0)
	var p_z := handle_spline.tangent_at(0.0)
	var p_x := handle_spline.normal_at(0.0)
	var p_y := p_z.cross(p_x).normalized()
	print("frame x: ", p_x)
	print("frame y: ", p_y)
	print("frame z: ", p_z)
	var loc := BdgLocation.new(p_pos, Basis(p_x, p_y, p_z).get_rotation_quaternion())
	var profile_2d := BdgFace.make_rounded_rect(wall_thickness, 8.0, fillet_radius)
	var profile_3d := profile_2d.move(loc) as BdgFace
	var handle_solid := BdgShape.make_pipe_shell(handle_wire, [profile_3d], true)
	var bb := handle_solid.bounding_box()
	print("GD handle bbox: ", bb.min, " / ", bb.max)
	print("GD handle vol: ", handle_solid.volume())
	quit()