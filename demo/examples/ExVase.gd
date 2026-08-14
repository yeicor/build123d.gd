extends "res://demo/BdgExample.gd"
class_name ExVase

func _init() -> void:
	super(
		"vase",
		"Organic Fluted Vase",
		"Advanced",
		"Artistic parametric fluted vase created with tangent spline segments, revolved 360 degrees, hollowed with solid offset shelling, and filleted along base and opening rims.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/vase.py"
	)
	gdscript_code = """# 1. Vase outer profile curve segments on XY plane
var p0 := Vector3(0, 0, 0)
var p1 := Vector3(12, 0, 0)
var p2 := Vector3(15, 20, 0)
var p3_mid := Vector3(22, 40, 0)
var p3 := Vector3(20, 50, 0)
var p4 := Vector3(20, 55, 0)
var p5_mid := Vector3(22.5, 57.5, 0)
var p5 := Vector3(20, 60, 0)
var p6 := Vector3(20, 61, 0)
var p7 := Vector3(0, 61, 0)

var e1 := Bdg.make_line(p0, p1)
var e2 := Bdg.make_radius_arc(p1, p2, 50.0, true)
var t2_end: Vector3 = Bdg.tangent_at(e2, 1.0)
var e3 := Bdg.make_spline([p2, p3_mid, p3], [t2_end, Vector3(-0.75, 1, 0).normalized()])
var e4 := Bdg.make_radius_arc(p3, p4, 5.0, true)
var t4_end: Vector3 = Bdg.tangent_at(e4, 1.0)
var e5 := Bdg.make_spline([p4, p5_mid, p5], [t4_end, Vector3(-1, 0, 0).normalized()])
var poly_wire := Bdg.make_polygon([p5, p6, p7, p0], false)

var vase_wire := Bdg.make_wire([e1, e2, e3, e4, e5, poly_wire])
var vase_face := Bdg.make_from_wires(vase_wire)

# 2. Revolve 360 deg around Y axis
var solid_vase := Bdg.revolve_axis(vase_face, 360.0, Bdg.axis_y()) as BdgSolid

# 3. Shell / hollow out with top planar opening
var top_opening: Array = []
for f in Bdg.faces(solid_vase):
	var face: BdgFace = f as BdgFace
	if Bdg.geom_type(face) == Bdg.GeomType.PLANE and Bdg.center(face).y > 60.0:
		top_opening.append(face)

var hollow_vase: BdgShape = Bdg.offset_shape(solid_vase, -1.0, top_opening)

# 4. Fillet rim & base edges
var circular_edges: Array = []
for e in Bdg.edges(hollow_vase):
	var edge: BdgEdge = e as BdgEdge
	if Bdg.geom_type(edge) == Bdg.GeomType.CIRCLE and Bdg.center(edge).y > 59.0:
		circular_edges.append(edge)

if not circular_edges.is_empty():
	hollow_vase = Bdg.fillet_edges(hollow_vase, 0.25, circular_edges)

var base_edge: BdgEdge = null
var min_y: float = INF
for e in Bdg.edges(hollow_vase):
	var edge: BdgEdge = e as BdgEdge
	if Bdg.center(edge).y < min_y:
		min_y = Bdg.center(edge).y
		base_edge = edge

if base_edge != null:
	hollow_vase = Bdg.fillet_edges(hollow_vase, 0.5, [base_edge])

return Bdg.clean(hollow_vase)"""
