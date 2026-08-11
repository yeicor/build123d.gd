extends RefCounted
## BdgAxis - an infinite line in 3D space (position + direction), wrapping OcgGpAx1.
## Mirrors build123d/geometry.py Axis.
class_name BdgAxis

var _wrapped: OcgGpAx1 = null

var position: Vector3 = Vector3.ZERO:
	set(value):
		position = value
		_sync()
	get:
		return position
var direction: Vector3 = Vector3.BACK:
	set(value):
		direction = value.normalized()
		_sync()
	get:
		return direction

## Predefined axes
static var X: BdgAxis = null
static var Y: BdgAxis = null
static var Z: BdgAxis = null
static var X_flipped: BdgAxis = null
static var Y_flipped: BdgAxis = null
static var Z_flipped: BdgAxis = null

static func _static_init() -> void:
	X = BdgAxis.new(Vector3.ZERO, Vector3.RIGHT)
	Y = BdgAxis.new(Vector3.ZERO, Vector3.UP)
	Z = BdgAxis.new(Vector3.ZERO, Vector3.BACK)
	X_flipped = BdgAxis.new(Vector3.ZERO, Vector3.LEFT)
	Y_flipped = BdgAxis.new(Vector3.ZERO, Vector3.DOWN)
	Z_flipped = BdgAxis.new(Vector3.ZERO, Vector3.FORWARD)

## Construct. Args:
##   (position: Vector3, direction: Vector3)
##   (origin: Vector3, x_dir, z_dir) -> axis along x_dir through origin (plane-style)
##   (gp_ax1: OcgGpAx1) -> wrap
##   (axis: BdgAxis) -> copy
func _init(...args) -> void:
	_wrapped = OcgGpAx1.new()
	if args.size() >= 2 and (args[0] is Vector3 and args[1] is Vector3):
		position = args[0]
		direction = args[1]
		_sync()
	elif args.size() >= 3:
		position = args[0]
		var xd: Vector3 = args[1]
		var zd: Vector3 = args[2]
		direction = xd.normalized()
		_sync()
	elif args.size() == 1:
		var a = args[0]
		if a is BdgAxis:
			position = a.position
			direction = a.direction
		elif a is OcgGpAx1:
			_wrapped = a
			var loc := _wrapped.location()
			var dir := _wrapped.direction()
			position = BdgPlane._to_v3(loc)
			direction = BdgPlane._to_v3_dir(dir)
		else:
			push_error("BdgAxis: unsupported argument")

func _sync() -> void:
	if _wrapped == null:
		_wrapped = OcgGpAx1.new()
	var pnt := OcgGpPnt.from_6(position.x, position.y, position.z)
	var dir := OcgGpDir.from_6(direction.x, direction.y, direction.z)
	_wrapped = OcgGpAx1.from_n(pnt, dir)

## The wrapped OCCT gp_Ax1
func wrapped() -> OcgGpAx1:
	return _wrapped

## Flip axis direction
func flipped() -> BdgAxis:
	return BdgAxis.new(position, -direction)

func _to_string() -> String:
	return "Axis(position=%s, direction=%s)" % [position, direction]
