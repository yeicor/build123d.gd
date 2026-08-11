extends RefCounted
## BdgBuilder - base class for all builders (BuildPart, BuildSketch, BuildLine).
## Provides a push/pop context system: builders are active between begin() and end().
## Mirrors build123d/build_common.py Builder.
class_name BdgBuilder

static var _current: BdgBuilder = null
static var _contexts: Array = []

var _tag: String = "Builder"
var _obj: BdgShape = null

## Primary shape type handled by this builder ("edge", "face" or "solid")
var _primary: String = ""

var pending_edges: Array = []
var pending_faces: Array = []
var pending_face_planes: Array = []
var lasts: Dictionary = {}
var obj_before: BdgShape = null
var to_combine: Array = []
var new_edges: Array = []

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

# ---------------------------------------------------------------------------
# Operation tracking (Select.LAST / Select.NEW)
# ---------------------------------------------------------------------------

## Track the last operation given the typed inputs that were combined.
## Call after _obj has been updated. Fills lasts and new_edges.
func _track_op(typed_edges: Array, typed_faces: Array, typed_solids: Array) -> void:
	var pre := {}
	var post := {}
	for kind in ["vertex", "edge", "wire", "face", "shell", "solid"]:
		pre[kind] = _collect_entities(obj_before, kind)
		post[kind] = _collect_entities(_obj, kind)
	lasts["vertex"] = _delta(pre["vertex"], post["vertex"])
	lasts["edge"] = typed_edges if _primary == "edge" else _delta(pre["edge"], post["edge"])
	lasts["wire"] = _delta(pre["wire"], post["wire"])
	lasts["face"] = typed_faces if _primary == "face" else _delta(pre["face"], post["face"])
	lasts["shell"] = _delta(pre["shell"], post["shell"])
	lasts["solid"] = typed_solids if _primary == "solid" else _delta(pre["solid"], post["solid"])
	new_edges = _delta(pre["edge"], post["edge"])

func _collect_entities(obj: BdgShape, kind: String) -> Array:
	if obj == null:
		return []
	match kind:
		"vertex": return obj.vertices()
		"edge": return obj.edges()
		"wire": return obj.wires()
		"face": return obj.faces()
		"shell": return obj.shells()
		"solid": return obj.solids()
	return []

func _delta(pre: Array, post: Array) -> Array:
	var res: Array = []
	for p in post:
		var found := false
		for b in pre:
			if p._wrapped != null and b._wrapped != null and not p._wrapped.is_null() and p._wrapped.is_same(b._wrapped):
				found = true
				break
		if not found:
			res.append(p)
	return res

# ---------------------------------------------------------------------------
# Entity selectors (mirror build_common BuilderMixin)
# ---------------------------------------------------------------------------

func vertices(select: int = BdgEnums.Select.ALL) -> Array:
	match select:
		BdgEnums.Select.ALL: return [] if _obj == null else _obj.vertices()
		BdgEnums.Select.LAST: return _last_array("vertex")
		_:
			push_error("Select.NEW only valid for edges")
			return []

func vertex(select: int = BdgEnums.Select.ALL) -> BdgVertex:
	return _single(vertices(select), "vertex")

func edges(select: int = BdgEnums.Select.ALL) -> Array:
	match select:
		BdgEnums.Select.ALL: return [] if _obj == null else _obj.edges()
		BdgEnums.Select.LAST: return _last_array("edge")
		BdgEnums.Select.NEW: return new_edges
		_:
			push_error("Invalid Select value")
			return []

func edge(select: int = BdgEnums.Select.ALL) -> BdgEdge:
	return _single(edges(select), "edge")

func wires(select: int = BdgEnums.Select.ALL) -> Array:
	match select:
		BdgEnums.Select.ALL: return [] if _obj == null else _obj.wires()
		BdgEnums.Select.LAST:
			var wires: Array = []
			var last_edges := _last_array("edge")
			if not last_edges.is_empty():
				var w := BdgWire.make_wire(last_edges)
				if w != null:
					wires.append(w)
			return wires
		_:
			push_error("Select.NEW only valid for edges")
			return []

func wire(select: int = BdgEnums.Select.ALL) -> BdgWire:
	return _single(wires(select), "wire")

func faces(select: int = BdgEnums.Select.ALL) -> Array:
	match select:
		BdgEnums.Select.ALL: return [] if _obj == null else _obj.faces()
		BdgEnums.Select.LAST: return _last_array("face")
		_:
			push_error("Select.NEW only valid for edges")
			return []

func face(select: int = BdgEnums.Select.ALL) -> BdgFace:
	return _single(faces(select), "face")

func shells(select: int = BdgEnums.Select.ALL) -> Array:
	match select:
		BdgEnums.Select.ALL: return [] if _obj == null else _obj.shells()
		BdgEnums.Select.LAST: return _last_array("shell")
		_:
			push_error("Select.NEW only valid for edges")
			return []

func shell(select: int = BdgEnums.Select.ALL) -> BdgShell:
	return _single(shells(select), "shell")

func solids(select: int = BdgEnums.Select.ALL) -> Array:
	match select:
		BdgEnums.Select.ALL: return [] if _obj == null else _obj.solids()
		BdgEnums.Select.LAST: return _last_array("solid")
		_:
			push_error("Select.NEW only valid for edges")
			return []

func solid(select: int = BdgEnums.Select.ALL) -> BdgSolid:
	return _single(solids(select), "solid")

func _last_array(kind: String) -> Array:
	return lasts.get(kind, []) as Array

func _single(list: Array, what: String):
	if list.size() != 1:
		push_error("BdgBuilder: expected exactly one %s, found %d" % [what, list.size()])
		return null
	return list[0]
