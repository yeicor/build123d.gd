extends "res://demo/BdgExample.gd"
class_name ExHoles

func _init() -> void:
	super(
		"holes",
		"CAD Hole Types Showcase",
		"Intermediate",
		"Demonstrates a simple through hole: a cylinder with a concentric bore cut through its full height.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/holes.py"
	)
	gdscript_code = """# Base cylinder (r=3, h=2)
var cyl: BdgShape = Bdg.make_cylinder(3.0, 2.0)

# Simple through hole: Hole(radius=1) cuts a r=1 cylinder through the full height
var drill: BdgShape = Bdg.translate(Bdg.make_cylinder(1.0, 4.0), Vector3(0, 0, -1))
var part: BdgShape = Bdg.cut(cyl, drill)

return Bdg.clean(part)"""
