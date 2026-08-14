extends RefCounted
## BdgLocations - Base Location Context & Generator.
## Manages a stack of active location contexts so objects created inside a builder
## are automatically replicated at each active location.
## Mirrors build123d/build_common.py Locations, GridLocations, HexLocations, PolarLocations.
class_name BdgLocations

static var _stack: Array = []

var locations: Array[BdgLocation] = []

## Push this location context onto the active stack.
func begin() -> void:
	_stack.append(self)

## Pop this location context from the active stack.
func end() -> bool:
	if not _stack.is_empty() and _stack.back() == self:
		_stack.pop_back()
		return true
	return false

## Get currently active locations (or empty array if none active).
static func get_current_locations() -> Array[BdgLocation]:
	if _stack.is_empty():
		return []
	var cur: BdgLocations = _stack.back()
	return cur.locations

## Whether a location context is currently active.
static func has_active_locations() -> bool:
	return not _stack.is_empty()

## Construct from array of Vector3, BdgLocation, or BdgPlane.
func _init(...args) -> void:
	locations = []
	if args.is_empty():
		return
	if args[0] is Array:
		for item in args[0]:
			if item is BdgLocation:
				locations.append(item)
			elif item is Vector3:
				locations.append(BdgLocation.new(item))
			elif item is BdgPlane:
				locations.append(BdgLocation.new((item as BdgPlane).origin, (item as BdgPlane).to_quaternion() if item.has_method("to_quaternion") else Quaternion.IDENTITY))
	else:
		for item in args:
			if item is BdgLocation:
				locations.append(item)
			elif item is Vector3:
				locations.append(BdgLocation.new(item))
			elif item is BdgPlane:
				locations.append(BdgLocation.new((item as BdgPlane).origin))
