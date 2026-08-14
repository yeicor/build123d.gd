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

# 1. Half profile on XZ plane (faithful port of Polyline + JernArc + DoubleTangentArc)
# JernArc: center (20, 5), radius 5, from (20, 0) to (18.076923, 9.615385)
# DoubleTangentArc: center (0, 53), radius 47, from (18.076923, 9.615385) to (0, 6)
var p0 := Vector3(0, 0, thickness * 0.6)
var p_bot_c := Vector3(0, 0, 0)
var p_edge := Vector3(r_flat, 0, 0)
var p_jern_end := Vector3(18.07692307692308, 0, 9.615384615384613)

var e1: BdgEdge = BdgEdge.make_line(p_bot_c, p_edge)
var e2: BdgEdge = BdgEdge.make_three_point_arc(p_edge, Vector3(r_flat + 5.0, 0, 5.0), p_jern_end)
var e3: BdgEdge = BdgEdge.make_tangent_arc(p_jern_end, Vector3(-0.923076923, 0, -0.384615385), p0)
var e4: BdgEdge = BdgEdge.make_line(p0, p_bot_c)

var coin_wire: BdgWire = Bdg.make_wire([e1, e2, e3, e4])
var coin_face: BdgFace = Bdg.make_from_wires(coin_wire)

# 2. Revolve 360 deg around Z axis
var coin_solid: BdgShape = Bdg.revolve_axis(coin_face, 360.0, Bdg.axis_z())

# 3. 8 Detent circular cuts around perimeter (radius 7 at radius 27.5)
var detent_radius := thickness * 1.4 * 0.5
var detent_pos_r := (diameter + 5.0) * 0.5
for i in range(8):
	var ang: float = float(i) * TAU / 8.0
	var pos := Vector3(detent_pos_r * cos(ang), detent_pos_r * sin(ang), -1.0)
	var detent_cyl: BdgShape = Bdg.translate(Bdg.make_cylinder(detent_radius, thickness + 2.0), pos)
	coin_solid = Bdg.cut(coin_solid, detent_cyl)

return Bdg.clean(coin_solid)"""
