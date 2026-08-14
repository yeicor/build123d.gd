extends "res://demo/BdgExample.gd"
class_name ExTeaCup

func _init() -> void:
	super(
		"teacup",
		"Porcelain Tea Cup",
		"Advanced",
		"Detailed porcelain tea cup with revolved body, hollowed shell, bottom base disk, and swept handle.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/tea_cup.py"
	)
	gdscript_code = """var wall_thickness := 3.0
var fillet_radius := wall_thickness * 0.49

# 1. Bowl profile spline & polyline
var p_start := Vector3(30, 0, 10)
var p_end := Vector3(69, 0, 105)
var t_start := Vector3(1, 0, 0.5).normalized() * 1.75
var t_end := Vector3(0.7, 0, 1).normalized() * 1.0

var bowl_spline := Bdg.make_spline([p_start, p_end], [t_start, t_end], false)
var poly_pts: Array = [
	p_end,
	Vector3(0, 0, 105),
	Vector3(0, 0, 0),
	p_start + Vector3(10, 0, -10),
	p_start
]
var poly_wire := Bdg.make_polygon(poly_pts, false)
var bowl_wire := Bdg.make_wire([bowl_spline, poly_wire])
var bowl_face := Bdg.make_from_wires(bowl_wire)

# 2. Revolve 360 deg around Z axis
var revolved_solid := Bdg.revolve_axis(bowl_face, 360.0, Bdg.axis_z()) as BdgSolid

# 3. Shell / offset with planar face openings
var planar_faces: Array = []
for f in Bdg.faces(revolved_solid):
	var face: BdgFace = f as BdgFace
	if Bdg.geom_type(face) == Bdg.GeomType.PLANE:
		planar_faces.append(face)

var shelled_solid: BdgShape = Bdg.offset_shape(revolved_solid, -wall_thickness, planar_faces)

# 4. Bottom base cylinder
var base_cyl := Bdg.translate(Bdg.make_cylinder(30.0, wall_thickness), Vector3(0, 0, 10.0 - wall_thickness * 0.5))
var main_cup: BdgShape = Bdg.fuse(shelled_solid, base_cyl)

# 5. Fillet edges
main_cup = Bdg.fillet_edges(main_cup, fillet_radius, Bdg.edges(main_cup))

# 6. Handle spline path & sweep
# The handle path is a 3D spline built in the Plane.XZ local frame. The 3D
# control points are the plane-local coords (x, 0, y) used directly as world
# points; only the 2D tangents get plane-wrapped to (x, 0, y).
var hp0 := Vector3(55.9247, 35, 0)
var hp3 := Vector3(60.5832, 80, 0)
var hp1 := Vector3(92.4247, 35, 30)
var hp2 := Vector3(97.4247, 35, 60)

var ht0 := Vector3(1, 0, 1.25)
var ht3 := Vector3(-0.2, 0, -1)

var handle_spline := Bdg.make_spline([
	hp0,
	hp1,
	hp2,
	hp3
], [ht0, ht3])
var handle_wire := Bdg.make_wire([handle_spline])

# Profile at start of handle path
var p_pos := Bdg.position_at(handle_spline, 0.0)
var p_z := Bdg.tangent_at(handle_spline, 0.0)
var p_x := Bdg.normal_at(handle_spline, 0.0)
var p_y := p_z.cross(p_x).normalized()
var loc := Bdg.location(p_pos, Basis(p_x, p_y, p_z).get_rotation_quaternion())

var profile_2d := Bdg.make_rounded_rect(wall_thickness, 8.0, fillet_radius)
var profile_3d := Bdg.move(profile_2d, loc) as BdgFace

var handle_solid := Bdg.make_pipe_shell(handle_wire, [profile_3d], true)
if handle_solid != null:
	main_cup = Bdg.fuse(main_cup, handle_solid)

return Bdg.clean(main_cup)"""
