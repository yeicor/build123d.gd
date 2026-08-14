extends "res://demo/BdgExample.gd"
class_name ExBoxesOnFaces

func _init() -> void:
	super(
		"boxes_on_faces",
		"Boxes on Faces",
		"Basics",
		"Demo adding features to multiple faces of a box in one operation.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/boxes_on_faces.py"
	)
	gdscript_code = """var base_box := Bdg.make_box(3.0, 3.0, 3.0)
var main_shape: BdgShape = base_box

for f in Bdg.faces(base_box):
	var face: BdgFace = f as BdgFace
	var p := Bdg.to_plane(face)
	var rect := Bdg.make_rect(1.0, 2.0, p)
	var rot_axis := Bdg.axis(p.origin, p.z_dir)
	var rot_rect := Bdg.rotate(rect, rot_axis, 45.0) as BdgFace
	var extr_part := Bdg.extrude_vec(rot_rect, p.z_dir * 0.1)
	main_shape = Bdg.fuse(main_shape, extr_part)

return main_shape"""
