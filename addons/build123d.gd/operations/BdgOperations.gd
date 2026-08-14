extends RefCounted
## BdgOperations - Unified facade for all generic, sketch, and part operations.
## Mirrors build123d operations_generic.py, operations_sketch.py, and operations_part.py.
class_name BdgOperations

# --- Generic Operations ---

static func add(objects: Variant, mode: int = BdgEnums.Mode.ADD) -> Variant:
	return BdgOpsGeneric.add(objects, mode)

static func mirror(objects: Variant, about: BdgPlane = null) -> Variant:
	return BdgOpsGeneric.mirror(objects, about)

static func scale(objects: Variant, factor: Variant, center: Vector3 = Vector3.ZERO) -> Variant:
	return BdgOpsGeneric.scale(objects, factor, center)

static func offset(objects: Variant, amount: float, kind: int = 0) -> Variant:
	return BdgOpsGeneric.offset(objects, amount, kind)

static func project(objects: Variant, target: BdgShape, direction: Vector3 = Vector3.ZERO) -> Array:
	return BdgOpsGeneric.project(objects, target, direction)

static func split(objects: Variant, bisect_by: Variant, keep: int = BdgEnums.Keep.TOP) -> Variant:
	return BdgOpsGeneric.split(objects, bisect_by, keep)

static func bounding_box(objects: Variant) -> BdgBoundBox:
	return BdgOpsGeneric.bounding_box(objects)

# --- Sketch Operations ---

static func make_face(wires_or_edges: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgFace:
	return BdgOpsSketch.make_face(wires_or_edges, mode)

static func make_hull(points_or_shapes: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgFace:
	return BdgOpsSketch.make_hull(points_or_shapes, mode)

static func trace(wire: BdgWire, distance: float, mode: int = BdgEnums.Mode.ADD) -> BdgFace:
	return BdgOpsSketch.trace(wire, distance, mode)

# --- Part Operations ---

static func extrude(
	to_extrude: Variant,
	amount: float,
	dir: Vector3 = Vector3.ZERO,
	both: bool = false,
	taper: float = 0.0,
	mode: int = BdgEnums.Mode.ADD,
) -> BdgPart:
	return BdgOpsPart.extrude(to_extrude, amount, dir, both, taper, mode)

static func revolve(
	to_revolve: Variant,
	angle: float,
	axis: BdgAxis = null,
	mode: int = BdgEnums.Mode.ADD,
) -> BdgPart:
	return BdgOpsPart.revolve(to_revolve, angle, axis, mode)

static func sweep(
	profile: Variant,
	path: Variant,
	mode: int = BdgEnums.Mode.ADD,
) -> BdgShape:
	return BdgOpsPart.sweep(profile, path, mode)

static func loft(objs: Array, ruled: bool = false, mode: int = BdgEnums.Mode.ADD) -> BdgSolid:
	return BdgOpsPart.loft(objs, ruled, mode)

static func fillet(objects: Variant, radius: float) -> BdgShape:
	return BdgOpsPart.fillet(objects, radius)

static func chamfer(objects: Variant, length: float, length2: float = 0.0) -> BdgShape:
	return BdgOpsPart.chamfer(objects, length, length2)

static func section(shape: BdgShape, plane: BdgPlane = null) -> Array:
	return BdgOpsPart.section(shape, plane)

static func thicken(shape: BdgShape, amount: float, mode: int = BdgEnums.Mode.ADD) -> BdgShape:
	return BdgOpsPart.thicken(shape, amount, mode)

static func hollow(solid: BdgSolid, faces_to_remove: Array, thickness: float, mode: int = BdgEnums.Mode.ADD) -> BdgSolid:
	return BdgOpsPart.hollow(solid, faces_to_remove, thickness, mode)

static func draft(solid: BdgSolid, faces: Array, angle_deg: float, neutral_plane: BdgPlane, pull_dir: Vector3 = Vector3.ZERO, mode: int = BdgEnums.Mode.ADD) -> BdgSolid:
	return BdgOpsPart.draft(solid, faces, angle_deg, neutral_plane, pull_dir, mode)
