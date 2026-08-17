extends RefCounted
## BdgLocation - a position + orientation (rotation) in 3D space.
## Wraps OcgTopLocLocation (OCCT TopLoc_Location) but exposes Godot-native
## position (Vector3) and orientation (Quaternion / Vector3 euler in degrees).
## Mirrors build123d/geometry.py Location.
class_name BdgLocation

var _wrapped: OcgTopLocLocation = null

var position: Vector3 = Vector3.ZERO:
	set(value):
		position = value
		_sync()
	get:
		return position
var orientation: Quaternion = Quaternion.IDENTITY:
	set(value):
		orientation = value.normalized()
		_sync()
	get:
		return orientation

## identity location
static func new_identity() -> BdgLocation:
	return BdgLocation.new()

## Construct. Args:
##   ()                       -> identity
##   (position: Vector3)      -> translation only
##   (position, orientation: Quaternion)
##   (location: BdgLocation)  -> copy
##   (gp_location: OcgTopLocLocation) -> wrap
func _init(...args) -> void:
	_wrapped = OcgTopLocLocation.new()
	if args.size() == 1 and args[0] is BdgLocation:
		var other: BdgLocation = args[0]
		position = other.position
		orientation = other.orientation
	elif args.size() == 1 and args[0] is OcgTopLocLocation:
		_wrapped = args[0]
		_sync_properties_from_wrapped()
	elif args.size() == 1 and args[0] is Vector3:
		position = args[0]
		orientation = Quaternion.IDENTITY
		_sync()
	elif args.size() >= 2:
		position = args[0]
		orientation = args[1]
		_sync()
	else:
		position = Vector3.ZERO
		orientation = Quaternion.IDENTITY

func _sync() -> void:
	if _wrapped == null:
		_wrapped = OcgTopLocLocation.new()
	var trsf := OcgGpTrsf.new()
	var q := OcgGpQuaternion.from_r(orientation.x, orientation.y, orientation.z, orientation.w)
	trsf.set_rotation_A(q)
	var t := OcgGpVec.from_6(position.x, position.y, position.z)
	trsf.set_translation_part(t)
	_wrapped = OcgTopLocLocation.from_z(trsf)

func _sync_properties_from_wrapped() -> void:
	if _wrapped == null:
		return
	var trsf := _wrapped.transformation()
	var rot := trsf.get_rotation_k()
	orientation = Quaternion(rot.x(), rot.y(), rot.z(), rot.w()).normalized()
	var t := trsf.translation_part()
	position = Vector3(t.x(), t.y(), t.z())

func wrapped() -> OcgTopLocLocation:
	return _wrapped

func inverted() -> BdgLocation:
	var inv := _wrapped.inverted()
	return BdgLocation.new(inv)

## Alias for inverted (Python parity)
func inverse() -> BdgLocation:
	return inverted()

## Combine two locations: self * other
func multiplied(other: BdgLocation) -> BdgLocation:
	var result := _wrapped.multiplied(other._wrapped)
	return BdgLocation.new(result)

## Mirror location across a plane or axis
func mirror(plane_or_axis: Variant) -> BdgLocation:
	var t := to_transform3d()
	if plane_or_axis is BdgPlane:
		var p: BdgPlane = plane_or_axis
		var mirrored_pos := p.origin + (t.origin - p.origin) - p.z_dir * (2.0 * p.signed_distance(t.origin))
		return BdgLocation.new(mirrored_pos, t.basis.get_rotation_quaternion())
	elif plane_or_axis is BdgAxis:
		var a: BdgAxis = plane_or_axis
		var proj := BdgVector.project_to_line(t.origin - a.position, a.direction) + a.position
		var mirrored_pos := proj + (proj - t.origin)
		return BdgLocation.new(mirrored_pos, t.basis.get_rotation_quaternion())
	return self

## Convert location orientation/position to BdgAxis along Z axis
func to_axis() -> BdgAxis:
	var t := to_transform3d()
	return BdgAxis.new(t.origin, t.basis.z.normalized())

## Convert location to array tuple [px, py, pz, qx, qy, qz, qw]
func to_tuple() -> Array:
	return [position.x, position.y, position.z, orientation.x, orientation.y, orientation.z, orientation.w]

## Local X axis
func x_axis() -> BdgAxis:
	var t := to_transform3d()
	return BdgAxis.new(t.origin, t.basis.x.normalized())

## Local Y axis
func y_axis() -> BdgAxis:
	var t := to_transform3d()
	return BdgAxis.new(t.origin, t.basis.y.normalized())

## Local Z axis
func z_axis() -> BdgAxis:
	var t := to_transform3d()
	return BdgAxis.new(t.origin, t.basis.z.normalized())

## Center position (alias for position)
func center() -> Vector3:
	return position

## Convert to Godot Transform3D
func to_transform3d() -> Transform3D:
	return Transform3D(Basis(orientation), position)

func _to_string() -> String:
	return "Location(position=%s, orientation=%s)" % [position, orientation]

