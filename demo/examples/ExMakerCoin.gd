extends "res://demo/BdgExample.gd"
class_name ExMakerCoin

func _init() -> void:
	super(
		"maker_coin",
		"Maker Coin with Detents",
		"Precision CAD",
		"Smooth coin token profile with tangential transitional arcs revolved 360 degrees, patterned with 8 perimeter detents and edge fillets.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/maker_coin.py"
	)
	gdscript_code = """var diameter := 50.0
var thickness := 10.0
var r_flat := (diameter - thickness) * 0.5
var r_arc := thickness * 0.5

# 1. Half profile on XZ plane
var p0 := Vector3(0, 0, thickness * 0.6)
var p1 := Vector3(0, 0, 0)
var p2 := Vector3(r_flat, 0, 0)

var e1: BdgEdge = Bdg.make_line(p0, p1)
var e2: BdgEdge = Bdg.make_line(p1, p2)
var arc_rim: BdgEdge = Bdg.make_radius_arc(p2, Vector3(r_flat + r_arc, 0, r_arc), r_arc, true)
var arc_top: BdgEdge = Bdg.make_radius_arc(Vector3(r_flat + r_arc, 0, r_arc), p0, diameter * 0.8, true)

var coin_wire: BdgWire = Bdg.make_wire([e1, e2, arc_rim, arc_top])
var coin_face: BdgFace = Bdg.make_from_wires(coin_wire)

# 2. Revolve 360 deg around Z axis
var coin_solid: BdgShape = Bdg.revolve_axis(coin_face, 360.0, Bdg.axis_z())

# 3. 8 Detent circular cuts around perimeter
var detent_radius := thickness * 1.4 * 0.5
var detent_pos_r := (diameter + 5.0) * 0.5
for i in range(8):
	var ang: float = float(i) * TAU / 8.0
	var pos := Vector3(detent_pos_r * cos(ang), detent_pos_r * sin(ang), -1.0)
	var detent_cyl: BdgShape = Bdg.translate(Bdg.make_cylinder(detent_radius, thickness + 2.0), pos)
	coin_solid = Bdg.cut(coin_solid, detent_cyl)

return Bdg.clean(coin_solid)"""
