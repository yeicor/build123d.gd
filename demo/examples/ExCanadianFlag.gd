extends "res://demo/BdgExample.gd"
class_name ExCanadianFlag

func _init() -> void:
	super(
		"canadian_flag",
		"Canadian Flag Relief",
		"Artistic CAD",
		"National flag of Canada modeled with dual red side stripes, recessed white center field, and an intricately mirrored 22-vertex maple leaf emblem.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/canadian_flag.py"
	)
	gdscript_code = """# 1. Base flag plate (2.0 x 1.0 x 0.1)
var flag_base: BdgShape = Bdg.translate(Bdg.make_box(2.0, 1.0, 0.1), Vector3(-1.0, -0.5, -0.05))

# 2. Side red bands (recessed cuts for dual-tone look)
var left_stripe: BdgShape = Bdg.translate(Bdg.make_box(0.5, 1.0, 0.05), Vector3(-1.0, -0.5, 0.0))
var right_stripe: BdgShape = Bdg.translate(Bdg.make_box(0.5, 1.0, 0.05), Vector3(0.5, -0.5, 0.0))

# 3. Half maple leaf coordinates (scaled by 1.2 and shifted)
var half_pts: Array[Vector3] = [
	Vector3(0.0000, 0.4442, 0),
	Vector3(0.0274, 0.4442, 0),
	Vector3(0.0274, 0.3540, 0),
	Vector3(0.0717, 0.3703, 0),
	Vector3(0.0460, 0.2285, 0),
	Vector3(0.0841, 0.2443, 0),
	Vector3(0.0381, 0.1292, 0),
	Vector3(0.0735, 0.1345, 0),
	Vector3(0.0221, 0.0575, 0),
	Vector3(0.0381, 0.0531, 0),
	Vector3(0.0000, 0.0000, 0)
]

# Scale and offset half leaf points
var leaf_pts: Array[Vector3] = []
for p in half_pts:
	leaf_pts.append(Vector3(p.x * 1.2, (p.y - 0.2221) * 1.2, 0.05))

# Mirror for left side points
var full_leaf_pts: Array[Vector3] = []
for p in leaf_pts:
	full_leaf_pts.append(p)
for i in range(leaf_pts.size() - 2, 0, -1):
	var p: Vector3 = leaf_pts[i]
	full_leaf_pts.append(Vector3(-p.x, p.y, p.z))

var leaf_wire: BdgWire = Bdg.make_polygon(full_leaf_pts, true)
var leaf_face: BdgFace = Bdg.make_from_wires(leaf_wire)
var leaf_cut: BdgShape = Bdg.extrude_vec(leaf_face, Vector3(0, 0, -0.05))

var flag: BdgShape = Bdg.cut(Bdg.cut(Bdg.cut(flag_base, left_stripe), right_stripe), leaf_cut)
return Bdg.clean(flag)"""
