extends RefCounted
## BdgPlane - 2D plane in 3D space wrapping OcgGpPln (OCCT gp_Pln).
## Mirrors build123d/geometry.py Plane.
##
## Properties (Godot-native): origin (Vector3), x_dir, y_dir, z_dir (Vector3 normalized).
## wrapped (OcgGpPln): the underlying OCCT object.
class_name BdgPlane

var _wrapped: OcgGpPln = null
var _suppress_sync: bool = false

var origin: Vector3 = Vector3.ZERO:
	set(value):
		origin = value
		if not _suppress_sync:
			_sync()
	get:
		return origin
var x_dir: Vector3 = Vector3.RIGHT:
	set(value):
		x_dir = value.normalized()
		if not _suppress_sync:
			_sync()
	get:
		return x_dir
var y_dir: Vector3 = Vector3.UP:
	set(value):
		y_dir = value.normalized()
		if not _suppress_sync:
			_sync()
	get:
		return y_dir
var z_dir: Vector3 = Vector3.BACK:
	set(value):
		z_dir = value.normalized()
		if not _suppress_sync:
			_sync()
	get:
		return z_dir

## Predefined planes
static var XY: BdgPlane = null
static var YZ: BdgPlane = null
static var ZX: BdgPlane = null
static var XZ: BdgPlane = null
static var YX: BdgPlane = null
static var ZY: BdgPlane = null
static var origin_plane: BdgPlane = null

static func _static_init() -> void:
	XY = BdgPlane.new(Vector3.ZERO, Vector3.RIGHT, Vector3.BACK)
	YZ = BdgPlane.new(Vector3.ZERO, Vector3.UP, Vector3.RIGHT)
	ZX = BdgPlane.new(Vector3.ZERO, Vector3.BACK, Vector3.UP)
	XZ = BdgPlane.new(Vector3.ZERO, Vector3.RIGHT, Vector3.DOWN)
	YX = BdgPlane.new(Vector3.ZERO, Vector3.UP, Vector3.FORWARD)
	ZY = BdgPlane.new(Vector3.ZERO, Vector3.BACK, Vector3.LEFT)
	origin_plane = XY

## Construct a plane. Args can be:
##   ()                          -> XY plane at origin
##   (origin: Vector3)           -> XY plane at origin
##   (origin, x_dir, z_dir)      -> plane defined by origin, x direction, and z (normal) direction
##   (gp_pln: OcgGpPln)          -> wrap an existing OCCT plane
##   (wrapped: BdgPlane)         -> copy
func _init(...args) -> void:
	_wrapped = OcgGpPln.new()
	if args.is_empty():
		_sync_from_vectors(Vector3.ZERO, Vector3.RIGHT, Vector3.UP)
	elif args.size() == 1:
		var a = args[0]
		if a is BdgPlane:
			_wrapped = a._wrapped
		elif a is OcgGpPln:
			_wrapped = a
		elif a is Vector3:
			_sync_from_vectors(a, Vector3.RIGHT, Vector3.UP)
		else:
			push_error("BdgPlane: unsupported argument")
	elif args.size() >= 3:
		_sync_from_vectors(args[0], args[1], args[2])
	_sync_properties_from_wrapped()

func _sync_from_vectors(o: Vector3, x: Vector3, z: Vector3) -> void:
	_suppress_sync = true
	origin = o
	var xn := x.normalized()
	var zn := z.normalized()
	z_dir = zn
	x_dir = xn
	y_dir = zn.cross(xn).normalized()
	if y_dir == Vector3.ZERO:
		y_dir = Vector3.UP
	_suppress_sync = false
	_sync()

## Rebuild the OCCT gp_Pln from current vector properties
func _sync() -> void:
	if _wrapped == null:
		_wrapped = OcgGpPln.new()
	var dir := OcgGpDir.from_6(z_dir.x, z_dir.y, z_dir.z)
	var pnt := OcgGpPnt.from_6(origin.x, origin.y, origin.z)
	var vx := OcgGpDir.from_6(x_dir.x, x_dir.y, x_dir.z)
	var ax3 := OcgGpAx3.from_S(pnt, dir, vx)
	_wrapped = OcgGpPln.from_k(ax3)

## Update x_dir/y_dir/z_dir properties from the OCCT plane
func _sync_properties_from_wrapped() -> void:
	var ax3 := _wrapped.position()
	origin = _to_v3(ax3.location())
	x_dir = _to_v3_dir(ax3.x_direction())
	z_dir = _to_v3_dir(ax3.direction())
	y_dir = z_dir.cross(x_dir).normalized()

static func _to_v3(p: OcgGpPnt) -> Vector3:
	return Vector3(p.x(), p.y(), p.z())

static func _to_v3_dir(d: OcgGpDir) -> Vector3:
	return Vector3(d.x(), d.y(), d.z()).normalized()

static func _to_v3v(v: OcgGpVec) -> Vector3:
	return Vector3(v.x(), v.y(), v.z())

func _to_pnt() -> OcgGpPnt:
	return OcgGpPnt.from_6(origin.x, origin.y, origin.z)

