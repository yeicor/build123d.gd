extends BdgSketch
## BdgSketchObject - base class for BuildSketch objects & operations.
## Mirrors build123d/objects_sketch.py BaseSketchObject: wraps a face into a
## Sketch after applying 2D align (MIN/CENTER/MAX) and rotation about Z.
class_name BdgSketchObject

var mode: int = BdgEnums.Mode.ADD
var rotation: float = 0.0

func _init(...args) -> void:
	super(null, [])

## Build this sketch object from a primitive face.
func _from_face(face: BdgFace, rot: float, align: Variant, md: int) -> void:
	mode = md
	rotation = rot
	var part: BdgShape = face
	if align is int and align != BdgEnums.Align.NONE:
		var offset := _align_offset_2d(part.bounding_box(), align)
		if offset != Vector3.ZERO:
			part = part.translate(offset)
	elif align is Array:
		var offset := _align_offset_2d(part.bounding_box(), align)
		if offset != Vector3.ZERO:
			part = part.translate(offset)
	if rotation != 0.0:
		part = part.rotated_about(BdgAxis.Z, rotation)
	var faces := part.faces()
	_wrapped = BdgShape.make_compound_of(faces)._wrapped
	children = faces
	if BdgBuilder.has_context(BdgBuildSketch.TAG):
		BdgBuilder.add_to_current(self, mode, BdgBuildSketch.TAG)

## 2D alignment: single BdgEnums.Align int or Array of 2.
func _align_offset_2d(bbox: BdgBoundBox, align: Variant) -> Vector3:
	var minp := bbox.min
	var maxp := bbox.max
	var center := (minp + maxp) * 0.5
	if align is int:
		match align:
			BdgEnums.Align.MIN:
				return -minp
			BdgEnums.Align.MAX:
				return -maxp
			BdgEnums.Align.CENTER:
				return -center
		return Vector3.ZERO
	var offset := Vector3.ZERO
	var arr: Array = align
	for i in 2:
		var a: int = arr[i]
		match a:
			BdgEnums.Align.MIN:
				offset[i] = -minp[i]
			BdgEnums.Align.MAX:
				offset[i] = -maxp[i]
			BdgEnums.Align.CENTER:
				offset[i] = -center[i]
	return offset
