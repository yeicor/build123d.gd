extends "res://demo/BdgExample.gd"
class_name ExHandle

func _init() -> void:
	super(
		"handle",
		"Drawer Handle",
		"Intermediate",
		"Multisection loft along a 3D spline curve creating an ergonomic drawer handle.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/handle.py"
	)
	gdscript_code = """var segment_count := 6

# Spline path
var p0 := Vector3(-10, 0, 0)
var p1 := Vector3(0, 0, 5)
var p2 := Vector3(10, 0, 0)
var t0 := Vector3(0, 0, 1.5)
var t2 := Vector3(0, 0, -1.5)
var path_edge := Bdg.make_spline([p0, p1, p2], [t0, t2], false)
var path_wire := Bdg.make_wire([path_edge])

var sections: Array = []
var total_len := Bdg.length(path_edge)
for i in range(segment_count + 1):
	var target_dist := (float(i) / float(segment_count)) * total_len
	var u := Bdg.param_at_distance(path_edge, target_dist)
	var p_pos := Bdg.position_at(path_edge, u)
	var p_z := Bdg.tangent_at(path_edge, u)
	var p_x := Bdg.normal_at(path_edge, u)
	var p_y := p_z.cross(p_x).normalized()

	var basis := Basis(p_x, p_y, p_z)
	var loc := Bdg.location(p_pos, basis.get_rotation_quaternion())

	if i == 0 or i == segment_count:
		var circ2d := Bdg.make_circle(1.0)
		var circ := Bdg.move(circ2d, loc) as BdgFace
		sections.append(circ)
	else:
		var rect2d := Bdg.make_rounded_rect(1.25, 3.0, 0.2)
		var rect := Bdg.move(rect2d, loc) as BdgFace
		sections.append(rect)

var handle_solid := Bdg.make_pipe_shell(path_wire, sections, true)
return handle_solid"""
