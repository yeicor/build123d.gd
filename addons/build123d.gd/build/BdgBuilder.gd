extends RefCounted
## BdgBuilder - base class for all builders (BuildPart, BuildSketch, BuildLine).
## Provides a push/pop context system: builders are active between begin() and end().
## Mirrors build123d/build_common.py Builder.
class_name BdgBuilder

static var _current: BdgBuilder = null
static var _contexts: Array = []

var _tag: String = "Builder"
var _obj: BdgShape = null

var pending_edges: Array = []
var pending_faces: Array = []
var pending_face_planes: Array = []
var lasts: Dictionary = {}

## Activate this builder as the innermost context.
func begin() -> void:
	_contexts.append(self)
	_current = self

## Deactivate this builder (returns true if it was the current context).
func end() -> bool:
	if _contexts.is_empty():
		return false
	if _current == self:
		_contexts.pop_back()
		_current = _contexts.back() if not _contexts.is_empty() else null
		return true
	return false

## Current innermost builder context (or null).
static func get_current() -> BdgBuilder:
	return _current

## Convenience: add an object (already built with its mode) to the current
## matching builder context. Returns true if handled.
static func add_to_current(obj: BdgShape, mode: int, builder_tag: String) -> bool:
	var current := _current
	while current != null:
		if current._tag == builder_tag:
			current._add_to_context(obj, mode)
			return true
		var idx := _contexts.find(current)
		current = _contexts[idx - 1] if idx > 0 else null
	return false

## Whether the current context is of the given tag.
static func has_context(tag: String) -> bool:
	return _current != null and _current._tag == tag

func _add_to_context(_obj_in: BdgShape, _mode: int) -> void:
	push_error("BdgBuilder._add_to_context must be overridden")

## The object built by this builder.
func obj() -> BdgShape:
	return _obj
