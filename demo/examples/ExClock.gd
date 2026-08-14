extends "res://demo/BdgExample.gd"
class_name ExClock

func _init() -> void:
	super(
		"clock",
		"Parametric Clock Face",
		"Precision CAD",
		"Detailed parametric clock dial with circular profile, 60 radial minute indicators, 12 hour slots, and recessed center extruded to a solid clock face.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/clock.py"
	)
	gdscript_code = """var clock_radius := 50.0
var thickness := 5.0

# 1. Main clock base cylinder
var main_dial: BdgShape = Bdg.make_cylinder(clock_radius, thickness)

# 2. 12 Major hour slot cuts
for i in range(12):
	var ang: float = float(i) * TAU / 12.0
	var r_slot := clock_radius * 0.82
	var pos := Vector3(r_slot * cos(ang), r_slot * sin(ang), thickness - 1.0)
	var rot_deg: float = rad_to_deg(ang)
	var slot_face: BdgFace = Bdg.make_slot(clock_radius * 0.12, clock_radius * 0.04, rot_deg)
	var slot_cut: BdgShape = Bdg.translate(Bdg.extrude_vec(slot_face, Vector3(0, 0, 2.0)), pos)
	main_dial = Bdg.cut(main_dial, slot_cut)

# 3. 60 Minute tick marks
for i in range(60):
	if i % 5 == 0:
		continue # Skip hour markers
	var ang: float = float(i) * TAU / 60.0
	var r_tick := clock_radius * 0.92
	var pos := Vector3(r_tick * cos(ang), r_tick * sin(ang), thickness - 0.75)
	var tick_cyl: BdgShape = Bdg.translate(Bdg.make_cylinder(clock_radius * 0.012, 1.5), pos)
	main_dial = Bdg.cut(main_dial, tick_cyl)

# 4. Center arbor hole & recessed ring
var center_hole: BdgShape = Bdg.translate(Bdg.make_cylinder(clock_radius * 0.06, thickness + 2.0), Vector3(0, 0, -1.0))
var recessed_ring: BdgShape = Bdg.translate(Bdg.make_cylinder(clock_radius * 0.35, 1.0), Vector3(0, 0, thickness - 1.0))
var inner_ring: BdgShape = Bdg.translate(Bdg.make_cylinder(clock_radius * 0.25, 1.5), Vector3(0, 0, thickness - 1.25))

main_dial = Bdg.fuse(Bdg.cut(Bdg.cut(main_dial, center_hole), recessed_ring), inner_ring)
return Bdg.clean(main_dial)"""
