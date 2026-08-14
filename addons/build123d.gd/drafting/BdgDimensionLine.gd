extends RefCounted
## BdgDimensionLine - 2D Technical Drafting Dimension Line Annotation.
## Represents a linear or radial dimension line with extension lines, arrows, and value text.
## Mirrors build123d/drafting.py DimensionLine.
class_name BdgDimensionLine

var start_point: Vector3
var end_point: Vector3
var offset: float
var text: String
var arrow_size: float = 2.5

func _init(p1: Vector3, p2: Vector3, off: float = 10.0, txt: String = "", arr_size: float = 2.5) -> void:
	start_point = p1
	end_point = p2
	offset = off
	arrow_size = arr_size
	if txt != "":
		text = txt
	else:
		var dist := p1.distance_to(p2)
		text = "%.1f" % dist

## Generate 2D CAD wires for the dimension line annotation (witness lines + dim line)
func to_wires() -> Array[BdgWire]:
	var dir := (end_point - start_point).normalized()
	var normal := Vector3.BACK.cross(dir).normalized() * offset

	var p1_dim := start_point + normal
	var p2_dim := end_point + normal

	# Extension lines
	var ext1 := BdgWire.make_polygon([start_point, p1_dim + normal.normalized() * 2.0], false)
	var ext2 := BdgWire.make_polygon([end_point, p2_dim + normal.normalized() * 2.0], false)
	# Dimension line
	var dim := BdgWire.make_polygon([p1_dim, p2_dim], false)

	return [ext1, ext2, dim]
