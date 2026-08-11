extends BdgPart
## BdgPartObject - base class for BuildPart objects & operations.
## Mirrors build123d/objects_part.py BasePartObject: wraps a solid into a
## Compound after applying align (MIN/CENTER/MAX) and rotation (X, Y, Z Euler degrees).
class_name BdgPartObject

var mode: int = BdgEnums.Mode.ADD
var rotation: Vector3 = Vector3.ZERO

func _init(...args) -> void:
	super(null, [])

## Build this part from a primitive solid.
func _from_solid(solid: BdgSolid, rot: Variant, align: Variant, md: int) -> void:
	mode = md
	var part: BdgShape = solid
	if align is int and align != BdgEnums.Align.NONE:
		var offset := _align_offset(part.bounding_box(), align)
		if offset != Vector3.ZERO:
			part = part.translate(offset)
	elif align is Array:
		var offset := _align_offset(part.bounding_box(), align)
		if offset != Vector3.ZERO:
			part = part.translate(offset)
	if rot is Vector3:
		rotation = rot
	elif rot is Array:
		rotation = Vector3(float(rot[0]), float(rot[1]), float(rot[2]))
	if rotation != Vector3.ZERO:
		part = part.rotated_about(BdgAxis.X, rotation.x)
		part = part.rotated_about(BdgAxis.Y, rotation.y)
		part = part.rotated_about(BdgAxis.Z, rotation.z)
	if part._wrapped.shape_type() != BdgEnums.ShapeType.COMPOUND:
		var comp := BdgShape.make_compound_of([part])
		_wrapped = comp._wrapped
		children = [part]
	else:
		_wrapped = part._wrapped
	if BdgBuilder.has_context(BdgBuildPart.TAG):
		BdgBuilder.add_to_current(self, mode, BdgBuildPart.TAG)

## Amount to move so the bounding box aligns to the origin.
## align: single BdgEnums.Align int (applies to all axes) or Array of 3.
func _align_offset(bbox: BdgBoundBox, align: Variant) -> Vector3:
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
	for i in 3:
		var a: int = arr[i]
		match a:
			BdgEnums.Align.MIN:
				offset[i] = -minp[i]
			BdgEnums.Align.MAX:
				offset[i] = -maxp[i]
			BdgEnums.Align.CENTER:
				offset[i] = -center[i]
	return offset
