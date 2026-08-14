extends "res://demo/BdgExample.gd"
class_name ExClock

func _init() -> void:
	super(
		"clock",
		"Parametric Clock Face",
		"Precision CAD",
		"Detailed parametric 2D clock dial: circular face, 60 radial minute indicators with filleted corners, 12 hour slots, and 12 recessed hour labels.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/clock.py"
	)
	gdscript_code = """var clock_radius := 10.0

# Build the minute indicator: an annular sector between two CenterArcs joined by two
# radial Lines, turned into a face and filleted at its 4 corners (radius 0.1).
var make_mi := func(cr: float) -> BdgFace:
	var rout := cr * 0.975
	var rin := cr * 0.925
	var rf := cr * 0.01
	var t1 := 0.75
	var t2 := 5.25
	var pho := rad_to_deg(asin(rf / (rout - rf)))
	var phi := rad_to_deg(asin(rf / (rin + rf)))
	var pa := func(ang: float, rad: float) -> Vector3:
		return Vector3(rad * cos(deg_to_rad(ang)), rad * sin(deg_to_rad(ang)), 0)
	var pca := func(center: Vector3, ang: float, rad: float) -> Vector3:
		return center + Vector3(rad * cos(deg_to_rad(ang)), rad * sin(deg_to_rad(ang)), 0)
	var p_ao: Vector3 = pa.call(t1 + pho, rout)
	var p_al: Vector3 = pa.call(t1, (rout - rf) * cos(deg_to_rad(pho)))
	var p_bl: Vector3 = pa.call(t2, (rout - rf) * cos(deg_to_rad(pho)))
	var p_bo: Vector3 = pa.call(t2 - pho, rout)
	var p_cl: Vector3 = pa.call(t2, (rin + rf) * cos(deg_to_rad(phi)))
	var p_ci: Vector3 = pa.call(t2 - phi, rin)
	var p_di: Vector3 = pa.call(t1 + phi, rin)
	var p_dl: Vector3 = pa.call(t1, (rin + rf) * cos(deg_to_rad(phi)))
	var c_b: Vector3 = pa.call(t2 - pho, rout - rf)
	var c_c: Vector3 = pa.call(t2 - phi, rin + rf)
	var c_d: Vector3 = pa.call(t1 + phi, rin + rf)
	var c_a: Vector3 = pa.call(t1 + pho, rout - rf)
	var e1: BdgEdge = BdgEdge.make_three_point_arc(p_ao, pa.call(3.0, rout), p_bo)
	var e_fb: BdgEdge = BdgEdge.make_three_point_arc(p_bo, pca.call(c_b, t2 - pho / 2.0 + 45.0, rf), p_bl)
	var e_l2: BdgEdge = BdgEdge.make_line(p_bl, p_cl)
	var e_fc: BdgEdge = BdgEdge.make_three_point_arc(p_cl, pca.call(c_c, t2 - phi / 2.0 + 135.0, rf), p_ci)
	var e2: BdgEdge = BdgEdge.make_three_point_arc(p_ci, pa.call(3.0, rin), p_di)
	var e_fd: BdgEdge = BdgEdge.make_three_point_arc(p_di, pca.call(c_d, t1 + phi / 2.0 + 225.0, rf), p_dl)
	var e_l1: BdgEdge = BdgEdge.make_line(p_dl, p_al)
	var e_fa: BdgEdge = BdgEdge.make_three_point_arc(p_al, pca.call(c_a, t1 + pho / 2.0 + 315.0, rf), p_ao)
	var wire: BdgWire = BdgWire.make_wire([e1, e_fb, e_l2, e_fc, e2, e_fd, e_l1, e_fa])
	return Bdg.make_face(wire)

var mi_face: BdgFace = make_mi.call(clock_radius)

# Clock face: outer circle with the minute indicators, hour slots and labels recessed.
var clock_face := Bdg.build_sketch(func():
	Bdg.circle(clock_radius)
	Bdg.polar_locations(0, 60, 0, 360, true, func():
		Bdg.add(mi_face, Bdg.Mode.SUBTRACT)
	)
	Bdg.polar_locations(clock_radius * 0.875, 12, 0, 360, true, func():
		Bdg.slot_overall(clock_radius * 0.05, clock_radius * 0.025, 0.0, Bdg.Align.CENTER, Bdg.Mode.SUBTRACT)
	)
	for hour in range(1, 13):
		var ang: float = -float(hour) * 30.0 + 90.0
		Bdg.polar_locations(clock_radius * 0.75, 1, ang, 360.0, false, func():
			Bdg.text(str(hour), clock_radius * 0.175, "sans-serif", Bdg.FontStyle.BOLD, Bdg.Align.CENTER, 0.0, Bdg.Mode.SUBTRACT)
		)
)

return Bdg.clean(clock_face)"""