extends "res://demo/BdgExample.gd"
class_name ExHoles

func _init() -> void:
	super(
		"holes",
		"CAD Hole Types Showcase",
		"Intermediate",
		"Demonstrates standard mechanical fasteners and hole patterns: through-hole, recessed counterbore, recessed countersink, and flush countersink.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/holes.py"
	)
	gdscript_code = """# 1. Base Cylinders
var c1: BdgShape = Bdg.translate(Bdg.make_cylinder(3.0, 2.0), Vector3(0, 0, 0))
var c2: BdgShape = Bdg.translate(Bdg.make_cylinder(3.0, 2.0), Vector3(10, 0, 0))
var c3: BdgShape = Bdg.translate(Bdg.make_cylinder(3.0, 2.0), Vector3(0, 10, 0))
var c4: BdgShape = Bdg.translate(Bdg.make_cylinder(3.0, 2.0), Vector3(10, 10, 0))

# 2. Simple through hole
var h1: BdgShape = Bdg.translate(Bdg.hole(1.0, 4.0), Vector3(0, 0, -1))
var part1: BdgShape = Bdg.cut(c1, h1)

# 3. Recessed CounterBore hole
var cb: BdgShape = Bdg.translate(Bdg.counter_bore_hole(1.0, 4.0, 1.5, 0.5), Vector3(10, 0, 0))
var part2: BdgShape = Bdg.cut(c2, cb)

# 4. Recessed CounterSink hole
var cs1: BdgShape = Bdg.translate(Bdg.counter_sink_hole(1.0, 1.5, 4.0, 82.0), Vector3(0, 10, 0))
var part3: BdgShape = Bdg.cut(c3, cs1)

# 5. Flush CounterSink hole at top face
var cs2: BdgShape = Bdg.translate(Bdg.counter_sink_hole(1.0, 1.5, 4.0, 82.0), Vector3(10, 10, 2))
var part4: BdgShape = Bdg.cut(c4, cs2)

var compound: BdgShape = Bdg.make_compound([part1, part2, part3, part4])
return Bdg.clean(compound)"""
