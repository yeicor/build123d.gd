extends "res://demo/BdgExample.gd"
class_name ExPillowBlock

func _init() -> void:
	super(
		"pillow_block",
		"Pillow Block",
		"Intermediate",
		"Industrial pillow block bearing body with central counterbore and grid mounting holes.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/pillow_block.py"
	)
	gdscript_code = """var height := 60.0
var width := 80.0
var thickness := 10.0
var padding := 12.0
var screw_shaft_radius := 1.5
var screw_head_radius := 3.0
var screw_head_height := 3.0
var bearing_axle_radius := 4.0
var bearing_radius := 11.0
var bearing_thickness := 7.0

var rect_face := Bdg.make_rounded_rect(width, height, 5.0)
var base_part: BdgShape = Bdg.extrude_vec(rect_face, Vector3(0, 0, thickness))

var faces_list := Bdg.shape_list(Bdg.faces(base_part))
var top_face: BdgFace = Bdg.at(Bdg.sort_by(faces_list, Bdg.axis_z()), -1) as BdgFace
var plane := Bdg.to_plane(top_face)

# Main bearing counterbore hole
var cb1 := Bdg.move(Bdg.counter_bore_hole(bearing_axle_radius, bearing_radius, bearing_thickness, thickness), Bdg.location(plane.origin))
base_part = Bdg.cut(base_part, cb1)

# Grid mounting holes
var grid_x := width - 2.0 * padding
var grid_y := height - 2.0 * padding
var grid := Bdg.grid_locations_list(grid_x, grid_y, 2, 2)
for loc in grid:
	var l: BdgLocation = loc as BdgLocation
	var pos: Vector3 = plane.origin + plane.x_dir * l.position.x + plane.y_dir * l.position.y
	var cb_screw := Bdg.move(Bdg.counter_bore_hole(screw_shaft_radius, screw_head_radius, screw_head_height, thickness), Bdg.location(pos))
	base_part = Bdg.cut(base_part, cb_screw)

return base_part"""
