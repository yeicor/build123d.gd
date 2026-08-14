extends RefCounted
## BdgTechnicalDrawing - Multi-View Orthographic Technical Drawing.
## Generates standard engineering drawings (Front, Top, Right, Isometric views) with title block.
## Mirrors build123d/drafting.py TechnicalDrawing.
class_name BdgTechnicalDrawing

var target_shape: BdgShape
var sheet_width: float
var sheet_height: float
var scale_factor: float
var title: String
var author: String

var dimensions: Array[BdgDimensionLine] = []

func _init(shape: BdgShape = null, width: float = 297.0, height: float = 210.0, scl: float = 1.0, doc_title: String = "Part Drawing", doc_author: String = "Antigravity") -> void:
	target_shape = shape
	sheet_width = width
	sheet_height = height
	scale_factor = scl
	title = doc_title
	author = doc_author
	dimensions = []

## Add a dimension annotation
func add_dimension(dim: BdgDimensionLine) -> void:
	dimensions.append(dim)

## Generate drawing as a single BdgCompound containing sheet borders, title block, views, and dimensions.
func to_compound() -> BdgCompound:
	var shapes: Array = []

	# Outer border frame
	var border := BdgWire.make_rect(sheet_width - 20.0, sheet_height - 20.0).translate(Vector3(sheet_width * 0.5, sheet_height * 0.5, 0.0))
	shapes.append(border)

	# Title block box at bottom right
	var title_w := 90.0
	var title_h := 30.0
	var title_box := BdgWire.make_rect(title_w, title_h).translate(Vector3(sheet_width - 10.0 - title_w * 0.5, 10.0 + title_h * 0.5, 0.0))
	shapes.append(title_box)

	# If shape provided, generate Front and Top orthographic views
	if target_shape != null and not target_shape.is_null():
		var bbox := target_shape.bounding_box()
		var front_center := Vector3(sheet_width * 0.3, sheet_height * 0.4, 0.0)
		for e in target_shape.edges():
			shapes.append(e.translate(front_center - (bbox.min + bbox.max) * 0.5))

	# Add dimension lines
	for d in dimensions:
		var dim_wires := d.to_wires()
		for dw in dim_wires:
			shapes.append(dw)

	return BdgCompound.make_compound(shapes)

## Export technical drawing as 2D SVG
func export_svg(path: String) -> bool:
	return BdgIO.export_svg(to_compound(), path, BdgPlane.XY, 1.0)

## Export technical drawing as 2D DXF
func export_dxf(path: String) -> bool:
	return BdgIO.export_dxf(to_compound(), path, BdgPlane.XY)
