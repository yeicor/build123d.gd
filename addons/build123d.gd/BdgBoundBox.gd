extends RefCounted
## BdgBoundBox - axis-aligned bounding box wrapping OcgBndBox (OCCT Bnd_Box).
## Mirrors build123d/geometry.py BoundBox.
## Godot-native: min (Vector3), max (Vector3), size, center, diagonal.
class_name BdgBoundBox

var _wrapped: OcgBndBox = null

var min: Vector3 = Vector3.ZERO:
	set(value):
		min = value
		_sync()
	get:
		return min
var max: Vector3 = Vector3.ZERO:
	set(value):
		max = value
		_sync()
	get:
		return max

## Construct. Args:
##   ()                  -> empty
##   (min: Vector3, max: Vector3)
##   (bnd_box: OcgBndBox) -> wrap
##   (box: BdgBoundBox)   -> copy
func _init(...args) -> void:
	if args.size() == 0:
		_wrapped = OcgBndBox.new()
		_wrapped.set_void()
	elif args.size() == 1 and args[0] is BdgBoundBox:
		_wrapped = args[0]._wrapped
	elif args.size() == 1 and args[0] is OcgBndBox:
		_wrapped = args[0]
		_sync_properties_from_wrapped()
	elif args.size() >= 2 and args[0] is Vector3 and args[1] is Vector3:
		_wrapped = OcgBndBox.new()
		min = args[0]
		max = args[1]
		_sync()
	else:
		push_error("BdgBoundBox: unsupported arguments")

func _sync() -> void:
	if _wrapped == null:
		_wrapped = OcgBndBox.new()
	_wrapped.set_void()
	var pmin := OcgGpPnt.from_6(min.x, min.y, min.z)
	var pmax := OcgGpPnt.from_6(max.x, max.y, max.z)
	_wrapped = OcgBndBox.from_W(pmin, pmax)

func _sync_properties_from_wrapped() -> void:
	var lo: Vector3
	var hi: Vector3
	if _wrapped.is_void():
		lo = Vector3.ZERO
		hi = Vector3.ZERO
	else:
		lo = Vector3(_wrapped.get_x_min(), _wrapped.get_y_min(), _wrapped.get_z_min())
		hi = Vector3(_wrapped.get_x_max(), _wrapped.get_y_max(), _wrapped.get_z_max())
	min = lo
	max = hi

func wrapped() -> OcgBndBox:
	return _wrapped

func is_void() -> bool:
	return _wrapped.is_void()

func size() -> Vector3:
	return max - min

func center() -> Vector3:
	return (min + max) * 0.5

func diagonal() -> float:
	return size().length()

func diagonal_length() -> float:
	return size().length()

func contains(p: Vector3, tolerance: float = 1e-6) -> bool:
	return (
		p.x >= min.x - tolerance and p.x <= max.x + tolerance
		and p.y >= min.y - tolerance and p.y <= max.y + tolerance
		and p.z >= min.z - tolerance and p.z <= max.z + tolerance
	)

func add_box(other: BdgBoundBox) -> void:
	_wrapped.add(other._wrapped)
	_sync_properties_from_wrapped()

## Generic add method (box or vector/point)
func add(other: Variant) -> void:
	if other is BdgBoundBox:
		add_box(other)
	elif other is Vector3:
		min = Vector3(minf(min.x, other.x), minf(min.y, other.y), minf(min.z, other.z))
		max = Vector3(maxf(max.x, other.x), maxf(max.y, other.y), maxf(max.z, other.z))

## Check if point or box is inside this bounding box
func is_inside(other: Variant, tolerance: float = 1e-6) -> bool:
	if other is Vector3:
		return contains(other, tolerance)
	elif other is BdgBoundBox:
		return (
			other.min.x >= min.x - tolerance and other.max.x <= max.x + tolerance
			and other.min.y >= min.y - tolerance and other.max.y <= max.y + tolerance
			and other.min.z >= min.z - tolerance and other.max.z <= max.z + tolerance
		)
	return false

## Measure box dimensions (returns size)
func measure() -> Vector3:
	return size()

## Check if two bounding boxes overlap
func overlaps(other: BdgBoundBox, tolerance: float = 1e-6) -> bool:
	return (
		min.x <= other.max.x + tolerance and max.x >= other.min.x - tolerance
		and min.y <= other.max.y + tolerance and max.y >= other.min.y - tolerance
		and min.z <= other.max.z + tolerance and max.z >= other.min.z - tolerance
	)

## Compute alignment offset vector for aligning shapes
func to_align_offset(align: Variant) -> Vector3:
	var sz := size()
	var offset := Vector3.ZERO
	if align is Array:
		# [align_x, align_y, align_z]
		var ax: int = align[0] if align.size() > 0 else BdgEnums.Align.CENTER
		var ay: int = align[1] if align.size() > 1 else BdgEnums.Align.CENTER
		var az: int = align[2] if align.size() > 2 else BdgEnums.Align.CENTER
		
		match ax:
			BdgEnums.Align.MIN: offset.x = -min.x
			BdgEnums.Align.MAX: offset.x = -max.x
			BdgEnums.Align.CENTER: offset.x = -(min.x + max.x) * 0.5
		match ay:
			BdgEnums.Align.MIN: offset.y = -min.y
			BdgEnums.Align.MAX: offset.y = -max.y
			BdgEnums.Align.CENTER: offset.y = -(min.y + max.y) * 0.5
		match az:
			BdgEnums.Align.MIN: offset.z = -min.z
			BdgEnums.Align.MAX: offset.z = -max.z
			BdgEnums.Align.CENTER: offset.z = -(min.z + max.z) * 0.5
	return offset

## Find outside box bounds in 2D plane
func find_outside_box_2d() -> Array:
	return [Vector2(min.x, min.y), Vector2(max.x, max.y)]

## Convert to Godot native AABB
func to_aabb() -> AABB:
	return AABB(min, size())

## expand by a scalar on all sides
func enlarge(delta: float) -> void:
	_wrapped.enlarge(delta)
	_sync_properties_from_wrapped()

func _to_string() -> String:
	return "BoundBox(min=%s, max=%s)" % [min, max]