func _to_dir() -> OcgGpDir:
	return OcgGpDir.from_6(z_dir.x, z_dir.y, z_dir.z)

## Set location (origin)
func set_location(value: Vector3) -> void:
	origin = value

## The plane's wrapped OCCT gp_Pln
func wrapped() -> OcgGpPln:
	return _wrapped

## Flip the plane normal
func reverse() -> void:
	var tmp := z_dir
	z_dir = -tmp
	x_dir = -x_dir

## Distance from a point to the plane (unsigned)
func distance(p: Vector3) -> float:
	return BdgVector.distance_to_plane(p, origin, z_dir)

## Project a point onto the plane
func project(p: Vector3) -> Vector3:
	return BdgVector.project_to_plane(p, origin, z_dir)

## Signed distance from the plane to point p
func signed_distance(p: Vector3) -> float:
	return BdgVector.signed_distance_from_plane(p, origin, z_dir)

func to_axis() -> BdgAxis:
	return BdgAxis.new(origin, z_dir)

## Convert to an OCCT gp_Ax2 with x_dir as X and z_dir as Z
func to_ax2() -> OcgGpAx2:
	return OcgGpAx2.from_S(
		OcgGpPnt.from_6(origin.x, origin.y, origin.z),
		OcgGpDir.from_6(z_dir.x, z_dir.y, z_dir.z),
		OcgGpDir.from_6(x_dir.x, x_dir.y, x_dir.z),
	)

## Create a new plane shifted along its normal z_dir by distance.
func offset(dist: float) -> BdgPlane:
	return BdgPlane.new(origin + z_dir * dist, x_dir, z_dir)

## Return location corresponding to this plane (origin + orientation)
func location() -> BdgLocation:
	var b := Basis(x_dir, y_dir, z_dir)
	return BdgLocation.new(origin, b.get_rotation_quaternion())

## Return new plane with origin shifted to new_origin
func shift_origin(new_origin: Vector3) -> BdgPlane:
	return BdgPlane.new(new_origin, x_dir, z_dir)

## Transform world 3D point/vector into local plane 2D/3D coordinates
func to_local_coords(world_p: Vector3) -> Vector3:
	var d := world_p - origin
	return Vector3(d.dot(x_dir), d.dot(y_dir), d.dot(z_dir))

## Transform local plane 2D/3D coordinates into world 3D coordinates
func from_local_coords(local_p: Vector3) -> Vector3:
	return origin + x_dir * local_p.x + y_dir * local_p.y + z_dir * local_p.z

## Forward 4x4 matrix mapping local plane space to world space
func forward_transform() -> BdgMatrix:
	var loc := location()
	return BdgMatrix.translation(loc.position).multiplied(BdgMatrix.new())

## Reverse 4x4 matrix mapping world space to local plane space
func reverse_transform() -> BdgMatrix:
	return forward_transform().inverted()

## Create a new plane rotated by angle_deg around an axis vector or local axis
func rotated(angle_deg: float, axis_vector: Vector3 = Vector3.ZERO) -> BdgPlane:
	var rot_axis := axis_vector if axis_vector != Vector3.ZERO else z_dir
	var new_x := x_dir.rotated(rot_axis.normalized(), deg_to_rad(angle_deg))
	var new_z := z_dir.rotated(rot_axis.normalized(), deg_to_rad(angle_deg))
	return BdgPlane.new(origin, new_x, new_z)

## Move plane origin in-place by offset_vec
func move(offset_vec: Vector3) -> BdgPlane:
	origin += offset_vec
	_sync()
	return self

## Move plane origin returning a new BdgPlane
func moved(offset_vec: Vector3) -> BdgPlane:
	return BdgPlane.new(origin + offset_vec, x_dir, z_dir)

## Check if point lies within plane tolerance
func contains(p: Vector3, tolerance: float = 1e-5) -> bool:
	return distance(p) < tolerance

## Compute line of intersection with another plane, or point of intersection with line/axis
func intersect(other: Variant) -> Variant:
	if other is BdgPlane:
		var other_pln: BdgPlane = other as BdgPlane
		var n1 := z_dir
		var n2 := other_pln.z_dir
		var line_dir := n1.cross(n2)
		if line_dir.length_squared() < 1e-8:
			return null # parallel planes
		var line_dir_n := line_dir.normalized()
		var d1 := signed_distance(Vector3.ZERO)
		var d2 := other_pln.signed_distance(Vector3.ZERO)
		var pnt := ((n1 * d2) - (n2 * d1)).cross(line_dir_n) / line_dir.length_squared()
		return BdgAxis.new(pnt, line_dir_n)
	elif other is BdgAxis:
		var other_axis: BdgAxis = other as BdgAxis
		var denom := z_dir.dot(other_axis.direction)
		if absf(denom) < 1e-8:
			return null
		var dist_t := (origin - other_axis.position).dot(z_dir) / denom
		return other_axis.position + other_axis.direction * dist_t
	return null


func _to_string() -> String:
	return "Plane(origin=%s, x_dir=%s, z_dir=%s)" % [origin, x_dir, z_dir]

