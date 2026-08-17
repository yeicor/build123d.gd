extends RefCounted
## BdgMatrix - a 4x4 affine transformation matrix wrapping OcgGpTrsf (OCCT gp_Trsf).
## Mirrors build123d/geometry.py Matrix.
class_name BdgMatrix

var _wrapped: OcgGpTrsf = null

## identity
static func new_identity() -> BdgMatrix:
	return BdgMatrix.new()

## Construct. Args:
##   ()                -> identity
##   (matrix: BdgMatrix) -> copy
##   (trsf: OcgGpTrsf) -> wrap
func _init(...args) -> void:
	_wrapped = OcgGpTrsf.new()
	if args.size() == 1 and args[0] is BdgMatrix:
		_wrapped = args[0]._wrapped
	elif args.size() == 1 and args[0] is OcgGpTrsf:
		_wrapped = args[0]

func wrapped() -> OcgGpTrsf:
	return _wrapped

## 4x4 matrix values (OCCT convention: [a11..a34])
func get_values() -> Array:
	var v: Array = []
	for row in range(1, 4):
		for col in range(1, 5):
			v.append(_wrapped.value(row, col))
	return v

## Extract as a Godot Transform3D
func to_transform3d() -> Transform3D:
	var m: Array = get_values()
	# OCCT gp_Trsf matrix is a 3x4: a11 a12 a13 a14 / a21 a22 a23 a24 / a31 a32 a33 a34
	var basis := Basis(
		Vector3(m[0], m[3], m[6]),   # column 1
		Vector3(m[1], m[4], m[7]),   # column 2
		Vector3(m[2], m[5], m[8]),   # column 3
	)
	var t := Vector3(m[9], m[10], m[11])
	return Transform3D(basis, t)

## Build a rotation matrix about an axis by angle in degrees
static func rotation_about(axis_pos: Vector3, axis_dir: Vector3, angle_deg: float) -> BdgMatrix:
	var trsf := OcgGpTrsf.new()
	var pnt := OcgGpPnt.from_6(axis_pos.x, axis_pos.y, axis_pos.z)
	var dir := OcgGpDir.from_6(axis_dir.x, axis_dir.y, axis_dir.z)
	var ax1 := OcgGpAx1.from_n(pnt, dir)
	trsf.set_rotation_6(ax1, deg_to_rad(angle_deg))
	var m := BdgMatrix.new()
	m._wrapped = trsf
	return m

## Translation matrix
static func translation(v: Vector3) -> BdgMatrix:
	var trsf := OcgGpTrsf.new()
	trsf.set_translation_Z(OcgGpVec.from_6(v.x, v.y, v.z))
	var m := BdgMatrix.new()
	m._wrapped = trsf
	return m

## Scale matrix
static func scaling(center: Vector3, s: Vector3) -> BdgMatrix:
	var trsf := OcgGpTrsf.new()
	trsf.set_scale(OcgGpPnt.from_6(center.x, center.y, center.z), s.x)
	var m := BdgMatrix.new()
	m._wrapped = trsf
	return m

## Compose: self * other (apply self after other)
func multiplied(other: BdgMatrix) -> BdgMatrix:
	var result := _wrapped.multiplied(other._wrapped)
	var m := BdgMatrix.new()
	m._wrapped = result
	return m

func inverted() -> BdgMatrix:
	var inv := _wrapped.inverted()
	var m := BdgMatrix.new()
	m._wrapped = inv
	return m

## Alias for inverted (Python parity)
func inverse() -> BdgMatrix:
	return inverted()

## Alias for multiplied (Python parity)
func multiply(other: BdgMatrix) -> BdgMatrix:
	return multiplied(other)

## Rotate matrix in-place or returning new BdgMatrix around axis
func rotate(axis_pos_or_dir: Variant, angle_deg: float = 0.0) -> BdgMatrix:
	var axis_pos := Vector3.ZERO
	var axis_dir := Vector3.UP
	if axis_pos_or_dir is BdgAxis:
		axis_pos = axis_pos_or_dir.position
		axis_dir = axis_pos_or_dir.direction
	elif axis_pos_or_dir is Vector3:
		axis_dir = axis_pos_or_dir
	var r := BdgMatrix.rotation_about(axis_pos, axis_dir, angle_deg)
	return r.multiplied(self)

## Return 4x4 matrix values formatted as a transposed 4x4 nested array
func transposed_list() -> Array:
	var vals := get_values() # 12 elements (3x4)
	return [
		[vals[0], vals[3], vals[6], 0.0],
		[vals[1], vals[4], vals[7], 0.0],
		[vals[2], vals[5], vals[8], 0.0],
		[vals[9], vals[10], vals[11], 1.0],
	]

## Apply this transform to a point
func apply(p: Vector3) -> Vector3:
	var t := to_transform3d()
	return t * p

## Apply this transform to a direction (no translation)
func apply_dir(d: Vector3) -> Vector3:
	var t := to_transform3d()
	return t.basis * d

func _to_string() -> String:
	return "Matrix(%s)" % _wrapped

