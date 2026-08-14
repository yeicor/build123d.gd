extends "res://demo/BdgExample.gd"
class_name ExFastGridHoles

func _init() -> void:
	super(
		"fast_grid_holes",
		"Hexagonal Grid Perforated Plate",
		"Intermediate",
		"High-efficiency 2D multi-hole face construction with hexagonal lattice pattern extruded in a single step.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/fast_grid_holes.py"
	)
	gdscript_code = """var major_r := 10.0
var count_x := 25
var count_y := 25
var plate_w := 500.0
var plate_h := 600.0

# 1. Outer perimeter wire
var perim_wire: BdgWire = Bdg.make_polygon([
	Vector3(-plate_w * 0.5, -plate_h * 0.5, 0),
	Vector3(plate_w * 0.5, -plate_h * 0.5, 0),
	Vector3(plate_w * 0.5, plate_h * 0.5, 0),
	Vector3(-plate_w * 0.5, plate_h * 0.5, 0)
], true)

# 2. Hexagonal lattice hole locations & wires
var hex_radius := major_r - 1.0
var hex_wires: Array = []

var hole_locs := Bdg.hex_locations_list(major_r, count_x, count_y)
for loc in hole_locs:
	var l: BdgLocation = loc as BdgLocation
	var hex_pts: Array[Vector3] = []
	for k in range(6):
		var ang: float = float(k) * TAU / 6.0
		hex_pts.append(l.position + Vector3(hex_radius * cos(ang), hex_radius * sin(ang), 0))
	hex_wires.append(Bdg.make_polygon(hex_pts, true))

# 3. Create Face from outer wire and inner hole wires
var perforated_face: BdgFace = Bdg.make_from_wires(perim_wire, hex_wires)

# 4. Extrude to solid plate
var plate_solid: BdgShape = Bdg.extrude_vec(perforated_face, Vector3(0, 0, 1.0))
return Bdg.clean(plate_solid)"""
