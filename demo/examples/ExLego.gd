extends "res://demo/BdgExample.gd"
class_name ExLego

func _init() -> void:
	super(
		"lego",
		"Parametric Lego Brick",
		"Basics",
		"Parametric 2x6 Lego brick with hollow bottom tubes, interior wall ribs, and top studs.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/lego.py"
	)
	gdscript_code = """var pip_count := 6
var lego_unit_size := 8.0
var pip_height := 1.8
var pip_diameter := 4.8
var block_length := lego_unit_size * float(pip_count)
var block_width := 16.0
var base_height := 9.6
var support_outer_diameter := 6.5
var support_inner_diameter := 4.8
var ridge_width := 0.6
var ridge_depth := 0.3
var wall_thickness := 1.2

# 1. Base sketch
var outer_rect := Bdg.make_rect(block_length, block_width)
var inner_rect := Bdg.make_rect(block_length - 2.0 * wall_thickness, block_width - 2.0 * wall_thickness)
var sketch_face: BdgShape = Bdg.cut(outer_rect, inner_rect)

# Rib bars
var y_grid := Bdg.grid_locations_list(0, lego_unit_size, 1, 2)
for loc in y_grid:
	var l: BdgLocation = loc as BdgLocation
	var r := Bdg.move(Bdg.make_rect(block_length, ridge_width), l)
	sketch_face = Bdg.fuse(sketch_face, r)

var x_grid := Bdg.grid_locations_list(lego_unit_size, 0, pip_count, 1)
for loc in x_grid:
	var l: BdgLocation = loc as BdgLocation
	var r := Bdg.move(Bdg.make_rect(ridge_width, block_width), l)
	sketch_face = Bdg.fuse(sketch_face, r)

# Subtract interior pocket
var pocket := Bdg.make_rect(
	block_length - 2.0 * (wall_thickness + ridge_depth),
	block_width - 2.0 * (wall_thickness + ridge_depth)
)
sketch_face = Bdg.cut(sketch_face, pocket)

# Add support cylinders
var sup_grid := Bdg.grid_locations_list(lego_unit_size, 0, pip_count - 1, 1)
for loc in sup_grid:
	var l: BdgLocation = loc as BdgLocation
	var c_outer := Bdg.move(Bdg.make_circle(support_outer_diameter * 0.5), l) as BdgFace
	var c_inner := Bdg.move(Bdg.make_circle(support_inner_diameter * 0.5), l) as BdgFace
	var ring := Bdg.cut(c_outer, c_inner)
	sketch_face = Bdg.fuse(sketch_face, ring)

# Extrude walls to base height minus wall thickness
sketch_face = Bdg.clean(sketch_face)
var extrude_h := base_height - wall_thickness
var lego_part: BdgShape = Bdg.extrude_vec(sketch_face, Vector3(0, 0, extrude_h))

# Top solid cover box
var top_box := Bdg.make_box(block_length, block_width, wall_thickness)
top_box = Bdg.translate(top_box, Vector3(-block_length * 0.5, -block_width * 0.5, extrude_h))
lego_part = Bdg.fuse(lego_part, top_box)

# Top studs (pips)
var top_z := base_height
var pips_grid := Bdg.grid_locations_list(lego_unit_size, lego_unit_size, pip_count, 2)
for loc in pips_grid:
	var l: BdgLocation = loc as BdgLocation
	var pos := Vector3(l.position.x, l.position.y, top_z)
	var pip := Bdg.translate(Bdg.make_cylinder(pip_diameter * 0.5, pip_height), pos)
	lego_part = Bdg.fuse(lego_part, pip)

return Bdg.clean(lego_part)"""
