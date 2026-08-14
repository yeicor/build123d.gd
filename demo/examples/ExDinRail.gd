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
var fillet_radius := 0.8
var fillet_radius_outer := fillet_radius + thickness

# 1. Outer hat profile coordinates on XZ plane
var w_half := overall_width * 0.5
var top_half := top_width * 0.5
var top_inner := top_half - thickness
var h_inner := height - thickness

# Fillet tangent points
var step_xt := top_half + fillet_radius          # 14.3 base-top edge tangent
var step_zt := thickness + fillet_radius         # 1.8 step wall tangent
var top_zt := height - fillet_radius_outer       # 5.7 top wall tangent
var top_xt := top_half - fillet_radius_outer     # 11.7 top edge tangent
var bottom_zt := fillet_radius_outer             # 1.8 hole wall tangent
var bottom_xt := top_inner + fillet_radius_outer # 14.3 hole bottom tangent
var top_zt2 := h_inner - fillet_radius           # 5.7 hole top wall tangent
var top_xt2 := top_inner - fillet_radius         # 11.7 hole top edge tangent

# 2. Outer hat wire (fillets baked into the edges)
var oe: Array = []
oe.append(Bdg.make_line(Vector3(-w_half, 0, 0), Vector3(w_half, 0, 0)))
oe.append(Bdg.make_line(Vector3(w_half, 0, 0), Vector3(w_half, 0, thickness)))
oe.append(Bdg.make_line(Vector3(w_half, 0, thickness), Vector3(step_xt, 0, thickness)))
oe.append(Bdg.make_radius_arc(Vector3(step_xt, 0, thickness), Vector3(top_half, 0, step_zt), -fillet_radius))
oe.append(Bdg.make_line(Vector3(top_half, 0, step_zt), Vector3(top_half, 0, top_zt)))
oe.append(Bdg.make_radius_arc(Vector3(top_half, 0, top_zt), Vector3(top_xt, 0, height), fillet_radius_outer))
oe.append(Bdg.make_line(Vector3(top_xt, 0, height), Vector3(-top_xt, 0, height)))
oe.append(Bdg.make_radius_arc(Vector3(-top_xt, 0, height), Vector3(-top_half, 0, top_zt), fillet_radius_outer))
oe.append(Bdg.make_line(Vector3(-top_half, 0, top_zt), Vector3(-top_half, 0, step_zt)))
oe.append(Bdg.make_radius_arc(Vector3(-top_half, 0, step_zt), Vector3(-step_xt, 0, thickness), -fillet_radius))
oe.append(Bdg.make_line(Vector3(-step_xt, 0, thickness), Vector3(-w_half, 0, thickness)))
oe.append(Bdg.make_line(Vector3(-w_half, 0, thickness), Vector3(-w_half, 0, 0)))
var outer_wire: BdgWire = Bdg.make_wire(oe)

# 3. Inner hollow wire (fillets baked into the edges)
var he: Array = []
he.append(Bdg.make_radius_arc(Vector3(top_inner, 0, bottom_zt), Vector3(bottom_xt, 0, 0), fillet_radius_outer))
he.append(Bdg.make_line(Vector3(bottom_xt, 0, 0), Vector3(-bottom_xt, 0, 0)))
he.append(Bdg.make_radius_arc(Vector3(-bottom_xt, 0, 0), Vector3(-top_inner, 0, bottom_zt), fillet_radius_outer))
he.append(Bdg.make_line(Vector3(-top_inner, 0, bottom_zt), Vector3(-top_inner, 0, top_zt2)))
he.append(Bdg.make_radius_arc(Vector3(-top_inner, 0, top_zt2), Vector3(-top_xt2, 0, h_inner), -fillet_radius))
he.append(Bdg.make_line(Vector3(-top_xt2, 0, h_inner), Vector3(top_xt2, 0, h_inner)))
he.append(Bdg.make_radius_arc(Vector3(top_inner, 0, top_zt2), Vector3(top_xt2, 0, h_inner), fillet_radius))
he.append(Bdg.make_line(Vector3(top_inner, 0, top_zt2), Vector3(top_inner, 0, bottom_zt)))
var inner_wire: BdgWire = Bdg.make_wire(he)

# 4. Build the profile face (with hollow) and extrude along Y
var profile_face: BdgFace = Bdg.make_from_wires(outer_wire, [inner_wire])
var rail_solid: BdgShape = Bdg.translate(Bdg.extrude_vec(profile_face, Vector3(0, rail_length, 0)), Vector3(0, -rail_length * 0.5, 0))

# 5. Pattern slotted mounting holes
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
