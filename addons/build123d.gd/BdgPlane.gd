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

func _to_string() -> String:
	return "Plane(origin=%s, x_dir=%s, z_dir=%s)" % [origin, x_dir, z_dir]
