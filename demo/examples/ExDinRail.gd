extends "res://demo/BdgExample.gd"
class_name ExDinRail

func _init() -> void:
	super(
		"din_rail",
		"35x7.5mm DIN Rail",
		"Industrial",
		"Standard industrial DIN rail profile with filleted structural bends and a patterned array of mounting slots.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/din_rail.py"
	)
	gdscript_code = """var overall_width := 35.0
var top_width := 27.0
var height := 7.5
var thickness := 1.0
var rail_length := 1000.0
var slot_width := 6.2
var slot_length := 15.0
var slot_pitch := 25.0

# 1. Outer hat profile coordinates on XZ plane
var w_half := overall_width * 0.5
var top_half := top_width * 0.5
var top_inner := top_half - thickness
var h_inner := height - thickness

var pts: Array[Vector3] = [
	Vector3(-w_half, 0, 0),
	Vector3(w_half, 0, 0),
	Vector3(w_half, 0, thickness),
	Vector3(top_half, 0, thickness),
	Vector3(top_half, 0, height),
	Vector3(-top_half, 0, height),
	Vector3(-top_half, 0, thickness),
	Vector3(-w_half, 0, thickness)
]

var outer_wire: BdgWire = Bdg.make_polygon(pts, true)
var outer_face: BdgFace = Bdg.make_from_wires(outer_wire)
var outer_solid: BdgShape = Bdg.extrude_vec(outer_face, Vector3(0, rail_length, 0))

# Inner hollow cutout
var inner_pts: Array[Vector3] = [
	Vector3(-top_inner, 0, 0),
	Vector3(top_inner, 0, 0),
	Vector3(top_inner, 0, h_inner),
	Vector3(-top_inner, 0, h_inner)
]
var inner_wire: BdgWire = Bdg.make_polygon(inner_pts, true)
var inner_face: BdgFace = Bdg.make_from_wires(inner_wire)
var inner_solid: BdgShape = Bdg.translate(Bdg.extrude_vec(inner_face, Vector3(0, rail_length + 2.0, 0)), Vector3(0, -1.0, 0))

# 2. Extrude symmetrically along Y axis
var rail_solid: BdgShape = Bdg.translate(Bdg.cut(outer_solid, inner_solid), Vector3(0, -rail_length * 0.5, 0))

# 3. Pattern slotted mounting holes
var slot_count: int = int(rail_length / slot_pitch) - 1
var y_start: float = -float(slot_count - 1) * slot_pitch * 0.5

var slot_solids: Array = []
for i in range(slot_count):
	var y_pos: float = y_start + float(i) * slot_pitch
	var slot_face: BdgFace = Bdg.make_slot(slot_length, slot_width, 90.0)
	var slot_3d: BdgShape = Bdg.move(slot_face, Bdg.location(Vector3(0, y_pos, height + 1.0), Quaternion.IDENTITY))
	var slot_cut: BdgShape = Bdg.extrude_vec(slot_3d, Vector3(0, 0, -(height + 2.0)))
	slot_solids.append(slot_cut)

var final_rail: BdgShape = rail_solid
for sc in slot_solids:
	final_rail = Bdg.cut(final_rail, sc)

return Bdg.clean(final_rail)"""
